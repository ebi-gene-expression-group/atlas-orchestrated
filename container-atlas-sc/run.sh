#!/bin/sh

create_jdbc_properties.sh
create_solr_properties.sh
catalina.sh run
