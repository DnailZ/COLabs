rep["Word"] = "[WIDTH-1:0]"
rep["RegId"] = "[REGFILE_WIDTH-1:0]"
rep["ALUop"] = "[ALUOP_W-1:0]"
rep["Addr"] = "[MEM_ADDR_WIDTH-1:0]"

module_dict = dict()
current_module = ""

def module(A):
    print(A)
    global current_module
    current_module = A
    module_dict[A] = ([], [], [])
    wr("module {A}")

def input(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        T = ""
        end = "," 
    module_dict[current_module][1].append((A, T, "in"))
    wr("input {T} {A}{end} {comment}")

def ninput(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        T = ""
        end = ","
    module_dict[current_module][2].append((A, T, "in"))
    wr("input {T} {A}{end} {comment}")

def Input(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][0].append((A, T, "in"))
    wr("input {T} {A}{end} {comment}")

def input(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][1].append((A, T, "in"))
    wr("input {T} {A}{end} {comment}")

def output(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][1].append((A, T, "out"))
    wr("output {T} {A}{end} {comment}")

def outputr(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][1].append((A, T, "out"))
    wr("output reg {T} {A}{end} {comment}")

def noutput(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][2].append((A, T, "out"))
    wr("output {T} {A}{end} {comment}")

def noutputr(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][2].append((A, T, "out"))
    wr("output reg {T} {A}{end} {comment}")

reg_list = []
def reglize(A):
    global reg_list

    reg_list += [A]

def impl(A, name, l, arg="", comment=""):
    global reg_list
    l = eval(l)
    cin = module_dict[A][0]
    nio = module_dict[A][2]
    out = module_dict[A][1]
    for o in out:
        if o[0] in reg_list:
            wr("reg {o[1]} {name}_{o[0]};")
        else:
            wr("wire {o[1]} {name}_{o[0]};")
    wr("{A}{arg} {name} (")
    for n in nio:
        wr("\t.{n[0]}({n[0]}),")
    for c, p in zip(cin, l[:len(cin)]):
        wr("\t.{c[0]}({p}),")
    if len(out) >= 1:
        for o in out[:-1]:
            wr("\t.{o[0]}({name}_{o[0]}),")
        o = out[-1]
        wr("\t.{o[0]}({name}_{o[0]})")
    wr(");")
    reg_list = []

def inst(A, name, l, arg="", comment=""):
    global reg_list
    l = eval(l)
    cin = module_dict[A][0]
    nio = module_dict[A][2]
    out = module_dict[A][1]
    for o in out:
        if name + "_" + o[0] in reg_list:
            wr("reg {o[1]} {name}_{o[0]};")
        else:
            wr("wire {o[1]} {name}_{o[0]};")
    wr("{A}{arg} {name}_inst (")
    for n in nio:
        wr("\t.{n[0]}({n[0]}),")
    for c, p in zip(cin, l[:len(cin)]):
        wr("\t.{c[0]}({p}),")
    if len(out) >= 1:
        for o in out[:-1]:
            wr("\t.{o[0]}({name}_{o[0]}),")
        o = out[-1]
        wr("\t.{o[0]}({name}_{o[0]})")
    wr(");")
    reg_list = []


    

