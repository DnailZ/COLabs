#!/usr/bin/env python
# -*- coding: utf-8 -*-

from sys import argv
import os
import re

outfile = argv[2] if len(argv) > 2 else argv[1]

fout = open(outfile, "w")
title = {
    "实验目标" : "##",
    "实验内容" : "##",
    "实验步骤" : "##",
    "实验检查" : "##",
    "思考题" : "##"
}

index = [0]

def indexstr():
    return ".".join(map(lambda x: str(x), index))

for line in open(argv[1]):
    for k in title:
        if k in line:
            index = [index[0] + 1]
            line = title[k] + " " + indexstr() + " " + k
            line += "\n"
    if re.match(r"[0-9]*(\.|\\\.) .*", line):
        index = [index[0], 1 if len(index) == 1 else index[1] + 1 ]
        line = "###" + " " + indexstr() + " "+ " ".join(line.split(" ")[1:])
        line += "\n"
    if re.match(r"[ ]*<!--[ ]*-->[ ]*", line):
        line = ""
    if re.match(r" *图-[0-9].*", line) or re.match(r" *表-[0-9].*", line):
        line = "<center>" + line + "</center>"
    fout.write(line)
    

