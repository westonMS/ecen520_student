#!/usr/bin/python3

'''
A set of classes for performing tests within a git repo.
'''

# Manages file paths
import pathlib
# Shell utilities for copying, 
import shutil
import subprocess
import os
import sys
from enum import Enum
from git import Repo
import re


class repo_test():
    """ Class for performing a test on files within a repository.
    Each instance of this class represents a _single_ test with a single
    executable. Multiple tests can be performed by creating multiple instances
    of this test class.
    This is intended as a super class for custom test modules.
    """

    def __init__(self, repo_test_suite, abort_on_error=True, process_output_filename = None):
        """ Initialize the test module with a repo object """
        self.rts = repo_test_suite
        self.rts.add_test_module(self)
        self.abort_on_error = abort_on_error
        self.process_output_filename = process_output_filename

    def module_name(self):
        """ returns a string indicating the name of the module. Used for logging. """
        return "BASE MODULE"

    def perform_test(self):
        return False

    def execute_command(self, proc_cmd, process_output_filename = None ):
        """ Completes a sub-process command. and print to a file and stdout.
        Args:
            proc_cmd -- The string command to be executed.
            proc_wd -- The directory in which the command should be executed. Note that the execution directory
                can be anywhere and not necessarily within the repository. If this is None, the self.working_path
                will be used.
            print_to_stdout -- If True, the output of the command will be printed to stdout.
            print_message -- If True, messages will be printed to stdout about the command being executed.
            process_output_filepath -- The file path to which the output of the command should be written.
                This can be None if no output file is wanted.
        Returns: the sub-process return code
        """
        
        fp = None
        if self.rts.log_dir is not None and process_output_filename is not None:
            if not os.path.exists(self.repo_test_suite.log_dir):
                os.makedirs(self.repo_test_suite.log_dir)
            process_output_filepath = self.log_dir + '/' + process_output_filename
            fp = open(process_output_filepath, "w")
            if not fp:
                self.rts.print_error("Error opening file for writing:", process_output_filepath)
                return -1
            self.rts.print("Writing output to:", process_output_filepath)
        cmd_str = " ".join(proc_cmd)
        message = "Executing the following command in directory:"+str(self.rts.working_path)+":"+str(cmd_str)
        self.rts.print(message)
        if fp:
            fp.write(message+"\n")
        # Execute command		
        proc = subprocess.Popen(
            proc_cmd,
            cwd=self.rts.working_path,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
        )
        for line in proc.stdout:
            if self.rts.print_to_stdout:
                sys.stdout.write(line)
            if fp:
                fp.write(line)
                fp.flush()
        # Wait until process is done
        proc.communicate()
        return proc.returncode

class file_exists_test(repo_test):
    ''' Checks to see if files exist in a repo directory
    '''

    def __init__(self, repo_test_suite, repo_file_path, abort_on_error=True):
        '''  '''
        super().__init__(repo_test_suite, abort_on_error)
        self.repo_file_path = repo_file_path

    def module_name(self):
        return "File Check"

    def perform_test(self):
        file_path = self.rts.working_path / self.repo_file_path
        if not os.path.exists(file_path):
            self.rts.print_error(f'File does not exist: {file_path}')
            return False
        self.rts.print(f'File ok: {file_path}')
        return True

class make_test(repo_test):
    ''' Performs makefile rules
    '''

    def __init__(self, repo_test_suite, make_rule, generate_output_file = True, make_output_filename=None,
                 abort_on_error=True):
        '''  '''
        if generate_output_file and make_output_filename is None:
            make_output_filename = make_rule.replace(" ", "_") + '.log'
        super().__init__(repo_test_suite, abort_on_error=abort_on_error, process_output_filename=make_output_filename)
        self.make_rule = make_rule

    def module_name(self):
        return "Makefile"

    def perform_test(self):
        cmd = ["make", self.make_rule]
        return_val = self.execute_command(cmd)
        if return_val != 0:
            return False
        return True

class check_for_untracked_files(repo_test):
    ''' 
    '''
    def __init__(self, repo_test_suite, ignore_ok = True):
        '''  '''
        super().__init__(repo_test_suite)
        self.ignore_ok = ignore_ok

    def module_name(self):
        return "Check for untracked GIT files"

    def perform_test(self):
        # TODO: look into using repo.untracked_files instead of git command

        untracked_files = self.rts.repo.git.ls_files("--others", "--exclude-standard")
        if untracked_files:
            self.rts.print_error(f'Untracked files found in repository:')
            files = untracked_files.splitlines()
            for file in files:
                self.rts.print_error(f'  {file}')
            return False
        self.rts.print(f'No untracked files found in repository')
        return True

class check_for_ignored_files(repo_test):
    ''' 
    '''
    def __init__(self, repo_test_suite):
        '''  '''
        super().__init__(repo_test_suite)

    def module_name(self):
        return "Check for ignored GIT files"

    def perform_test(self):
        # TODO: look into using repo.untracked_files instead of git command

        ignored_files = self.rts.repo.git.ls_files("--others", "--ignored", "--exclude-standard")
        if ignored_files:
            self.rts.print_error(f'Ignored files found in repository:')
            files = ignored_files.splitlines()
            for file in files:
                self.rts.print_error(f'  {file}')
            return False
        self.rts.print(f'No ignored files found in repository')
        return True

class check_for_uncommitted_files(repo_test):

    def __init__(self, repo_test_suite):
        '''  '''
        super().__init__(repo_test_suite)

    def module_name(self):
        return "Check for uncommitted GIT files"

    def perform_test(self):
        uncommitted_files = self.repo.git.status("--suno")
        if uncommitted_files:
            self.rts.print_error(f'Uncommitted files found in repository:')
            files = uncommitted_files.splitlines()
            for file in files:
                self.rts.print_error(f'  {file}')
            return False
        self.rts.print(f'No uncommitted files found in repository')
        return True

class list_git_commits(repo_test):

    def __init__(self, repo_test_suite, repo_path = None):
        '''  '''
        super().__init__(repo_test_suite)
        if repo_path is None:
            self.repo_path = self.rts.script_path
        else:
            self.repo_path = repo_path

    def module_name(self):
        return "List Git Commits"

    def perform_test(self):
        commits = self.rts.repo.git.log("--pretty=format:%h %ad \"%s\"", "--date=format:%m%d%y_%H:%M")
        commits = commits.splitlines()
        if commits:
            self.rts.print(f'{len(commits)} Commits found in {self.repo_path}:')
            for commit in commits:
                # e387b37 073124/17:36 "Updated requriements"
                commit_re = re.compile(r'(\w+)\s+(\d+)\s+\"(.*)\"')
                match = commit_re.match(commit)
                self.rts.print(f'  {commit}')
                # TODO: print all the files changed in the commit (option?)
                if match:
                    hash = match.group(1)
                    date = match.group(2)
                    message = match.group(3)
                    files = self.repo.git.show("--name-status", hash)
                    for file in files:
                        self.rts.print(f'    {file}')
            return True
        self.rts.print(f'No uncommitted files found in repository')
        return False
