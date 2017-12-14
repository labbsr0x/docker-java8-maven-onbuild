FROM maven:3-jdk-8-alpine

# create a Maven repo to store the downloaded jars
RUN mkdir -p /usr/maven_repo

# just downlading the dependencies
RUN mkdir -p /usr/tmp
ONBUILD WORKDIR /usr/tmp
ONBUILD COPY pom.xml /usr/tmp/pom.xml
ONBUILD RUN mvn -Dmaven.repo.local=/usr/maven_repo dependency:go-offline
ONBUILD RUN mvn -Dmaven.repo.local=/usr/maven_repo install; exit 0

# compiling and packaging the Java App
RUN mkdir -p /usr/src/app
ONBUILD WORKDIR /usr/src/app
ONBUILD COPY . /usr/src/app
ONBUILD RUN cp /usr/tmp/pom.xml /usr/src/app/pom.xml
ONBUILD RUN mvn -Dmaven.repo.local=/usr/maven_repo install

# fire in the hole
CMD ["/usr/bin/java","-jar","/usr/src/app/target/app.jar"]
