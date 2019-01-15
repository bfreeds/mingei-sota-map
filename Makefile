# Requirements:
# 	- GDAL
# 	- PostGIS
# 	- SHP2PGSQL

# VARIABLES
GENERATED_FILES = $(DATA_DIR)/flow.geojson $(DATA_DIR)/minnesota_osm.pbf $(DATA_DIR)/wisconsin_osm.pbf $(DATA_DIR)/ne_places.shp
DATA_DIR = data
TMP_DIR = $(DATA_DIR)/tmp

# PostgreSQL Connection Variables
##### Will read from environment variables if set
PGHOST?=localhost
PGUSER?=postgres
PGPORT?=5432
PGDATABASE=mn
DBCONN = "host=$(PGHOST) user=$(PGUSER) port=$(PGPORT) dbname=$(PGDATABASE)"

.PHONY: all clean

all: $(GENERATED_FILES)

clean:
	rm -Rf data/finished
	rm -Rf data/tmp

data:
	mkdir $(DATA_DIR)
	mkdir $(TMP_DIR)

# MN DNR Hydrologic Flow Network
$(DATA_DIR)/flow.geojson: $(TMP_DIR)/DNR_flow_network_27mar09.shp
	@echo Importing shapefile into PostGIS to deal with erroneous shapefile
	shp2pgsql -d -s 26915:4326 $< public.flow | psql
	@echo Exporting PostGIS table to GeoJSON
	ogr2ogr -f GeoJSON $@ PG:$(DBCONN) public.flow

$(TMP_DIR)/DNR_flow_network_27mar09.shp: data
	@echo Downloading hydrologic flow dataset
	wget --no-parent -nH --cut-dirs 5 -r \
	-P $(TMP_DIR) \
	ftp://ftp.dnr.state.mn.us/pub/waters/watershed_data/flow_networks/Statewide/

# MN DNR Watershed Boundaries
$(DATA_DIR)/dnr_watersheds.zip: data
	wget --no-use-server-timestamps \
	-O $@ \
	ftp://ftp.gisdata.mn.gov/pub/gdrs/data/pub/us_mn_state_dnr/geos_dnr_watersheds/fgdb_geos_dnr_watersheds.zip

# OSM data for Minnesota
$(DATA_DIR)/minnesota_osm.pbf: data
	wget --no-use-server-timestamps \
	-O $@ \
	https://download.geofabrik.de/north-america/us/minnesota-latest.osm.pbf
# OSM data for Wisconsin
$(DATA_DIR)/wisconsin_osm.pbf: data
	wget --no-use-server-timestamps \
	-O $@ \
	https://download.geofabrik.de/north-america/us/wisconsin-latest.osm.pbf

# Natural Earth places for point labels
$(DATA_DIR)/ne_places.shp: data
	wget --no-use-server-timestamps \
	-O $@ \
	https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places_simple.zip