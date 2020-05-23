import re
from os import listdir
from os.path import isfile, join, dirname, isdir
import pathlib
from pathlib import Path
from sys import argv
import sys

def zip_with_end(*args):
    f = args[0]
    n = len(f)
    ending = [False] * (n-1) + [True]
    return zip(*args, ending)

def openf(f, m):
    if not isdir(dirname(f)):
        Path(dirname(f)).mkdir(parents=True, exist_ok=True)
    return open(f,m)

def inter(s):
    return s.format(**sys._getframe(1).f_locals)


rep = dict()
fin = None
fout = None
spaces = ""

def _():
    pass

def wr(str):
    str = str.format(**sys._getframe(1).f_locals)
    for line in str.split("\n"):
        fout.write(spaces + line + "\n")
def inter(s):
    return s.format(**sys._getframe(1).f_locals)


def generate(fin0, fout0):
    global fin, fout, spaces, rep
    fin = open(fin0, 'r')
    fout = openf(fout0, 'w')

    mode = "verilog"
    code_acc = ""
    spaces = ""
    for line in fin:
        line = line[:-1] if len(line) >= 1 else line
        words = re.split(r"([ ,;])", line)
        for i, w in enumerate(words):
            if w in rep:
                words[i] = rep[w]
        line = "".join(words) + "\n"

        if line == "@py\n":
            mode = "python"
        elif line == '@end\n':
            if mode == "python":
                mode = "verilog"
                exec(code_acc)
            elif mode == "str":
                mode = "verilog"
        elif re.match(r"( *)@([^{].*)",line):
            comment = None
            if "//" in line:
                cmt_pos = line.index("//")
                comment = line[cmt_pos:-1]
                line = line[:cmt_pos]
            m = re.match(r"( *)@(.*)",line)
            spaces = m[1]
            words = [""]
            s = m[2] + " "
            level = 0
            for s in m[2]:
                if level == 0 and s == "," or s == ";":
                    words += [s]
                    continue
                if level == 0 and (s ==" " or s == "\t"):
                    if words[-1] != "":
                        words += [""]
                    continue
                if s == "(" or s =="[" or s =="{":
                    level += 1
                elif s == ")" or s == "]" or s =="}":
                    level -= 1
                words[-1] += s
            if words[-1] == "":
                words.pop()
            if len(words) >= 1:
                code = words[0] + "(" + ",".join(map(lambda s : "\"" + s.replace('"', '\\"') + "\"", words[1:])) + \
                    ((",comment=\"" + comment.replace('"', '\\"') + "\"") if comment else "" ) +  \
                ")"
                exec(code)
                try:
                    pass
                except:
                    print(code)
                    quit(0)
        else:
            if mode == "python" or mode == "str":
                code_acc += line
            elif mode == "verilog":
                part = re.split("@{", line)
                if len(part) > 1:
                    line = part[0]
                    for e in part[1:]:
                        spl = e.split("}@")
                        if len(spl) != 2:
                            print(spl)
                        [expr, post] = spl
                        line += str(eval(expr))
                        line += post
                
                fout.write(line)
    
    fin.close()
    fout.close()


src_name = 'src'
module_name = argv[1]
verilog_name = argv[2]
source_path = join(src_name,module_name)
target_path = join(src_name,verilog_name)

for path in ['module.py', "struct.py", "venum.py"]:
    fin = str(path)
    print(fin)
    exec(open(fin, 'r').read())
for path in Path(source_path).rglob('*.py'):
    fin = str(path)
    print(fin)
    exec(open(fin, 'r').read())

for path in open(join(source_path, "mari.info")):
    if re.match(" *(.*)",path):
        path = re.match(" *(.*)",path)[1]
        path = join(source_path, path)
        fin = str(path)
        print(fin)
        fout = fin.replace(source_path, target_path)
        generate(fin, fout)

