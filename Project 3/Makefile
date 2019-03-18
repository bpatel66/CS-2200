# Authored by Christopher Tam for Georgia Tech's CS 2200

SRCDIR = assembly

SRC := $(wildcard $(SRCDIR)/*.s)

SUBMIT_SUFFIX = -pipeline
SUBMIT_FILES = $(SRC) BOB2200-pipeline.circ
SUBMIT_FILES_EC = $(SRC) BOB2200-pipeline.circ BOB2200-pipeline-EC.circ

all: ;

.PHONY: check-username
check-username:
	@if [ -z "$(GT_USERNAME)" ]; then \
		echo "Before running 'make submit', please set your GT Username in the environment"; \
		echo "Run the following to set your username: \"export GT_USERNAME=your username\""; \
		exit 1; \
	fi

.PHONY: submit
submit: check-username
	@(tar zcfh $(GT_USERNAME)$(SUBMIT_SUFFIX).tar.gz $(SUBMIT_FILES) && \
	echo "Created submission archive (not including EC) $$(tput bold)$(GT_USERNAME)$(SUBMIT_SUFFIX).tar.gz$$(tput sgr0).") || \
	(echo "$$(tput bold)$$(tput setaf 1)Error:$$(tput sgr0) Failed to create submission archive." && \
	rm -f $$name$(SUBMIT_SUFFIX).tar.gz)

.PHONY: ec
ec: check-username
	@(tar zcfh $(GT_USERNAME)$(SUBMIT_SUFFIX).tar.gz $(SUBMIT_FILES_EC) && \
	echo "Created submission archive (including EC) $$(tput bold)$(GT_USERNAME)$(SUBMIT_SUFFIX).tar.gz$$(tput sgr0).") || \
	(echo "$$(tput bold)$$(tput setaf 1)Error:$$(tput sgr0) Failed to create submission archive." && \
	rm -f $$name$(SUBMIT_SUFFIX).tar.gz)
