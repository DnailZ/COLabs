
struct_dict = dict()
current_struct = ""
acc = 0
reg_list2 = []


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
 

def pstruct(A):
    global current_struct
    struct_dict[A] = (A, 0, [])
    current_struct = A
    wr("// {A}'s structure")
    acc = 0

def e(A, T="", comment=""):
    global current_struct
    if len(comment) > 3:
        comment = comment[2:]
    T = int(T) if T != "" else 1
    struct_dict[current_struct][2].append((A, T, comment))
    wr("//   {current_struct}_{A} - {T} {comment}")
    acc += T


def endpstruct():
    global current_struct
    nameu = current_struct.upper()
    rep[current_struct] = inter("[{nameu}_W-1:0]")

def defparam_pstruct(A):
    cur = struct_dict[A][0]
    len = struct_dict[A][1]
    wr("parameter {cur}_W = {len};")

def decompose(A, B, comment=""):
    construct(A, B)
    l = comp(A, B)
    wr("assign {l} = {B};{comment}")

def construct(A, B):
    (cur, len, L) = struct_dict[A]
    for entry in L:
        (N, T, _) = entry
        u = T - 1
        if N in reg_list2:
            wr("reg [{u}:0] {B}_{N};")
        wr("wire [{u}:0] {B}_{N};")

def comp(A, B):
    l = ""
    (cur, len, L) = struct_dict[A]
    for entry in L:
        (N, T, _) = entry
        l += " {B}_{N},"
    l = "{" + l[:-1] + "}"
    return l

def compose_always(A, B):
    l = comp(A, B)
    wr("{B} = {l}")

def compose_assign(A, B):
    l = comp(A, B)
    wr("assign {B} = {l}")

def pr_entry(entry, V, end=","):
    (N, T, _) = entry
    if N in V:
        if is_number(V[N]):
            wr("\t{T}'h" + hex(int(V[N]))[2:] + "{end} // {N}")
        else:
            wr("\t" + V[N] + "{end} // {N}")
    else:
        wr("\t {T}'" + 'x'*T + "{end} // {N}")

def pr_entry2(entry, V, end=","):
    (N, T, _) = entry
    if is_number(V):
        wr("\t{T}'h" + hex(int(V))[2:] + "{end} // {N}")
    else:
        wr("\t" + V + "{end} // {N}")

def value(A, B, V):
    (cur, length, L) = struct_dict[A]
    if V == 0:
        wr("{B} = 0")
    elif V == 'x':
        wr("{B} = {length}'" + 'x'*len)
    elif type(V) == dict:
        wr("{B} = {")
        for entry in L:
            pr_entry(entry ,V)
        pr_entry(L[-1] , V, end="")
        wr("}")
    elif type(V) == list:
        wr("{B} = {")
        for entry, v in zip(L,V):
            pr_entry2(entry,v)
        pr_entry2(L[-1],V[-1], end="")
        wr("}")

def value_virtual(A, B, V):
    value(A, comp(A,B), V)
        





