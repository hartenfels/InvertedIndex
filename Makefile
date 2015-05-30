all: install test run

install:
	carton install

test:
	carton exec prove

run:
	carton exec ./index

clean:
	rm -r local

.PHONY: all install test run clean
