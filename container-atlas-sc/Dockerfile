FROM tomcat:7.0-jre8-alpine

ARG ATLAS_SC_BASE_TAG
ENV ATLAS_SC_BASE_TAG=${ATLAS_SC_BASE_TAG:-latest}

RUN mkdir -p /srv/gxa/data/ontology
RUN mkdir -p /srv/gxa/data/species
RUN mkdir -p /srv/gxa/data/scxa/magetab
RUN mkdir -p /srv/gxa/data/scxa/expdesign
RUN mkdir -p /srv/gxa/data/bioentity_properties/go

COPY --from=ATLAS_SC_BASE_BUILDER /resources/data-files/species/species-properties.json /srv/gxa/data/species/
COPY --from=ATLAS_SC_BASE_BUILDER /resources/data-files/ontology/* /srv/gxa/data/ontology/
COPY --from=ATLAS_SC_BASE_BUILDER /resources/data-files/bioentity_properties/go/* /srv/gxa/data/bioentity_properties/go/
COPY --from=ATLAS_SC_BASE_BUILDER /resources/data-files/bioentity_properties/annotations/* /srv/gxa/data/bioentity_properties/annotations/
COPY --from=ATLAS_SC_BASE_BUILDER /resources/data-files/bioentity_properties/interpro/* /srv/gxa/data/bioentity_properties/interpro/
COPY --from=ATLAS_SC_BASE_BUILDER /bytecode/gxa_sc.war $CATALINA_HOME/webapps/gxa#sc.war
RUN mkdir -p /etc/atlas-sc-config
COPY gxa#sc.xml $CATALINA_HOME/conf/Catalina/localhost/
COPY create_jdbc_properties.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/create_jdbc_properties.sh
COPY create_solr_properties.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/create_solr_properties.sh
COPY logback.xml /etc/atlas-sc-config/logback.xml
COPY run.sh /usr/local/bin/run.sh
RUN chmod a+x /usr/local/bin/run.sh

CMD ["run.sh"]
