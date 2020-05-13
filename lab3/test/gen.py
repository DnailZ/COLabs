f = open('MemoryContent.txt', 'w')
for line in open('MemoryContent.bin'):
    line = line.split(';')[0] \
               .replace(' ','') \
               .replace('\n','')
    f.write(line + '\n')
f.close()
