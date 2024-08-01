#!/usr/bin/python3

import pathlib
import argparse
import shutil
import subprocess
import sys
import re
import os
from git import Repo

class git_repo:
    ''' Represents a git repository and provides a number of functions for simplifying the
    access and manipulation of the repository. '''
    def __init__(self, repo):
        self.repo = repo

    def is_valid_repo(self):
        ''' Check to see if the repository is valid '''
        return not self.repo.bare

    def checkout_tag(self, tag, fetch_tags = True):
        ''' Checkout a tag in the repository '''
        if fetch_tags:
            self.repo.git.fetch("--tags","--force")
        self.repo.git.checkout(tag)

    def tag(self, tag, force=False):
        ''' Tag the repository. Return True if successful, False otherwise '''
        tag_exists = self.repo.git.fetch("tag","-l",tag)
        if tag_exists and not force:
            return False
        self.repo.git.fetch("tag","--force",tag)

    def get_origin_url(self):
        ''' Get the URL of the origin remote '''
        return self.repo.remotes.origin.url

    def is_classroom_repo(self,class_repo_name):
        # TODO: check for classroom repo
        pass

class remote_repo(git_repo):
    ''' Create a git_repo object from a remote repository. This will clone the repo '''

    def __init__(self, remote_url, local_dir = ".", starter_code = None):
        self.repo = Repo.clone_from(remote_url, local_dir)
        # TODO: check out starter code as well
        # TODO: support additional remotes?

class remote_classroom_repo(remote_repo):
    ''' Create a git_repo object from a remote repository. This will clone the repo '''

    def __init__(self, classroom_name, github_username, local_dir = "."):
        # TODO: create URL
        remote_url = f"test"
        super().__init__(remote_url,local_dir)

class local_repo:
    ''' Create a git_repo object from a local existing repository '''

    def __init__(self, local_path):
        self.local_path = local_path
        self.repo = Repo(local_path)
        # TODO: check for failure?
