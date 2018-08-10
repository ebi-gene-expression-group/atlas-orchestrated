FROM alpine:3.8
ARG ATLAS_SC_RELEASE
ENV ATLAS_SC_RELEASE=${ATLAS_SC_RELEASE:-master}
RUN apk update && apk add openjdk8 maven wget && \
    mkdir -p /atlas && \
    wget -q -O - https://github.com/ebi-gene-expression-group/atlas/archive/$ATLAS_SC_RELEASE.tar.gz | tar xzf - --strip-components=1 -C /atlas && \
    mvn clean install -f /atlas/pom.xml -pl base -am -P production -DskipTests && \
    mvn clean package -f /atlas/pom.xml -pl sc -am -P production -DskipTests && \
    mkdir -p /resources/data-files/species && mv /atlas/base/src/test/resources/data-files/species/species-properties.json /resources/data-files/species/ && \
    mv /atlas/base/src/test/resources/data-files/ontology /resources/data-files/ontology && \
    mkdir -p /resources/data-files/bioentity_properties/go && \
    mv /atlas/base/src/test/resources/data-files/bioentity_properties/go/* /resources/data-files/bioentity_properties/go && \
    mv /atlas/base/src/test/resources/data-files/bioentity_properties/annotations /resources/data-files/bioentity_properties/annotations && \
    mv /atlas/base/src/test/resources/data-files/bioentity_properties/interpro /resources/data-files/bioentity_properties/interpro && \
    mkdir -p /bytecode && mv /atlas/sc/target/gxa_sc.war /bytecode/gxa_sc.war && \
    rm -rf /atlas && rm -rf /root/.m2 && apk del openjdk8 maven git
