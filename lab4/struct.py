
struct_dict = dict()
comment_dict = dict()
current_struct = ""
acc = 0
reg_list2 = []

cur_dict = dict()
cur_dict_name = ""

class dictgen:
    def __init__(self,name):
        self.name = name
    def __getitem__(self, str):
        if self.name == "":
            return str
        else:
            return self.name + "_" + str
    def __contains__(self, elem):
        return True

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        pass
    try:
        import unicodedata
        unicodedata.numeric(s)
        return True
    except (TypeError, ValueError):
        pass
    return False
 

def struct(A):
    global current_struct, acc
    struct_dict[A + "_t"] = (A + "_t", 0, [])
    comment_dict[A + "_t"] = []
    current_struct = A + "_t"
    wr("// {A}'s structure")
    acc = 0

def e(A, T="", comment=""):
    global current_struct, acc
    if len(comment) > 3:
        comment = ":" + comment[2:]
    default = "0"
    if "/" in T:
        default = T.split("/")[1]
        T = T.split("/")[0]
    T = int(T) if T != "" else 1
    if default == "x":
        default = inter("{T}'b" + "x"*T)
    if default == "0":
        default = inter("{T}'b" + "0"*T)
    add_element(A, T, default, comment)
    comment_dict[current_struct] += [comment]

def add_element(name, type, default, comment=""):
    global current_struct, acc
    struct_dict[current_struct][2].append((name, type, default))
    wr("// -  {name} ({type}) {comment}")
    acc += type

def extends(A, comment=""):
    struct_comment = comment[2:] if len(comment)>2 else ""
    comment_list = comment_dict[A]
    for entry, comment in zip(struct_dict[A][2], comment_list):
        name, type, default = entry
        add_element(name, type, default, comment + struct_comment)


def endstruct():
    global current_struct, acc
    (A,_,C) = struct_dict[current_struct]
    struct_dict[current_struct] = (A, acc, C)
    nameu = current_struct.upper()[:-2]
    rep[current_struct[:-2]] = inter("[{nameu}_W-1:0]")
    rep[current_struct[:-2] + ".W"] = str(acc)
    l = acc - 1
    rep[current_struct[:-2] + ".T"] = inter("[{l}:0]")

def defparam_struct(A):
    cur = struct_dict[A][0]
    len = struct_dict[A][1]
    print("ASfd", len)
    nameu = cur.upper()[:-2]
    wr("parameter {nameu}_W = {len},")

def decompose(A, B, comment=""):
    construct(A, B)
    l = comp(A, B)
    wr("assign {l} = {B};{comment}")

def construct(A, B, r_or_w="wire"):
    (cur, len, L) = struct_dict[A]
    for entry in L:
        (N, T, _) = entry
        u = T - 1
        if N in reg_list2:
            if T == 1:
                wr("reg {B}_{N};")
            else:
                wr("reg [{u}:0] {B}_{N};")
        if T == 1:
            wr("{r_or_w} {B}_{N};")
        else:
            wr("{r_or_w} [{u}:0] {B}_{N};")

def construct_io(io_func, type, name, end="", reg=" "):
    (cur, len, L) = struct_dict[type]
    io_func = eval(io_func)
    for entry, endf in zip_with_end(L):
        (elem_name, width, _) = entry
        end_sym = end if endf else ","
        width_s1 = width -1
        if name != "":
            elem_name = inter("{name}_{elem_name}")
        io_func(elem_name,
            inter("[{width_s1}:0]") if width_s1 > 0 else "", end_sym)


def comp(A, B):
    l = ""
    (cur, len, L) = struct_dict[A]
    for entry in L:
        (N, T, _) = entry
        l += inter(" {B}_{N},")
    l = "{" + l[:-1] + "}"
    return l

def compose_always(A, B):
    l = comp(A, B)
    wr("{B} = {l};")

def compose_assign(A, B):
    l = comp(A, B)
    wr("assign {B} = {l};")

def pr_entry(entry, V, end=",", eq="=", var = None):
    (N, T, default) = entry
    if var != None:
        if var == "":
            var = inter("{N} {eq} ")
        else:
            var = inter("{var}_{N} {eq} ")
    else:
        var = ""
    if N in V:
        if is_number(V[N]):
            wr("    {var}{T}'h" + hex(int(V[N]))[2:] + "{end} //| {N}")
        else:
            wr("    {var}" + V[N] + "{end} //| {N}")
    else:
        wr("    {var}{default}{end} //| {N} (by default)")


def pr_entry2(entry, V, end=",", eq="=", var=None):
    (N, T, _) = entry
    if var != None:
        if var == "":
            var = inter("{N} {eq} ")
        else:
            var = inter("{var}_{N} {eq} ")
    else:
        var = ""
    if is_number(V):
        wr("    {var}{T}'h" + hex(int(V))[2:] + "{end} //| {N}")
    else:
        wr("    {var}" + V + "{end} //| {N}")

def slet(A, B, V, eq="=", prefix="", comment=""):
    (cur, length, L) = struct_dict[A]
    if V == "0":
        wr("{prefix} {B} {eq} 0")
        return
    elif V == 'x':
        wr("{prefix} {B} {eq} {length}'" + 'x'*len)
        return
    elif V[0] == "-":
        l = comp(A, V[1:])
        return
    V = eval(V)
    print(V)
    if type(V) == dict:
        wr("{prefix} {B} {eq} {{ //[")
        for entry in L[:-1]:
            pr_entry(entry ,V)
        pr_entry(L[-1] , V, end="")
        wr("}}; //]")
    elif type(V) == list:
        wr("{prefix} {B} {eq} {{ //[")
        for entry, v in zip(L[:-1],V):
            print(entry, v)
            pr_entry2(entry,v)
        pr_entry2(L[-1],V[-1], end="")
        wr("}}; //]")

def vlet(A, B, V, eq="=", prefix="", comment=""):
    (cur, length, L) = struct_dict[A]
    V = eval(V)
    if type(V) == dict or type(V) == dictgen:
        wr("{prefix}begin //[")
        for entry in L:
            pr_entry(entry ,V, var=B, eq=eq, end=";")
        wr("end //]")
    elif type(V) == list:
        wr("{prefix}begin //[")
        for entry, v in zip(L,V):
            pr_entry2(entry, v, var=B, eq=eq, end=";")
        wr("end //]")

def slet_b(A, B, V, prefix="", comment=""):
    slet(A, B, V, eq="<=", prefix=prefix, comment=comment)

def a_slet(A, B, V, comment=""):
    slet(A, B, V, eq="=", prefix="assign", comment=comment)

def slet_vir(A, B, V, eq="=", prefix="", comment=""):
    slet(A, comp(A,B), V, eq=eq, prefix="", comment="")

def slet_b_vir(A, B, V, prefix="", comment=""):
    slet_vir(A, B, V, eq="<=", prefix=prefix, comment=comment)

def a_slet_vir(A, B, V, comment=""):
    slet_vir(A, B, V, eq="=", prefix="assign", comment=comment)

def value_virtual(A, B, V):
    value(A, comp(A,B), V)

def defdict(A):
    global cur_dict_name
    cur_dict_name = A + "_t"
    cur_dict[cur_dict_name] = dict()

def dt(k, v):
    if is_number(v):
        cur_dict[cur_dict_name][k] = int(v)
    else:
        cur_dict[cur_dict_name][k] = v

def enddict():
    global cur_dict_name
    name = cur_dict_name
    rep[cur_dict_name[:-2]] = inter("cur_dict[\'{name}\']")

def sintf():
    pass
