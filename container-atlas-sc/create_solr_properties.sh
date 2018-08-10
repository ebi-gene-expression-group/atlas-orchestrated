#!/bin/sh

echo "zk.host = $ATLAS_SC_ZOOKEEPER_HOST" > /etc/atlas-sc-config/solr.properties
echo "solr.host = $ATLAS_SC_SOLR_HOST" >> /etc/atlas-sc-config/solr.properties
