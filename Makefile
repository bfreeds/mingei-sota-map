GENERATED_FILES = $(DATA_DIR)/minnesota_osm.pbf $(DATA_DIR)/wisconsin_osm.pbf
DATA_DIR = data

.PHONY: all clean

all: $(GENERATED_FILES)

clean:
	rm -Rf data/finished

data:
	mkdir $(DATA_DIR)

minnesota_osm.pbf: data
	wget -O $(DATA_DIR)/$@ --no-use-server-timestamps https://download.geofabrik.de/north-america/us/minnesota-latest.osm.pbf

wisconsin_osm.pbf: data
	wget -O $(DATA_DIR)/$@ --no-use-server-timestamps https://download.geofabrik.de/north-america/us/wisconsin-latest.osm.pbf
