
functs = dict()
instructions = dict()

def defparam(end="", comment=""):
    defparam_struct("Signal_t")
    wr("""parameter REG_W = 5,
parameter WIDTH = 32,
parameter FUNCT_W = 6,
parameter OPCODE_W = 6,
parameter ALUOP_W = 3{end}""")
rep["[Opcode]"] = "[31:26]"
rep["[Funct]"] = "[5:0]"
rep["[Imm]"] = "[15:0]"
rep["[Rs]"] = "[25:21]"
rep["[Rt]"] = "[20:16]"
rep["[Rd]"] = "[15:11]"
rep["[Addr]"] = "[25:0]"
rep["[Shamt]"] = "[10:6]"
rep["Opcode"] = "[OPCODE_W-1:0]"
rep["Word"] = "[WIDTH-1:0]"
rep["RegId"] = "[REG_W-1:0]"
rep["ALUop"] = "[ALUOP_W-1:0]"
rep["Funct"] = "[FUNCT_W-1:0]"
rep["Addr"] = "[MEM_ADDR_WIDTH-1:0]"