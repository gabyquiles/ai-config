.PHONY: install lint test

install:
	./install.sh

lint:
	shellcheck install.sh

test:
	bash -n install.sh
