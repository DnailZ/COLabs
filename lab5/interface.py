
intf_dict = dict()
def intf(name):
    global current_struct, acc
    struct_dict[A + "_t"] = (A + "_t", 0, [])
    current_struct = A + "_t"
    wr("// {A}'s structure")
    acc = 0