
NAME = nat1405/nifty
VERSION = 0.1

DATE := $(shell date +%Y%m%d-%H%M%S)
build: dependencies Dockerfile
	docker build --build-arg TIMESTAMP=$(DATE) -t $(NAME):$(VERSION) -f Dockerfile .

dependencies: 

init:
	mkdir -p build

.PHONY: clean
clean:
	\rm -rf build
