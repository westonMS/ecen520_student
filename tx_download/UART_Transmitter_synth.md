# UART Transmitter Synthesis and Download

<!--
  - Make the debounce time longer on the top-level testbench (it uses 1 ms but we probably need 5 ms)
  - Modify the receiver model to handle resets. You can do this by using fork / join_any (i.e., one fork does the receive processing
    and the other fork listens to the rest and done. the second fork ends when done is high OR when a rest is asserted. If a reset is
    asserted then terminate the other fork.). This would be a good way to demonstrate the forks
-->

For this assignment you will create a top-level design for your UART transmitter, synthesize the transmitter, and download it to the FPGA board.

**Assignment reminders:**
* As with the previous assignment, you must place your assignment code within a specific assignment directory as described in the [assignments overview](../Readme.md) page.
Make sure your add this directory to your repository and place all assignment specific code in this directory.
* You will also need to tag your repository when you are ready to submit.
* You are required to make frequent commits when you have design failures as described [here](../resources/assignment_mechanics.md#github-commits)

## Top-Level Transmitter Design

There are several steps needed to create a working UART transmitter design from your transmitter module from the last assignment.
You will need to create a top-level design that includes your transmitter module, a debouncer, and a one-shot detector.
You will need to create an xdc file that maps the pins of the FPGA to the ports of your design and you will need to run your full design files and xdc file through the Xilinx synthesis tools. 
The instructions below will guide you through these steps.


### Debouncer and One Shot Circuit

Before creating the top-level design, create a debouncer circuit to debounce the buttons on the FPGA board.
A debouncer is needed to prevent a single press of the button from being interpreted as multiple presses and thus causing multiple characters to be transmitted over the UART.
The idea behind the debouncer is to make sure that the button signal is stable for a minimum amount of time before actually accepting the signal as valid (i.e., ignore short pulses).
There is a [lab description](https://byu-cpe.github.io/ecen320/labs/lab-08/) of a debouncer that you can use as a reference.
Your debouncer will need to have a parameter that specifies the minimum debounce delay in microseconds. 
This way you can simulate your debouncer with relatively short debounce times but synthesize your debouncer with a longer debounce time.
You will be using the debouncer module in several assignments during the semester.

In addition to the debouncer, you need to create a "one shot" circuit that will generate a single pulse output when the button is pressed.
The purpose of the one-shot circuit is to generate a single pulse when the button is pressed and to ignore any additional presses until the pulse has completed.
If you do not add a one-shot circuit then the button press will be interpreted as multiple presses and multiple characters will be transmitted over the UART.
The output of the debouncer plus one-shot circuits will go into the `send` input of your transmitter module.

### Create a top-level FPGA design

Create a top-level design that instances your transmitter and hooks it up to the I/O pins of the FPGA board.
For this assignment and throughout the class we will be using the [Nexys 4 DDR](https://reference.digilentinc.com/programmable-logic/nexys-4-ddr/start) board and the top-level ports will correspond to the port names on this board.
Create a top-level module named `tx_top.sv` with the following ports and parameters (the port names are derived from the nexys4 DDR XDC file):

| Port Name | Direction | Width | Function |
| ---- | ---- | ---- | ----  |
| CLK100MHZ | Input | 1 | Clock |
| CPU_RESETN | Input | 1 | Reset (low asserted) |
| SW | Input | 8 | Switches (8 data bits to send) |
| BTNC | Input | 1 | Control signal to start a transmit operation |
| LED | Output | 8 | Board LEDs (used for data) |
| UART_RXD_OUT | Output | 1 | Transmitter output signal |
| LED16_B | Output | 1 | Used for TX busy signal |
| Parameter Name | Type | Default | Purpose |
| ---- | ---- | ---- | ----  |
| BAUD_RATE | integer | 19_200 | Baud rate of the design |
| PARITY | integer | 1 | Parity type (0 = Even, 1 = Odd) |
| DEBOUNCE_DELAY_US | integer | 10_000 | Specifies the minimum debounce delay in micro seconds|

Create your top-level design as follows:
  * Instance your transmitter component from the previous assignment (**Note**: do not copy your file into this assignment directory. Instead, use a relative path to the file in the previous assignment directory. If you need to make changes to the transmitter, make them in the previous directory. Your original submission should be properly tagged).
  * Attach the lower 8 switches on the board to the input to the UART transmitter (i.e., the value of the switches is the value to transmit over the UART).
  * Attach the lower 8 switches on the board to the lower 8 LEDs. This way the user can more easily see the value of the switches with the LEDs
  * Attach the `tx_busy` signal from your transmitter to the LED16_B signal. This is the "blue" color for tri-color LED 16 on the board (it should flash blue when the transmitter is busy)
  * Hook up the center button (BTNC) to your circuit so that when the button is pressed one character will be transmitted. You will need a debouncer and one-shot circuit to accomplish this. You will need to implement a simple state machine or handshaking protocol to make sure that only one character is sent for each button press.
  * Attach the CPU reset so that when pressed, the system will be reset (note that the input reset polarity is negative asserted). Add two synchronizing flip-flops between the reset button and your internal reset signal to synchronize the reset signal to the global clock. We will discuss the purpose of these synchronizing flip flops later in the class
<!--
  * Add a flip-flop on the TX output of your transmitter module and send the output to the top-level TX output. This flip-flop will make sure that the output signal does not glitch. 
-->

A top-level testbench, [top_tb.sv](./top_tb.sv), has been created for you to test your top-level design.
This testbench also uses the [rx_model.sv](../tx_sim/rx_model.sv) simulation model from the previous assignment.
Make sure your top-level design successfully passes this testbench.
Add a makefile rule named `sim_top` that will perform this simulation from the command line using the default parameters.
In addition, make a second makefile rule named `sim_top_115200_even` that performs this simulation with the parameters changed as follows: baud rate = 115200 and even parity.
Do not proceed to the next step until you have successfully simulated your top-level design for both baud rates and parities.

## Design Implementation

After verifying your design, the next step in this assignment is to synthesize your design and download it to the FPGA board.
If your design is properly verified and written in a way that synthesizes without any problems then this step can be relatively easy.
For this class we will be using the command line tools in non-project mode for the synthesis and implementation.
This is unlike previous classes where you might have used the Vivado GUI and used Vivado projects to manage your implementation flow.

### XDC Constraints File

The first step in this process is to create a top-level `.xdc` file that maps the top-level pins of your circuit to the appropriate FPGA pin on this board.
The easiest way to do this is to start with the master [`.xdc`](../resources/Nexys-4-DDR-Master.xdc) file for the Nexys 4 DDR board and uncomment the appropriate pins used by your design.
If you named your top-level ports as described above, then you can uncomment the corresponding lines in the `.xdc` file.
Note that you have to uncomment both lines related to the clock (the pin constraint and the timing constraint).
In addition to the pin constraints, you will need to add the following constraints to your `.xdc` file to set the voltage and I/O standard for the pins:
```
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
```
Make sure you commit your `.xdc` file to your repository.

<!--
The following [xdc tutorial](https://byu-cpe.github.io/ecen320/tutorials/lab_03/05_making_an_xdc_file/) can help you complete an xdc file and add the xdc file to your project.
-->

### Design Synthesis

The next step in the implementation process is to synthesize your design with the Xilinx Vivado synthesis tool.
Although you are welcome to run the synthesis tool in the GUI mode, you will need to run the tool in command line mode for submission of this assignment.
You are encouraged to use the command line mode during development to make sure you are familiar with the process.

Start by running vivado in interactive mode as follows:
```
vivado -mode batch
```
You will have access to the Vivado tools in batch mode allowing you to execute individual tcl commands to perform the synthesis and implementation steps.
The discussion below will describe these commands for interactive use but you will eventually run these as a .tcl synthesis script.
You will need to execute several commands to complete the synthesis process:
1. Load the HDL files<br>
The first step involves compiling your HDL files into a representation that can be synthesized.
Although your files have been previously compiled for simulation in QuestaSim, they must be compiled again within the Vivado tools.
You can load the files using the [`read_verilog`](../resources/vivado_command_line.md#read_verilog) command with the `-sv` option.
The following example demonstrates how to compile two files in the Vivado tools:
```
read_verilog -sv tx.sv
read_verilog -sv tx_top.sv
```
Note that since we are not simulating in this process, you do not need to compile the testbench files - these files are only used for simulation in QuestaSim.

2. Load the xdc files<br>
The next step involves loading the XDC file that contains the pin constraints for your design.
Your design will not be able to be synthesized and implemented without these constraints.
This is done using the [`read_xdc`](../resources/vivado_command_line.md#read_xdc) command.
The following command demonstrates how to load the .xdc file:
```
read_xdc top.xdc
```

3. Run the synthesis command

The final step for synthesis is to run perform the actual synthesis using the [`synth_design`](../resources/vivado_command_line.md#synth_design) command.
This command requires at least two options: the top-level module name and the part number of the FPGA you are targeting.
The following example demonstrates how to run the synthesis command for a top-level module named `top` and the part we are using on the NexysDDR board:
```synth_design -top top -part xc7a100tcsg324-1
```

Sometimes you will need to change the top-level parameters of your design as part of the synthesis step.
This can be done using the `-generic` option.
For example, the option `-generic {BAUD_RATE=115200}` would change the top-level BAUD_RATE of your design if you wanted to synthesize a design with a different baud rate.

This command may take some time to execute and will produce a lot of text output.
It is possible that the synthesis will fail due to errors in your design.
Even though your design simulates correctly, you may have not coded your HDL properly to result in a successful synthesis.
You may spend a fair amount of time iterating through your design when you have synthesis errors.
If you resolve synthesis errors, you should resimulate your design to make sure it is still working properly.

The synthesis process is very important and there is a lot of important information within the synthesis logs generated by Vivado.
You should get in the habit of reviewing this log to learn more about your implemented design.
In addition, you should look for any warnings and resolve all warnings before proceeding to implementation.
The synthesis tool may generate a number of warnings and you may need to downgrade some warning messages to info messages to get a clean synthesis.
This [summary](../resources/vivado_command_line.md#adjusting-message-severity-levels) describes how to add lines to your .xdc file to adjust the severity of messages generated by the synthesis tool.

<!--
Synthesize your design and create a bit file [see the tutorials for synthesis](https://byu-cpe.github.io/ecen320/tutorials/lab_03/07_synthesis/),
[implementation](https://byu-cpe.github.io/ecen320/tutorials/lab_03/08_implementation/), and
[bitgen](https://byu-cpe.github.io/ecen320/tutorials/lab_03/09_bitgen/).
-->

### Implementation and Bitstream generation

After generating a successful synthesis, the next step is to complete the implementation process.
This involves optimizing your design, placing your design into specific sites within the FPGA, performing routing, and generating a configuration bitstream.
These steps are performed by using the following Vivado commands:

```opt_design
place_design
route_design
write_bitstream -force tx.bit
```

The final step requires an argument with the filename of the bitstream you want to generate.
Like the synthesis step, there may be errors in this process that will require you to go back and make changes to your HDL code.

### Implementation Checkpoint and Logs

The state of your implemented design is held within the Vivado tool and this state is lost if you quit the tool.
It is often important to save the state of your implemented design so you can return to it later.
You can save the state of your design by using the [`write_checkpoint`](../resources/vivado_command_line.md#create-checkpoint) command.
You should generate a checkpoint file for every design you implement.

```write_checkpoint -force checkpoint_impl.dcp
```

Later, you can load the state of your design by using the [`read_checkpoint`](../resources/vivado_command_line.md#read-checkpoint) command.
```read_checkpoint
```

If you have successfully completed the implementation process, you will have a bitstream file that can be downloaded to the FPGA board.
Before downloading the bitstream, it is important to generate a number of reports to help you understand your design.
These reports will be required in all of your implementation assignments.
* **io**: A summary of the I/O ports used in your design
* **timing_summary**: A summary of your design timing, the timing constraints and violations in your design. We will be carefully reviewing this report in future assignments'
* **utilization**: A summary of the resources used in your design
* **drc**: A summary of the "design rule checks" for your design

Execute each of the following commands after implementation to generate these reports:
```report_io -file io.rpt
report_timing_summary -max_paths 10 -report_unconstrained -file timing_summary_routed.rpt -warn_on_violation
report_utilization -file utilization_impl.rpt
report_drc -file drc_routed.rpt
```


### Build Script

It is tedious to type all of these implementation commands in by hand every time you want to implement.
You can create a `.tcl` script that contains all of these commands and run this script to implement your design.
For this assignment, create a build `.tcl` script that contains all of the commands needed to synthesize and implement your design.
You can run your implementation script as a single command from the command line as follows:
`vivado -mode batch -source tx_synth.tcl -log tx_implement.log`





## Design Download

After successfully synthesizing your design and generating a bitfile, download your design to a Nexys4 DDR board and demonstrate it working correctly. 
Use the "Putty" tool to send characters from your board to the computer. 
There is a tutorial on [Putty](https://byu-cpe.github.io/ecen320/tutorials/other/01_putty_setup/) that can help you run this tool.
After generating a bitstream, download your bitstream and make sure your transmitter bitstream works with a terminal emulator.
You may want to view an [ASCII Table](https://commons.wikimedia.org/wiki/File:ASCII-Table-wide.svg) to test a variety of characters.

<!--
(didn't work for me)
screen /dev/ttyUSB2 115200,cs8,parenb,-parodd,-cstopb
-->
You will need to provide a makefile rule named `gen_bit` that generates a bitfile with the name `tx.bit` by running the makefile.
The following example demonstrates such a rule.
```
gen_bit:
  vivado -mode batch -source tx_synth.tcl
```
You will need to have a `.tcl` script that includes all the tcl commands needed to perform this step.
See the [instructions](../resources/vivado_command_line.md#synthesis-and-implementation) for details on what needs to be included in this script (also, make sure you commit this script to your repository).
Make sure you can properly create a bitstream using this makefile rule and that you test this bitfile on your own board.

You will also need a rule named `gen_bit_115200_even` that generates a different bitfile with the name `tx_115200_even.bit` that uses a baud rate of 115200 and even parity.


<!--
### Review Vivado Tools and Tutorials

You will need to use the AMD/Xilinx Vivado tools to synthesize your HDL designs.
It is your responsibility to learn how to use the Vivado tools. 
You can use the tools in the computers on the department digital laboratory or you can install them on your own computer. 
You are responsible for figuring out which tools to use. 
If you use your own computer, you are encouraged to use version 2021.2 (the same version in the digital lab).

We will be using these tools mostly in command-line mode.
However, you may find it useful to run the tools in the GUI while debugging your design.
There are a lot of tutorials you can follow from the [ECEN 320 class](https://byu-cpe.github.io/ecen320/) website. 
If you have not completed these tutorials in the past, you are encouraged to go through these so you are comfortable using the tool and creating Vivado projects. 
It is your responsibility to become familiar with the Vivado tools.

-->

<!--
### Create project script

Create a .tcl file named `create_project.tcl` that will create your project with all of the files needed to synthesize and generate a bitstream.
I will use this file to rebuild your project and verify that it works.
A sample file you can use as a start is as follows:

```
set nexys4_part "xc7a100tcsg324-1"

create_project -force uart_transmitter ./proj

# Set the part property for the project
set obj [get_projects uart_transmitter]
set_property "part" "$nexys4_part" $obj

# remove default simulation time
set_property -name {xsim.simulate.runtime} -value {0} -objects [get_filesets sim_1]
# Remove the INCREMENTAL property for the simulation
set_property INCREMENTAL false [get_filesets sim_1]
# Surpress the annoying synthesis warning: "cannot write xdc"
set_msg_config -suppress -id {Constraints 18-5210} 

# Synthesis files
add_files top.sv
add_files tx.sv
add_files -fileset constrs_1 -norecurse top.xdc
```
-->

## Common Problems

* Incorrectly set the terminal settings. In particularly, not setting "parity = odd". If you leave parity to none then you may get incorrect results.


## Submission and Grading

Once you have completed the assignment and verified that everything is working correctly, follow these steps to formally submit your assignment.

1. Prepare your repository
  * Make sure all the _essential_ files needed to complete your project are committed into your repository, that no _non-essential_ files are committed to your repository, and that you have a `.gitignore` file for your assignment directory and that all intermediate files are ignored.
  * Make sure you have a `makefile` with all the necessary make rules
    * `sim_top`:
    * `sim_top_115200_even`:
    * `gen_bit`: Generates a bitstream for your top-level design using the default parameters
    * `gen_bit_115200_even`: Generates a bitstream for your top-level design with a baud rate of 115200 and even parity
2. Commit and tag your repository
  * Make sure all of your files are committed and properly tagged
  * Make sure you follow the [Git repository standards](../resources/coding_standard.md#git-repository-standards)
3. Create your assignment [Readme.md](../resources/assignment_mechanics.md#assignment-submission) file
  * Create the template file based on the instructions linked above
  * Add the following items for the assignment-specific section of the readme:
    1. **Resoures**: Provide a summary of the number of resources your design uses (see the output from the utilization report). Specifically, indicate the number of `Slice LUTs`, `Slice Registers`, and `Bonded IOB` resources your design uses.
    2. **Warnings**: Provide a list of all the _synthesis_ warnings generated while sythesizing your design. You don't need to understand or remove them but I want to make sure you look at them and copy them. The warnings can be found in the implementation log during the synthesis step of Vivado.
    3. **Timing**: Determine the "Worst Negative Slack" (or WNS). This is found in the timing report and indicates how much timing you slack you have with the current clocking.



### Grading

I will follow these steps to grade this assignment:

1. Fetch and get tag
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
   * run `make sim_top`
   * run `make sim_top_115200_even`
   * run `make gen_bit`
   * run `make gen_bit_115200_even`
6. Download both bitfiles and make sure they both work
7. Check to see if there are any files that are generated during the build process but not ignored. I will run the following command:
`git ls-files . --exclude-standard --others`. <br>If there are any files not ignored after running the above make commands then you will lose points.
8. run `make clean`
I will clean the directory where I ran your commands to make sure the clean works properly. 
I will check to see if your `make clean` cleaned all the ignore files: `git check-ignore *` <br>
If there are any files that remain that are not cleaned by the `make clean` then you will lose some points.
7. Review the number of commits and the commit messages to your assignment directory **TODO: (list the command I am going to run)**
10. Review your Readme.md to see if it has all the requirements
11. Review your code for compliance to the coding standards

check for implementation reports