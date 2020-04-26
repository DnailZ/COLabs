name=lab1
upload_name=Lab1_PB18000058_丁垣天

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