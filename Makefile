# Copyright 2012-2015 Alex Sexton, Eemeli Aro, and Contributors
# Licensed under the MIT License

GREEN=\033[32;01m
RED=\033[31;01m
YELLOW=\033[33;01m
STOP=\033[0m
CHK=${GREEN} ✓${STOP}
ERR=${RED} ✖${STOP}

BIN=./node_modules/.bin

.PHONY: test test-browser clean doc all


all: messageformat.js doc test

messageformat.js: lib/messageformat.js lib/messageformat-parser.js
	@${BIN}/browserify $< -s MessageFormat -o $@
	@echo "${CHK} messageformat.js is now ready for browsers."

lib/messageformat-parser.js: lib/messageformat-parser.pegjs
	@${BIN}/pegjs $< $@
	@echo "${CHK} parser re-compiled by PEGjs"


doc: lib/messageformat.js
	@${BIN}/jsdoc -c jsdoc-conf.json
	@echo "${CHK} API documentation generated with jsdoc"

test/common-js-generated-test-fixture.js: bin/messageformat.js lib/messageformat.js lib/messageformat-parser.js example/en/colors.json
	./$< --module --locale en --include $(lastword $^) -o $@

test: test/common-js-generated-test-fixture.js
	@${BIN}/mocha --require test/common --reporter spec --growl test/tests.js

test-browser: messageformat.js test/common-js-generated-test-fixture.js
	@open "http://127.0.0.1:3000/test/" & ${BIN}/serve .


clean:
	rm -rf messageformat.js lib/messageformat-parser.js doc/ test/common-js-generated-test-fixture.js
