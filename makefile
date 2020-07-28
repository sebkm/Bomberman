.PHONY: clean

all:
	@ozc -c *.oz
	@ozengine Main.ozf

compile:
	@ozc -c *.oz

%.ozf:%.oz
	@ozc -c $*.oz

run:
	@ozengine Main.ozf

clean:
	@rm -f *.ozf