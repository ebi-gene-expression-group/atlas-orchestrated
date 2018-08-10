#!/bin/sh

echo "jdbc.url = jdbc:postgresql://$ATLAS_SC_POSTGRES_HOST/$ATLAS_SC_DB_NAME" > /etc/atlas-sc-config/jdbc.properties
echo "jdbc.username = $ATLAS_SC_DB_USERNAME" >> /etc/atlas-sc-config/jdbc.properties
echo "jdbc.password = $ATLAS_SC_DB_PASSWORD" >> /etc/atlas-sc-config/jdbc.properties
echo "jdbc.pool = $ATLAS_SC_POOL" >> /etc/atlas-sc-config/jdbc.properties
