# UART Transmitter Simulation

For this first assignment, you will be designing and simulating a UART transmitter.
Hopefully this assignment will be more of a review as the design of a UART transmitter is a common exercise in many introductory digital design courses.
The purpose of this assignment is to help you review your digital design skills and help you become familiar with the simulation tool.
You will not be synthesizing and downloading your design in this lab as you will focus primarily on design and simulation. 
We will synthesize and download the design in the next lab.

## Assignment Mechanics

Assignments play an important part of this class and much of your learning and skill development will occur while you complete assignments.
To complete and submit your assignments, you will need to follow the [assignment mechanics](../resources/assignment_mechanics.md) for the class.
Carefully review these guidelines before proceeding with this assignment.

### Create a GitHub Repository

As described in the [assignment mechanics](../resources/assignment_mechanics.md#github) page, you will need to submit your laboratory assignments using GitHub. 
When you have created your repository, add me as a collaborator as instructed in the mechanics web page.

You must place your assignment code within a specific assignment directory as described in the [assignments overview](../Readme.md) page.
Make sure your add this directory to your repository and place all assignment specific code in this directory.
You will also need to tag your repository when you are ready to submit.

### Perform Regular GitHub commits

As described in the [assignment mechanics](../resources/assignment_mechanics.md#github-commits) page, you will need to make regular commits to your repository as you complete your assignment.
Assignments submitted with only a single commit and no error examples will be penalized.

## Tools for this Assignment

Throughout this class you will learn to use a variety of tools to complete the assignments.
In this assignment you will need to use the following tools: [VSCode](https://code.visualstudio.com/) for text entry and QuestaSim for simulation.
You will learn about other tools (including the FPGA tools) in future assignments.

### VSCode

We will be using a number of different tools throughout the semester and many of these tools have an integrated text editor.
It is strongly recommended that you use [VSCode](https://code.visualstudio.com/) for all your text editing needs.
We will use the command line version of most of these tools and thus will rely on VSCode for all text editing.
VSCode is a free, open-source text editor that is available for Windows, Linux, and MacOS.
In addition to editing your files, you can also use VSCode to manage the GitHub repository for your assignments (commit, pull, push, etc.).
You will be much more productive in this class if you learn how to use VSCode proficiently.

I recommend that you install the [Verilog-HDL/SystemVerilog/Bluespec SystemVerilog](https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL) extension for VSCode to assist with syntax highlighting and other features.

### QuestaSim

For this assignment you will be using QuestaSim as a simulator to simulate your design.
QuestaSim is a commercial HDL simulator that is used in the design of large, complex ASICs and will be the simulator we use for this course.
QuestaSim has been installed on the computers in the digital lab and the embedded systems lab (see this link for [setting up your environment](../resources/tools.md#questasim-setup) to use these tools).

Go through the [QuestaSim Tutorial](../resources/questa_tutorial.md) to learn how to use QuestaSim in both GUI and command line mode.
You will need to use the command line mode for submitting this assignment.

## UART Transceiver Design

The primary goal of this assignment is to design a UART transmitter for transmitting data over a conventional serial connection.
You will need to create this design in SystemVerilog and simulate it using QuestaSim.
There is a ECEN 320 lab description for a [UART Transceiver](https://byu-cpe.github.io/ecen320/labs/lab-09/) that you can use as a reference.

Create your transmitter with the following ports and parameters (you must name the ports and parameters as indicated for the testbenches to operate correctly):
| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ---- |
| clk | Input | 1 | Clock |
| rst | Input | 1 | Reset |
| send | Input | 1 | Control signal to start a transmit operation |
| din | Input | 8 | 8 data bits to send |
| busy | Output | 1 | Indicates that the transmitter is in the middle of a transmission |
| dout | Output | 1 | Transmitter output signal |
| Parameter Name | Type | Default | Purpose |
| ---- | ---- | ---- | ----  |
| CLK_FREQUENCY | integer | 100_000_000 | Clock frequency of the design |
| BAUD_RATE | integer | 19_200 | Baud rate of the design |
| PARITY | integer | 1 | Parity type (0 = Even, 1 = Odd) |

Design your transmitter to operate as follows:
* Determine the baud period based on the clock frequency and baud rate parameters
* Generate your UART transmission signal as follows:
  * Send a start bit (low)
  * Send 8 data bits
  * Send a parity bit (Based on the parity parameter)
  * Send 1 stop bit
* The 'tx' signal starts out high on reset (not low!). This is to prevent any inadvertent characters from being sent when your module is reset
* The 'busy' signal is asserted whenever you are in the middle of a transmission (i.e., not in an idle state)
  * Ignore the 'send' signal if you are in the middle of a transmission
* Reset the internal state machines/counters when the 'rst' signal is asserted
  * Provide two flip-flops between the incoming 'rst' port and the reset you use in your design to synchronize the reset to the global clock
  * Implement an asynchronous reset in your design
* You do not need to implement handshaking as described by the 320 lab assignment.

Note that you must follow the [Level 1](../resources/coding_standard.md#level_1) coding standards for your Verilog files.

## Verifying Transmitter and Testbench

An essential part of digital design is properly _verifying_ your design.
For this design and all designs you create in this class you will be carefully verifying with a design testbench.
<!--
TCL command tutorial?

You may want to simulate your design using a `.tcl` file during the early stages of your design process.
There are tutorials for using TCL on the 320 page [here](https://byu-cpe.github.io/ecen320/tutorials/lab_03/04_tcl_tutorial/) and [here](https://byu-cpe.github.io/ecen320/tutorials/lab_04/00_tcl_tutorial_2/).
Note that you are not required to simulate with `.tcl` files and such files will not be graded as part of this assignment.
-->
We will be using and writing testbenches through the semester to help aid in your verification efforts.
A testbench, [tx_tb.sv](./tx_tb.sv), has been created for you to test your transmitter.
This testbench also includes a behavioral model of a simple UART "receiver", [rx_model.sv](./rx_modelsv).
You will need to test your transmitter with this testbench (and associated model) and make sure it operates without any warnings or errors.

Although you are free to use the GUI version of the ModelSim tools during the development process, you will be required to build your project using the command line.
All grading of your assignment will be done by building your project using the command line. 
This will involve creating a `makefile` with a number of rules for simulating and synthesizing your project.
<!--
A resource page with instructions for using the Vivado [command line](../resources/vivado_command_line.md) is available for you.
-->
When your transmitter operates correctly with the testbench, create a makefile with the `sim_tx` rule that will simulate your transmitter with the testbench from the command line.
Here is a sample makefile rule that will run the testbench simulation from the command line (you may need to adapt this to the names used by your design files):
```
sim_tx: tx.sv
    vlog tx.sv tx_tb.sv rx_model.sv
    vsim -c work.tx_tb -do "run -all"
```

You will need to verify that your transmitter works correctly with multiple baud rates and clock frequencies.
Further, you need to verify that your transmitter works with both even and odd parity.
You will need to create a makefile rule named `sim_tx_115200_even` that command line simulation of tx testbench with a baud rate of 115200 and even parity.
The following makefile rule demonstrates how to elaborate the simulation model with different top-level parameters:

```
sim_tx_115200_even: tx.sv
    xvlog -sv tx.sv tx_tb.sv rx_model.sv
    vsim -c work.tx_tb -gBAUD_RATE=115200 -gPARITY=0 -do "run -all"
```

## Submission and Grading

Once you have completed the assignment and verified that everything is working correctly, follow these steps to formally submit your assignment.

1. Prepare your repository
  * Make sure all the _essential_ files needed to complete your project are committed into your repository. If you are missing any of the essential files you will not receive credit for the lab
  * Make sure no _non-essential_ files are committed to your repository (like log files or temporary project files). You will lose 10% on your lab if any non-essential temporary files are committed to your repository.
  * Make sure you have a `.gitignore` file for your assignment directory and that all intermediate files are ignored.
  * Make sure you have a `makefile` with all the necessary make rules
    * `sim_tx`: performs command line simulation of tx testbench using the default parameters
    * `sim_tx_115200_even`: performs command line simulation of tx testbench with a baud rate of 115200 and even parity
2. Commit and tag your repository
  * Make sure all of your files are committed and properly tagged (using the tag listed at the top of the lab)
  * Make sure you follow the [Git repository standards](../resources/coding_standard.md#git-repository-standards)
3. Create your assignment [Readme.md](../resources/assignment_mechanics.md#assignment-submission) file based on the template
  * Add the following items for the assignment-specific section of the readme:
    1. **Coding Skill Summary**: Provide a short summary of how much HDL review you had to do to complete the assignment. Also, rate your HDL designs skills from 1-10.

### Grading

I will follow these steps to grade this assignment.
I will run these commands on the digital lab computers.
You may want to perform these steps as well to make sure that your submission is submitted correctly.

1. Fetch and get tag of your submission
```
git fetch --all --tags
git pull
git checkout tags/<assignment tag>
```
2. Check date of submission
```
git log -n 1 tags/<assignment tag>
```
3. Simulate and build your design
   * run `make sim_tx`
   * run `make sim_tx_115200_even`
7. Check to see if there are any files that are generated during the build process but not ignored. I will run the following command:
`git ls-files . --exclude-standard --others`. <br>If there are any files not ignored after running the above make commands then you will lose points.
7. Review the number of commits and the commit messages to your assignment directory: `git log --pretty=format:"%ad %s" --date=short --`. You will need to demonstrate that you have made several error commits as part of your history.
8. run `make clean`
I will clean the directory where I ran your commands to make sure the clean works properly. 
I will check to see if your `make clean` cleaned all the ignore files: `git check-ignore *` <br>
If there are any files that remain that are not cleaned by the `make clean` then you will lose some points.
10. Review your Readme.md to see if it has all the requirements
11. Review your code for compliance to the coding standards