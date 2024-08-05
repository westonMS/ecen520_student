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

def test_args_520(description, parser=None):
    if parser is None:
        parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--noclean", action="store_true", help="Skip the \"clean\" portions of the test")
    parser.add_argument("--nobuild", action="store_true", help="Only complete the \"clean\" portion of the test")
    return parser

class get_err_git_commits(repo_test):
    ''' Prints the commits of the given directory in the repo.
    '''
    def __init__(self, repo_test_suite, check_path = None):
        '''  '''
        super().__init__(repo_test_suite)
        if check_path is None:
            self.check_path = self.rts.working_path
        else:
            self.check_path = check_path

    def module_name(self):
        return "List Git Commits"

    def perform_test(self):
        relative_path = self.check_path.relative_to(self.rts.repo_root_path)
        self.rts.print(f'Checking for commits at {relative_path}')
        commits = list(self.rts.repo.iter_commits(paths=relative_path))
        for commit in commits:
            commit_hash = commit.hexsha[:7]
            commit_message = commit.message.strip()
            commit_date = commit.committed_datetime.strftime('%Y-%m-%d %H:%M:%S')
            print(f"{commit_hash} - {commit_date} - {commit_message}")
        return True