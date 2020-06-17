
module_dict = dict()
intf_dict = dict()
current_module = ""
reg_list = []

def module(A):
    print(A)
    global current_module
    current_module = A
    module_dict[A] = ([], [], [])
    wr("module {A}")
    reg_list = []

# def input(A,T="",end="", comment=""):
#     global current_module, intf_dict
#     if T == ",":
#         T = ""
#         end = "," 
#     module_dict[current_module][1].append((A, T, "in"))
#     intf_dict[current_module] = ("input", A, T, end, comment)
#     wr("input {T} {A}{end} {comment}")

def ninput(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        T = ""
        end = ","
    module_dict[current_module][2].append((A, T, "in"))
    intf_dict[current_module] = ("ninput", A, T, end, comment)
    wr("input {T} {A}{end} {comment}")

def Input(A,T="",end="", comment=""):
    global current_module, intf_dict
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][0].append((A, T, "in"))
    intf_dict[current_module] = ("Input", A, T, end, comment)
    wr("input {T} {A}{end} {comment}")

def input(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][1].append((A, T, "in"))
    intf_dict[current_module] = ("input", A, T, end, comment)
    wr("input {T} {A}{end} {comment}")

def output(A,T="",end="", comment=""):
    global current_module, reg_list
    if A in reg_list:
        outputr(A, T, end, comment)
        return
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][1].append((A, T, "out"))
    intf_dict[current_module] = ("output", A, T, end, comment)
    wr("output {T} {A}{end} {comment}")

def outputr(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][1].append((A, T, "out"))
    intf_dict[current_module] = ("outputr", A, T, end, comment)
    wr("output reg {T} {A}{end} {comment}")

def Output(A,T="",end="", comment=""):
    global current_module, reg_list
    if A in reg_list:
        outputr(A, T, end, comment)
        return
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][0].append((A, T, "out"))
    intf_dict[current_module] = ("output", A, T, end, comment)
    wr("output {T} {A}{end} {comment}")

def Outputr(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][0].append((A, T, "out"))
    intf_dict[current_module] = ("outputr", A, T, end, comment)
    wr("output reg {T} {A}{end} {comment}")

def noutput(A,T="",end="", comment=""):
    global current_module, reg_list
    if A in reg_list:
        noutputr(A, T, end, comment)
        return
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][2].append((A, T, "out"))
    intf_dict[current_module] = ("noutput", A, T, end, comment)
    wr("output {T} {A}{end} {comment}")

def noutputr(A,T="",end="", comment=""):
    global current_module
    if T == ",":
        end = ","
        T = ""
    module_dict[current_module][2].append((A, T, "out"))
    intf_dict[current_module] = ("noutputr", A, T, end, comment)
    wr("output reg {T} {A}{end} {comment}")

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
    wr("{comment}")
    wr("{A}{arg} {name} (")
    for n in nio:
        wr("\t.{n[0]}({n[0]}),")
    for c, p, end in zip_with_end(cin, l[:len(cin)]):
        end = end and len(out) == 0
        end = "" if end else ","
        wr("\t.{c[0]}({p}){end}")
    if len(out) >= 1:
        for o in out[:-1]:
            wr("\t.{o[0]}({name}_{o[0]}),")
        o = out[-1]
        wr("\t.{o[0]}({name}_{o[0]})")
    wr(");")
    reg_list = []

# inst name will add a _inst postfix
def inst(A, name, l, subname="", arg="", comment=""):
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
    wr("{A}{arg} {name}_inst{subname} (")
    for n in nio:
        wr("\t.{n[0]}({n[0]}),")
    for c, p, end in zip_with_end(cin, l[:len(cin)]):
        end = end and len(out) == 0
        end = "" if end else ","
        wr("\t.{c[0]}({p}){end}")
    if len(out) >= 1:
        for o in out[:-1]:
            wr("\t.{o[0]}({name}_{o[0]}),")
        o = out[-1]
        wr("\t.{o[0]}({name}_{o[0]})")
    wr(");")
    reg_list = []


    

