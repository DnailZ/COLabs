import re
from os import listdir
from os.path import isfile, join, dirname, isdir
import pathlib
from pathlib import Path
from sys import argv

def generate(fin, fout):
    fout = open(fout, "w")
    lines = []
    mode = "n"
    for line in open(fin):
        if re.match(r"(.*)//\[(.*)",line) and mode == "n":
            m = re.match("(.*)//\[(.*)",line)
            mode = "c"

            lines = [(m[1], m[2])]
            # print(lines)
        elif re.match(r"(.*)//\|(.*)",line) and mode == "c":
            m = re.match(r"(.*)//\|(.*)",line)

            lines += [(m[1], m[2])]
            # print(lines)
        elif re.match(r"(.*)//\](.*)",line) and mode == "c":
            m = re.match(r"(.*)//\](.*)",line)
            mode = "n"

            lines += [(m[1], m[2])]
            # print(lines)
            l = max(map(lambda x: len(x[0]), lines))
            l += 5
            for code, cmt in lines:
                cmt = "" if cmt == None else "//" + cmt
                fout.write(code + " "*(l - len(code)) + cmt + "\n")
        elif mode == "c":
            lines += [(line[:-1], None)]
        else:
            fout.write(line)


src_name = 'src'
module_name = argv[1]
verilog_name = argv[2]
source_path = join(src_name,module_name)
target_path = join(src_name,verilog_name)

for path in Path(source_path).rglob('*.py'):
    fin = str(path)
    print(fin)
    exec(open(fin, 'r').read())

for path in Path(source_path).rglob('*.v'):
    fin = str(path)
    print(fin)
    fout = fin.replace(source_path, target_path)
    generate(fin, fout)