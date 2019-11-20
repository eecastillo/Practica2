/******************************************************************
* Description
*	This is the top-level of a MIPS processor that can execute the next set of instructions:
*		add
*		addi
*		sub
*		ori
*		or
*		and
*		nor
* This processor is written Verilog-HDL. Also, it is synthesizable into hardware.
* Parameter MEMORY_DEPTH configures the program memory to allocate the program to
* be execute. If the size of the program changes, thus, MEMORY_DEPTH must change.
* This processor was made for computer architecture class at ITESO.
* Version:
*	1.5
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	2/09/2018
******************************************************************/


module MIPS_Processor
#(
	parameter MEMORY_DEPTH = 64,
	parameter PC_INCREMENT = 4,
	parameter jump_start   = 32'b11_1111_1111_0000_0000_0000_0000_0000_00,
	parameter RA = 31
	//parameter RAM_INCREMENT =
)

(
	// Inputs
	input clk,
	input reset,
	input [7:0] PortIn,
	// Output
	output [31:0] ALUResultOut,
	output [31:0] PortOut
);
//******************************************************************/
//******************************************************************/
assign  PortOut = 0;

//******************************************************************/
//******************************************************************/
// signals to connect modules
wire branch_ne_wire;
wire branch_eq_wire;
wire reg_dst_wire;
wire not_zero_and_brach_ne;
wire zero_and_brach_eq;
wire or_for_branch;
wire alu_src_wire;
wire reg_write_wire;
wire zero_wire;
wire wMemWrite;
wire wMemRead;

wire wJump;
wire wJump_R;
wire wJAL;
wire Branch_Analyzer_Result_wire;

wire [2:0] aluop_wire;
wire [3:0] alu_operation_wire;
wire [4:0] write_register_wire;
wire [4:0] jal2_result;
wire [31:0] mux_pc_wire;
wire [31:0] jal_result;
wire [31:0] pc_wire;
wire [31:0] instruction_bus_wire;
wire [31:0] read_data_1_wire;
wire [31:0] read_data_2_wire;
wire [31:0] Inmmediate_extend_wire;
wire [31:0] read_data_2_orr_inmmediate_wire;
wire [31:0] alu_result_wire;
wire [31:0] pc_plus_4_wire;
wire [31:0] inmmediate_extended_wire;
wire [31:0] pc_to_branch_wire;

wire [31:0] wReadData;
wire [31:0] wMemtoReg;
wire [31:0] wRamAluMux;

wire [31:0] wBranchAdder;
wire [31:0] PC_Puls_ShiftLeft_RESULT;
wire [31:0] MUX_ForPCSource_RESULT;
wire [31:0] PC_R;
wire [31:0] New_PC;
wire [27:0] Shift_wire;
wire [31:0] offset_Start;


//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Control
ControlUnit
(
	.OP(instruction_bus_wire[31:26]),
	.FUN(instruction_bus_wire[5:0]),
	.RegDst(reg_dst_wire),
	.BranchNE(branch_ne_wire),
	.BranchEQ(branch_eq_wire),
	.ALUOp(aluop_wire),
	.ALUSrc(alu_src_wire),
	.RegWrite(reg_write_wire),
	.MemWrite(wMemWrite),
	.MemRead(wMemRead),
	.MemtoReg(wMemtoReg),
	.Jump(wJump),
	.Jump_R(wJump_R),
	.JAL(wJAL)
);


PC_Register
ProgramCounter
(
	.clk(clk),
	.reset(reset),
	.NewPC(PC_R),
	.PCValue(pc_wire)
);










ProgramMemory
#(
	.MEMORY_DEPTH(MEMORY_DEPTH)
)
ROMProgramMemory
(
	.Address(pc_wire),
	.Instruction(instruction_bus_wire)
);

Adder32bits
PC_Puls_4
(
	.Data0(pc_wire),
	.Data1(PC_INCREMENT),
	
	.Result(pc_plus_4_wire)
);


//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForBranch
(
	.Selector(Branch_Analyzer_Result_wire),
	.MUX_Data0(pc_plus_4_wire),
	.MUX_Data1(PC_Puls_ShiftLeft_RESULT),
	
	.MUX_Output(MUX_ForPCSource_RESULT)
);
ShiftLeft2
ShiftLeft2_Branch(
	.DataInput(Inmmediate_extend_wire),
	.DataOutput(wBranchAdder)
);

