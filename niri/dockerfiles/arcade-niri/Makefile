
NAME = images.canfar.net/gemini/niri
VERSION = 0.2

build: dependencies Dockerfile
	docker build -t $(NAME):$(VERSION) -f Dockerfile .

dependencies: 

init:
	mkdir -p build

.PHONY: clean
clean:
	\rm -rf build
