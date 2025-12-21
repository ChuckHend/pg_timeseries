EXTENSION    = timeseries
EXTVERSION    = $(shell grep "^default_version" timeseries.control | sed -r "s/default_version[^']+'([^']+).*/\1/")
DISTVERSION  = $(shell grep -m 1 '[[:space:]]\{3\}"version":' META.json | \
               sed -e 's/[[:space:]]*"version":[[:space:]]*"\([^"]*\)",\{0,1\}/\1/')

DATA 		 = $(wildcard sql/*--*.sql)
DATA_built   = $(foreach v,$(EXTVERSIONS),sql/$(EXTENSION)--$(v).sql)

DOCS         = $(wildcard doc/*.md)
TESTS        = $(wildcard test/sql/*.sql)
REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --temp-config=./images/timeseries-pg/timeseries.conf --temp-instance=./tmp_check --inputdir=test
PG_CONFIG ?= pg_config
EXTRA_CLEAN = sql/$(EXTENSION)--$(EXTVERSION).sql

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

all: sql/$(EXTENSION)--$(EXTVERSION).sql

dist:
	git archive --format zip --prefix=$(EXTENSION)-$(DISTVERSION)/ -o $(EXTENSION)-$(DISTVERSION).zip HEAD

latest-changes.md: Changes
	perl -e 'while (<>) {last if /^(v?\Q${DISTVERSION}\E)/; } print "Changes for v${DISTVERSION}:\n"; while (<>) { last if /^\s*$$/; s/^\s+//; print }' Changes > $@

# generate each version's file installation file by concatenating
# previous upgrade scripts
sql/$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql
	cp $< $@

install-ivm:
	git clone https://github.com/chuckhend/pg_ivm.git && \
	cd pg_ivm && \
    make && make install && \
	cd .. && rm -rf pg_ivm

install-pg-partman:
	git clone https://github.com/pgpartman/pg_partman.git && \
    cd pg_partman && \
    make && make install && \
    cd .. && rm -rf pg_partman

install-pg-cron:
	git clone https://github.com/citusdata/pg_cron.git && \
	cd pg_cron && \
	make && make install && \
    cd .. && rm -rf pg_cron

install-citus:
	git clone https://github.com/citusdata/citus.git && \
	cd citus && \
	./configure && \
	make && \
	make install && \
	cd .. && rm -rf citus

install-dependencies: install-ivm install-pg-partman install-pg-cron install-citus