Adder32bits
PC_Plus_ShiftLeft
(
	.Data0(pc_plus_4_wire),
	.Data1(wBranchAdder),
	
	.Result(PC_Puls_ShiftLeft_RESULT)
);

Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForJump
(
	.Selector(wJump),
	.MUX_Data0(MUX_ForPCSource_RESULT),
	.MUX_Data1(offset_Start),
	
	.MUX_Output(New_PC)
);
BranchesGates
BranchAnalyzer(
	.Branch(branch_eq_wire),
	.Branch_Not_Equal(branch_ne_wire),
	.zero(zero_wire),
	.PCSrc(Branch_Analyzer_Result_wire)
);

Adder32bits
ADD_ALU_OFFSET
(
	.Data0({pc_plus_4_wire[31:28],Shift_wire[27:0]}),
	.Data1(jump_start),
	.Result(offset_Start)
	
);
ShiftLeft2
ShiftLeft
(
	.DataInput(instruction_bus_wire[25:0]),
	.DataOutput(Shift_wire)
);
//******************************************************************/
//******************************************************************/
//******************************************************************/
Multiplexer2to1
#(
	.NBits(5)
)
MUX_ForRTypeAndIType
(
	.Selector(reg_dst_wire),
	.MUX_Data0(instruction_bus_wire[20:16]),
	.MUX_Data1(instruction_bus_wire[15:11]),
	
	.MUX_Output(write_register_wire)

);



RegisterFile
Register_File
(
	.clk(clk),
	.reset(reset),
	.RegWrite(reg_write_wire),
	.WriteRegister(jal2_result),
	.ReadRegister1(instruction_bus_wire[25:21]),
	.ReadRegister2(instruction_bus_wire[20:16]),
	.WriteData(jal_result),
	.ReadData1(read_data_1_wire),
	.ReadData2(read_data_2_wire)

);

SignExtend
SignExtendForConstants
(   
	.DataInput(instruction_bus_wire[15:0]),
   .SignExtendOutput(Inmmediate_extend_wire)
);


DataMemory
#(	.DATA_WIDTH(32),
	.MEMORY_DEPTH(256)
)
RamMemory
(
	.WriteData(read_data_2_wire),
	.Address(alu_result_wire),
	.MemWrite(wMemWrite),
	.MemRead(wMemRead),
	.clk(clk),
	.ReadData(wReadData)
);

Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForAluAndRamMemory
(
	.Selector(wMemtoReg),
	.MUX_Data0(alu_result_wire),
	.MUX_Data1(wReadData),
	.MUX_Output(wRamAluMux)
);

Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(alu_src_wire),
	.MUX_Data0(read_data_2_wire),
	.MUX_Data1(Inmmediate_extend_wire),
	
	.MUX_Output(read_data_2_orr_inmmediate_wire)

);


ALUControl
ArithmeticLogicUnitControl
(
	.ALUOp(aluop_wire),
	.ALUFunction(instruction_bus_wire[5:0]),
	.ALUOperation(alu_operation_wire)

);



ALU
ArithmeticLogicUnit 
(
	.shamt(instruction_bus_wire[10:6]),
	.ALUOperation(alu_operation_wire),
	.A(read_data_1_wire),
	.B(read_data_2_orr_inmmediate_wire),
	.Zero(zero_wire),
	.ALUResult(alu_result_wire)
);


Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForJump_R
(
	.Selector(wJump_R),
	.MUX_Data0(New_PC),
	.MUX_Data1(read_data_1_wire),
	
	.MUX_Output(PC_R)
);

Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForJAL
(
	.Selector(wJAL),
	.MUX_Data0(wRamAluMux),
	.MUX_Data1(pc_plus_4_wire),
	
	.MUX_Output(jal_result)
);

Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForJAL_2
(
	.Selector(wJAL),
	.MUX_Data0(write_register_wire),
	.MUX_Data1(RA),
	
	.MUX_Output(jal2_result)
);
assign ALUResultOut = alu_result_wire;


endmodule

