# Atlas Orchestrated

A repository for serving Atlas and Atlas SC on an orchestrated manner.

## Building the containers

To build the containers, use the `build_containers.sh` script (you will need docker installed).

At the least, you will need to specify the username for the container (ie. the Dockerhub or quay.io username).

```
bash build_containers.sh -u pcm32
```

This should yield:

```
Relevant containers:
Atlas SC:          pcm32/atlas-sc:latest
Base builder:      pcm32/atlas-sc-base:latest
```

See `build_containers.sh --help` to see options to specify the registry hostname, tag and other options.

## Running the container

### Using docker directly

To run the Atlas SC container directly on port 8080, you will need to specify the connection details to an adequate postgres and solr indexes, plus mount the adequate data locally:

```
docker run -e ATLAS_SC_POSTGRES_HOST=postgres-hostname:postgres-port \
           -e ATLAS_SC_DB_NAME=db-name -e ATLAS_SC_DB_USERNAME=db-username \
           -e ATLAS_SC_DB_PASSWORD=password -e ATLAS_SC_POOL=gxa \
           -e ATLAS_SC_SOLR_HOST=solr-host:solr-port \
           -e ATLAS_SC_ZOOKEEPER_HOST=zookeeper-host \
           -v /path/to/experiments/magetab:/srv/gxa/data/scxa/magetab \
           -v /path/to/experiments/expdesign:/srv/gxa/data/scxa/expdesign \
           -p 8080:8080 pcm32/atlas-sc
```
