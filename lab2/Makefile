name=lab2
upload_name=Lab2_PB18000058_丁垣天

verilog:
	python3 marco.py marilog .tmp_marcoed
	python3 comment.py .tmp_marcoed verilog

doc: verilog
	python3 attach.py $(name).md $(upload_name).md
	open $(upload_name).md

maindoc: *.docx
	pandoc -t markdown $< -o $(name).tmp.md --extract-media=.
	python3 ./md.py $(name).tmp.md $(name).md
	rm $(name).tmp.md

mkdirs:
	-mkdir src
	-mkdir src/marilog
	-mkdir src/marilog/logic
	-mkdir src/marilog/sim
	-mkdir src/verilog
	-mkdir src/verilog/logic
	-mkdir src/verilog/sim