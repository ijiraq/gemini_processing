
NAME = nat1405/nifty
VERSION = 0.1

build: dependencies Dockerfile
	docker build --no-cache -t $(NAME):$(VERSION) -f Dockerfile .

dependencies: 

init:
	mkdir -p build

.PHONY: clean
clean:
	\rm -rf build
