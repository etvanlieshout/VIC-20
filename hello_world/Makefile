.PHONY: all

hello.prg: hello_world.s
	64tass -Wall -Wno-implied-reg --cbm-prg -o hello.prg -L bin/list-co1.txt -l bin/labels.txt hello_world.s
