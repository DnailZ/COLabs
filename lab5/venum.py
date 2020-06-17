enum_dict = dict()

class VEnum:

    def __init__(self,name):
        self.name = name
        self.L = []
        self.width = -1
        pass
    def __getitem__(self,name):
        i = self.L.index(name)
        return inter("{width}'d{i}")
cur_enum = None

def venum(name):
    global cur_enum
    enum_dict[name + "_t"] = VEnum(name)
    cur_enum = enum_dict[name + "_t"]
    print(enum_dict)

def tag(n):
    global cur_enum
    cur_enum.L.append(n)

def localparam(name, value, end=""):
    wr("localparam {name} = {value};")

def parameter(name, value, end=","):
    if end == None:
        end = ","
    wr("parameter {name} = {value}{end}")

def endenum():
    defenum(cur_enum.name + "_t","localparam", "")
def defenum(type, define = "localparam", end=""):
    define = eval(define)
    global cur_enum
    import math
    cur_enum = enum_dict[type]
    cur_enum.width = math.ceil(math.log2(len(cur_enum.L)))
    width = cur_enum.width
    name = cur_enum.name.upper() + "_W"
    define(name, width, "")
    rep[cur_enum.name] = inter("[{name}-1:0]")
    for (i, e), endf in zip_with_end(list(enumerate(cur_enum.L))):
        name = cur_enum.name.upper() + "_" + e.upper()
        value = inter("{width}'d{i}")
        end_sym = end if endf else None
        define(name, value, end_sym)

def enum_getname(type, wire, str, eq="="):
    cur_enum = enum_dict[type]
    wr("case({wire})")
    for i, e in enumerate(cur_enum.L):
        name = cur_enum.name.upper() + "_" + e.upper()
        eu = e.upper()
        if i == 4:
            wr("/// doc_omit begin")
        wr("{name}: {str} {eq} \"{eu}\";")
    wr("    /// doc_omit end")
    wr("endcase")