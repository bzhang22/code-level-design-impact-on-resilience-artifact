# Convenience targets. See README.md for details.
.PHONY: help build main-results quick-check docker-image clean

help:
	@echo "targets:"
	@echo "  make build          compile-check all programs (needs g++/clang++)"
	@echo "  make main-results   regenerate paper tables+figures from included data (Python only)"
	@echo "  make quick-check    live fault-injection sanity check (needs the LLFI Docker image)"
	@echo "  make docker-image   fetch sources and build the LLFI Docker image"
	@echo "  make clean          remove regenerated outputs"

build:
	bash scripts/build.sh

main-results:
	bash scripts/reproduce_main_results.sh

quick-check:
	bash scripts/run_quick_check.sh

docker-image:
	bash docker/downloads/fetch.sh
	docker build -t anonymous-sdc-artifact .

clean:
	rm -rf results/reproduced results/processed/summary.csv \
	       results/tables/*.tex results/tables/*.csv \
	       results/figures/*.png results/figures/*.pdf results/figures/*_plotdata.csv \
	       $(shell find . -name __pycache__ -type d)
