# ECEN 520 Assignments

This page describes how you are to submit your assignments for the class. 

## GitHub

All assignments for this class will involve posting a report in a markdown file and all your code on a private [GitHub](https://github.com/) repository. 
If you do not have a GitHub account, you will need to [create an account](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F&source=header-home) for use in this class.
Send me your github username so I can add you as a user on the [ECEN_520](https://github.com/byu-cpe/ECEN_520) github repository which contains course materials, the class wiki, and assignment descriptions.

You will be responsible for learning how to use 'git' and 'GitHub' for creating repositories, committing code, managing Markdown files, and maintaining your projects. 
If you are not familiar with using these tools you are encouraged to complete the BYU bootcamp tutorials for [git](https://byu-cpe.github.io/ComputingBootCamp/tutorials/git/) and [GitHub](https://byu-cpe.github.io/ComputingBootCamp/tutorials/github/). 
There are many other tutorials online you can follow to sharpen your git/GitHub skills.

Create a private personal repository for this class. 
Name this repository "ECEN_520_\<last name\>" where \<last name\> refers to your last name using conventional capitalization (i.e. `Wirthlin` for my last name).
Make sure the repository is private. 
After creating the repository, [add me as a collaborator](https://docs.github.com/en/github/setting-up-and-managing-your-github-user-account/managing-access-to-your-personal-repositories/inviting-collaborators-to-a-personal-repository) to the repository. 
My GitHub username is `wirthlin`. 

## GitHub Commits

For this class you are required to submit regular commits to your repository as you complete your assignments.
When using Git, you typically commit your code when you have something working to checkpoint your progress.
In this class we will use Git more aggressively by having you commit your code *when you encounter a problem*.
This way I can track your progress through the assignment and see the problems you ran into.
This way, I can track your progress through the assignment and see the problems you ran into.
This will help me improve the labs and provide better feedback.
Further, I plan on using your commit history as part of a training set for a machine learning project I am working on (this project will collect examples of "non working" HDL code, the error messages that were generated, and the fixes that were made to get the code working).

When committing your code after you experience a problem, you must add a commit message with the following form: `"ERR:<error code> <Error summary>"`.
This message is needed for me to review the various types of errors you are experiencing and see how you resolve the problem.
The following error codes should be used:
* VLOG: An error with the QuestaSim module compilation. Use this error code for VHDL errors as well (the VCOM tool in QuestaSim)
* VSIM: An error when trying to run the vsim simulation tool. Note that this code should not be used when your module simulates but operates incorrectly. This is for errors in the elaboration process before starting the vsim simulation.
* TEST: When your module fails a simulation testbench
* SYNTH: An error with the synthesis process (`synth_design`)
* IMPL: An error during the implementation process (`opt_design`, `place_design`, `route_design`, or `write_bitstream`)
* DOWNLOAD: When your bitstream that is downloaded does not operate properly

For example, the following commit message demonstrates the proper way to describe a synthesis error: `"ERR:SYNTH There was a combinational feedback loop in my design"`.

You are encouraged to commit regularly when your code reaches various stable states of working.
In these cases you do not need any special commit message.
Of course you will need to commit your final working code as part of the submission process.


## Readme.md

Create a top-level opening Readme.md file welcome page for your repository that is formatted with Markdown tags.
Here is a sample Readme.md file you can start with:

```
# ECEN 520: Mike Wirthlin

This repository contains the laboratory submissions for [ECEN 520](https://github.com/wirthlin/ECEN_520) for Mike Wirthlin. 

## Assignments

* [UART Transmitter](./uart_transmitter/Readme.md)
* [Next assignment]
```

Note that there is a section in this file for assignments.
You will need to have a list of each assignment and include a link to your assignment writeup. 

Because GitHub will be used for your assignment submissions, you will be required to organize and maintain your repository properly.
You will be required to follow several [Git repository standards](./coding_standard#git_repository_standards) as you maintain your repository and your assignment grade will be based in part on how these standards are followed.

## Assignment Makefiles

You will be required to create a custom `makefile` for each assignment that allows you and me to create your assignment from the command line.
While GUI tools are available for you to help you complete your assignment, the actual submission and grading will be done exclusively from the command line.
The details on the makefile rules needed for each assignment will be described on the assignment summary page.

All assignment makefiles must have a `clean` rule that will completely clean all intermediate files generated by project.
You will lose points on your assignment if you fail to clean intermediate files generated by your project.


## Assignment Submission

Each assignment submission will involve committing files to a specific directory in your GitHub repository (the name of the directory will be provided in the lab instructions). 
The submission must include a `Readme.md`` file at the top-level of that assignment specific directory formatted with Markdown tags. 
A template that all labs must follow for this file is provided below:

```
# <Name>

**Assignment Name**

**Hours Spent**

**Summary of Major Challenges**

## Assignment Specific Responses

```
For each assignment you will need to keep track of the number of hours you spent on the assignment.
This helps me gauge the difficulty of the assignment and see how long it takes for you to complete it.
I would also like you to describe any major challenges you faced in the lab so I have a better idea on how I can improve the assignment in the future.
Each assignment will also ask you for additional information to include in this file.

In addition to the `Readme.md file`, your submission must include all of the files you created to complete the assignment. 
More details on what files are needed will be included in the instructions of each assignment
Your files will be reviewed as part of your assignment grade. 
Your code must follow any relevant coding standards and will be graded accordingly. 

An assignment "submission" involves a final commit and tag of files to your class repository. 
The assignment due dates are posted on learning suite. 
Please review the learning suite syllabus for details on the late policy for assignments. 
Each assignment submission will require a unique 'tag' where the actual tag is the same as the directory for the assignment.
When grading your assignment, I will check the submission time of this tag. 
If your latest commit of any file in the assignment with this tag is later than the deadline then you will be penalized for being late.
You may change your files after the submission date but do not retag these files unless you are changing your submission.

## Assignment Late Policy

Each assignment will have a due date/time published on learning suite.
It is your responsibility to identify the due date and submit your assignment on time.
Late assignments will be accepted and graded but will be subject to a 10% penalty per work day (i.e., M-F, excluding university holidays).
Submissions submitted five days or later passed the due date will be penalized by a maximum 50%.
Late submissions may not be graded in a timely manner and submissions past 4 days will not receive any feedback.
**No credit will be given for any assignments submitted after midnight on the last day of class (December 11th).**


## Assignment Grading

Each assignment will be graded using the following three components:
* **Operation** of your final assignment 
* **Coding Standard** of your submission
* **Assignment specific criteria**
The actual allocation of the assignment grade will be specified in the assignment page.
Each of these will be described in more detail below.

**Operation**

For this portion of your grade, you will be graded on the actual functionality of submission and will depend on the requirements of the given assignment.
This will usually include a simulation, synthesis, and actual operation on an FPGA board.
Note that submissions that do not simulate or build (i.e., submissions with syntax or build errors) will not receive any credit for this component of your grade.

**Coding Standard**

All of your submissions should conform to the class [coding standards](./coding_stadard.md).
The coding standards are progressive meaning that additional standards will be added gradually throughout the class.
Each assignment will indicate which code standard level you will be required to follow.

In addition to following coding standards, you are required to follow several git repository organization [standards](./coding_stadard.md#git-repository-standards).
Several basic standards for organizing your github repositories are given to aid in the grading of assignments and to provide a tidy repository environment.

You will receive full credit for this portion of your assignment grading if you conform to the coding and repository standards.
You will receive feedback for any violations of these standards as part of your assignment grade.

**Assignment Specific Criteria**

This portion of your grade will be based on any assignment specific criteria you are given.
See the assignment description for details on this portion of your grade.