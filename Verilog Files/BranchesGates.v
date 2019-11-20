/*
Este es el modulo con proposito del selector del multiplexor del Branch
comparando las señales de la unidad de control BEQ y BNE con respecto al zero de la ALU
*/
module BranchesGates
(
	input Branch,
	input Branch_Not_Equal,
	input zero,
	output reg PCSrc
);

always@(*)

	PCSrc = (Branch & zero)|(Branch_Not_Equal & (~zero));

endmodule