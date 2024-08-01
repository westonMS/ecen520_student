#!/usr/bin/python3

# Manages file paths
import pathlib
import sys

# Add to the system path the "resources" directory relative to the script that was run
resources_path = pathlib.Path(__file__).resolve().parent.parent  / 'resources'
sys.path.append( str(resources_path) )

import repo_test_suite
import repo_test

# Path of script that is being run
SCRIPT_PATH = pathlib.Path(__file__).absolute().parent.resolve()

makefile_rules =  [ "sim_tx",  "sim_tx_115200_even" ]

# TCL simulation
tcl_sim = tester_module.tcl_simulation( "updown_tcl", "UpDownButtonCount", [ "updown", "oneshot" ])

# Bitstream build
bit_build = tester_module.build_bitstream("UpDownButtonCount",["updown_xdc"], [ "updown", "oneshot" ], True, False)

def main():
    ''' Main executable for script
    '''
    checker = repo_test_suite.create_from_path()
    #repo_test = repo_test.file_exists_test(checker,"makefile")
    repo_test.list_git_commits(checker)
    #repo_test.make_test(checker,"sim_tx")
    #repo_test.make_test(checker,"sim_tx_115200_even")
    #repo_test.check_for_untracked_files(checker, True)
    repo_test.make_test(checker,"clean")
    #repo_test.check_for_untracked_files(checker, False)

    # Run tests
    checker.run_tests()

if __name__ == "__main__":
    main()