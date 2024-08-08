#!/usr/bin/python3

import pathlib
import argparse
import shutil
import subprocess
import sys
import re
import os
import git

from repo_test import repo_test


class test_suite_520():

    def __init__(self, repo, min_err_commits = 3, max_repo_files = 20):
        # Reference to the Git repository
        super().__init__(repo)
        repo_test.list_git_commits(self)
        get_err_git_commits(self,min_err_commits)
        repo_test.check_for_max_repo_files(self,max_repo_files)
        # repo_test.make_test(checker,"sim_tx")
        # repo_test.make_test(checker,"sim_tx_115200_even")
        # repo_test.check_for_untracked_files(checker)
        # repo_test.make_test(checker,"clean")
        # repo_test.check_for_ignored_files(checker)


def test_args_520(description, parser=None):
    if parser is None:
        parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--noclean", action="store_true", help="Skip the \"clean\" portions of the test")
    parser.add_argument("--nobuild", action="store_true", help="Only complete the \"clean\" portion of the test")
    return parser

class get_err_git_commits(repo_test):
    ''' Prints the commits of the given directory in the repo.
    '''
    def __init__(self, repo_test_suite, min_msgs, check_path = None, check_str = "ERR"):
        '''  '''
        super().__init__(repo_test_suite)
        if check_path is None:
            self.check_path = self.rts.working_path
        else:
            self.check_path = check_path
        self.min_msgs = min_msgs
        self.check_str = check_str

    def module_name(self):
        return "Check for minimum number of error commits"

    def perform_test(self):
        relative_path = self.check_path.relative_to(self.rts.repo_root_path)
        self.rts.print(f'Checking for commits at {relative_path}')
        commits = list(self.rts.repo.iter_commits(paths=relative_path))
        chk_commits = []
        for commit in commits:
            commit_message = commit.message.strip()
            if self.check_str in commit_message:
                chk_commits.append(commit_message)
                print(commit_message)
        if len(chk_commits) >= self.min_msgs:
            return True
        else:
            self.rts.print_error(f"Insufficient number of error commits: found {len(chk_commits)} but expecting {self.min_msgs}")
            return False