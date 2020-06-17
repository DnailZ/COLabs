
class TempReg:
    def __init__(self, regname, ty, value):
        self.regname = regname
        self.ty = ty
        self.value = value
    def reset(self):
        wr(f"{self.regname} <= 0;")
    def set(self):
        wr(f"{self.regname} <= {self.value};")

class TempStruct:
    def __init__(self, regname, ty, value):
        self.regname = regname
        self.ty = ty
        self.value = value
    def reset(self):
        vlet_no_beginend(self.ty, self.regname, "dict()", eq="<=")
    def set(self):
        vlet_no_beginend(self.ty, self.regname, self.value, eq="<=")

tempreg_l = []

def always_for_regs(cond="None", rstcond="rst"):
    global spaces, tempreg_l
    wr("always @(posedge clk) begin //{{")
    spaces += " " * 4
    if rstcond != "None":
        wr(f"if({rstcond}) begin")
        spaces += " " * 4
        for reg in tempreg_l:
            reg.reset()
        spaces = spaces[:-4]
        wr("end")
    if_stat = "" if cond == "None" else f"if ({cond})"
    wr(f"else {if_stat} begin")
    print("Asdf")
    spaces += " " * 4
    for reg in tempreg_l:
        reg.set()
    spaces = spaces[:-4]
    wr("end")
    spaces = spaces[:-4]
    wr("end //}}")
    tempreg_l = []

def regnext(regname, ty, value=None, comment=""):
    if value == None:
        value = ty
        ty = ""
    if ty[-2:] == "_t":
        regstruct(regname, ty, value, comment)
        return
    wr(f"reg {ty} {regname};")
    tempreg_l.append(TempReg(regname, ty, value))

def regstruct(regname, ty, value, comment=""):
    construct(ty, regname, "reg")
    tempreg_l.append(TempStruct(regname, ty, value))
    