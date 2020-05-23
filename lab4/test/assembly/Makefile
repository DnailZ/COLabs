
test.coe: test.asm
	./armips test.asm 
	mv output.bin test.bin
	python readbin.py > test.coe
	rm test.bin
	cp ./test.coe ../
