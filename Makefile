# Makefile for property-manager.
#
# Author: Peter Odding <peter@peterodding.com>
# Last Change: June 23, 2016
# URL: https://github.com/xolox/python-property-manager

WORKON_HOME ?= $(HOME)/.virtualenvs
VIRTUAL_ENV ?= $(WORKON_HOME)/property-manager
PATH := $(VIRTUAL_ENV)/bin:$(PATH)
MAKE := $(MAKE) --no-print-directory
SHELL = bash

default:
	@echo 'Makefile for property-manager'
	@echo
	@echo 'Usage:'
	@echo
	@echo '    make install    install the package in a virtual environment'
	@echo '    make reset      recreate the virtual environment'
	@echo '    make check      check coding style (PEP-8, PEP-257)'
	@echo '    make test       run the test suite'
	@echo '    make docs       update documentation using Sphinx'
	@echo '    make publish    publish changes to GitHub/PyPI'
	@echo '    make clean      cleanup all temporary files'
	@echo

install:
	@test -d "$(VIRTUAL_ENV)" || mkdir -p "$(VIRTUAL_ENV)"
	@test -x "$(VIRTUAL_ENV)/bin/python" || virtualenv --quiet "$(VIRTUAL_ENV)"
	@test -x "$(VIRTUAL_ENV)/bin/pip" || easy_install pip
	@test -x "$(VIRTUAL_ENV)/bin/pip-accel" || (pip install --quiet pip-accel && pip-accel install --quiet 'urllib3[secure]')
	@echo "Updating installation of property-manager .." >&2
	@pip uninstall --yes property-manager &>/dev/null || true
	@pip-accel install --quiet --editable .

reset:
	$(MAKE) clean
	rm -Rf "$(VIRTUAL_ENV)"
	$(MAKE) install

check: install
	@echo "Updating installation of flake8 .." >&2
	@pip-accel install --upgrade --quiet --requirement=requirements-checks.txt
	@flake8

test: install
	@pip-accel install --quiet detox --requirement=requirements-tests.txt
	@py.test --cov
	@coverage html
	@detox

docs: install
	@pip-accel install --quiet sphinx
	@cd docs && sphinx-build -nb html -d build/doctrees . build/html

publish: install
	git push origin && git push --tags origin
	make clean
	pip-accel install --quiet twine wheel
	python setup.py sdist bdist_wheel
	twine upload dist/*
	make clean

clean:
	rm -Rf *.egg .cache .coverage .tox build dist docs/build htmlcov
	find -depth -type d -name __pycache__ -exec rm -Rf {} \;
	find -type f -name '*.pyc' -delete

.PHONY: default install reset check test docs publish clean
