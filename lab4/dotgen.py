from sys import argv
import re
state_pattern = " *STATE_([A-Z])*:"
goto_pattern = " *@goto *([A-Z])* *"
fin = argv[1]
fout = open(argv[1], "w")

def inter(s):
    return s.format(**sys._getframe(1).f_locals)

states = dict()
cur_state = ""
for line in open(fin):
    gr_state = re.match(state_pattern, line)
    gr_goto = re.match(goto_pattern, line)

    if gr_state != None:
        cur_state = gr_state[1]
        states[cur_state] = []
    elif gr_goto != None:
        states[cur_state] += gr_goto[1]

fout.write("graph G {\n")
for name, state in states:
    for gt in state:
        fout.write(inter("\t{name} -> {gt};\n"))
fout.write("}\n")
