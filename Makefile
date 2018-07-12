tests = tests
package = pyresttest
examples = input()

# Additional Testing Requirements:

check:
	# Validate unit test input data
	# for FILE in tests/samples/*.json; do jsonschema tests/schemas/order-details.schema.json -i $$FILE; done
	# # Validate unit test output data
	# for FILE in tests/samples/*.xml; do jing tests/schemas/ticket-groups.schema.rng $$FILE; done
	# # Validate swagger file
	# if [ ! -f swagger.schema.json ]; then curl -sL http://swagger.io/v2/schema.json > swagger.schema.json; else true; fi
	# yaml2json swagger.yaml | jsonschema swagger.schema.json -i /dev/stdin
	# No unused imports, no undefined vars,
	flake8 --ignore=E731,W503 --exclude $(package)/__init__.py,$(package)/compat.py --max-complexity 10 $(package)/
	flake8 --ignore=E731,W503,F401 --max-complexity 10 $(package)/compat.py
	# Basic error checking in test code
	pyflakes $(tests)
	# PEP257 docstring conventions
	pydocstyle --add-ignore=D100,D101,D102,D103,D104,D105,D204,D301 $(package)/
	# Python linter errors only
	pylint --rcfile .pylintrc $(package)

pylint:
	pylint --rcfile .pylintrc $(package)

test:
	py.test -v $(tests)

typecheck:
	python -m mypy -p $(package) --ignore-missing-imports --disallow-untyped-defs --strict-optional --warn-no-return

coverage:
	py.test --cov $(package) --cov-report term-missing --cov-fail-under 80 $(tests)

.PHONY: htmlcov
htmlcov:
	py.test --cov $(package) --cov-report html $(tests)
	open htmlcov/index.html

prcheck: check typecheck test

rest:
    pyresttest $(examples) --interactive true --print-bodies true
