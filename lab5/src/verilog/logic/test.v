
// signals's structure
// -  reg_dst (1) 
// -  jump (1) 
// -  branch (1) 
// -  mem_read (1) 
// -  mem_to_reg (1) 
// -  mem_write (1) 
// -  aluop (4) 
// -  alusrc_1 (1) 
// -  alusrc_2 (1) 
// -  reg_write (1) 

parameter SIGNALS_T_W = 0,

wire sgn_reg_dst;
wire sgn_jump;
wire sgn_branch;
wire sgn_mem_read;
wire sgn_mem_to_reg;
wire sgn_mem_write;
wire [3:0] sgn_aluop;
wire sgn_alusrc_1;
wire sgn_alusrc_2;
wire sgn_reg_write;
assign { sgn_reg_dst, sgn_jump, sgn_branch, sgn_mem_read, sgn_mem_to_reg, sgn_mem_write, sgn_aluop, sgn_alusrc_1, sgn_alusrc_2, sgn_reg_write} = sgn;


 sgn = {
	3'b001, // reg_dst
	1'x, // jump
	1'x, // branch
	1'x, // mem_read
	1'x, // mem_to_reg
	1'x, // mem_write
	4'xxxx, // aluop
	1'x, // alusrc_1
	1'x, // alusrc_2
	1'x, // reg_write
	1'x // reg_write
}

