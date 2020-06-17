import re
from os import listdir
from os.path import isfile, join, dirname, isdir
import pathlib
from pathlib import Path
from sys import argv

src_name = 'src'
module_name = 'verilog'
source_path = join(src_name,module_name)

env = dict()

addcode = r" */// *code\((.*)\) *(until *(.*)){0,1}"
cmt = r" *///(.*)"
doc_omit = r" */// *doc_omit *begin.*"
doc_omit_end = r" */// *doc_omit *end.*"
omit = None

for path in Path(source_path).rglob('*.v'):
    fin = str(path)

    mode = "n"
    key = ""
    block = 0 # text1 is 0  code 1 is 1   text2 is 2
    until = None

    for line in open(fin) :
        if re.match(addcode, line) and mode == "n":
            mode = "c"
            key = re.match(addcode, line)[1]
            until = re.match(addcode, line)[3]
            block = 0
            if key not in env:
                env[key] = ""
        elif re.match(doc_omit, line) and mode == "c":
            omit = (key, block, until)
            mode = "n"
        elif re.match(doc_omit_end, line) and mode == "n":
            key, block, until = omit
            mode = "c"
            env[key] += " " * line.index("///") + " ......\n"
        elif re.match(cmt, line) and mode == "c":
            line = re.match(cmt, line)[1] + "\n"
            if block % 2 == 1:
                line = "```\n\n" + line
                block += 1
            env[key] += line
        elif until != None and until in line and mode == "c":
            if "code" not in until:
                env[key] += line
            if block % 2 == 1:
                env[key] += "```\n\n"
            mode = "n"
        elif mode == "c":
            if block % 2 == 0:
                line = "```verilog\n" + line
                block += 1
                if until == None and block >= 3:
                    mode = "n"
                    continue
            env[key] += line


fin = open(argv[1])
fout = open(argv[2], "w")


index = []

def indexstr(index):
    return ".".join(map(lambda x: str(x), index))

for line in fin:
    if re.match(r" *#(##*).*", line) :
        count = len(re.match(r" *#(##*).*", line)[1])

        if indexstr(index) in env:
            # fout.write("\n")
            fout.write(env[indexstr(index)][:-1])
            #fout.write("\n")

        if len(index) < count:
            index += [0] * (count - len(index))
        index = index[:count]
        index[count - 1] += 1
    if re.match(r" *rep\[(.*)\] *", line):
        k = re.match(r" *rep\[(.*)\] *", line)[1]
        # fout.write("\n")
        fout.write(env[k][:-1])
        # fout.write("\n")
        continue
    fout.write(line)

    