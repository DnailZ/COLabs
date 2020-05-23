from sys import argv
import sys
import re
state_pattern = r" *STATE_([A-Z_]*):"
goto_pattern = r" *@goto ([A-Z_]*) *"
fin = argv[1]
fout = open(argv[2], "w")

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
        states[cur_state] += [gr_goto[1]]

fout.write("digraph G {\n")
for name in states:
    state = states[name]
    for gt in state:
        fout.write(inter("\t{name} -> {gt};\n"))
fout.write("}\n")
