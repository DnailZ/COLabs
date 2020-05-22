
test.txt: test.bin
	python readbin.py > test.txt

test.bin: test.asm
	./armips test.asm 
	mv output.bin test.bin

