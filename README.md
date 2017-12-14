# Docker image to build and run Java8 Maven runnable jar Projects

A docker image that builds the app and expects a runnable jar to run.

To use this image you should:
* Create a Dockerfile on your project root, alongside with `pom.xml` with the following content:
```
FROM labbsr0x/java8-maven-onbuild
```
* Your source code must follow the Maven folder structure (`src/main/java`, `src/main/resources` and `src/test/java`)
* Your `pom.xml` maven file should have the `build` plugin having `<source>` and `<target>` pointed to **1.8** Java version and having the definition to build a jar named `app.jar`. An example:

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId><YOUR_GROUP_ID></groupId>
  <artifactId><YOUR_ARTIFACT_ID></artifactId>
  <version><YOUR_VERSION></version>
  <name><YOUR_NAME></name>

  <properties>
    <maven.compiler.target>1.8</maven.compiler.target>
    <maven.compiler.source>1.8</maven.compiler.source>
 </properties>

  <!-- ... dependency stuff ... -->

	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-compiler-plugin</artifactId>
				<version>3.1</version>
				<configuration>
					<source>1.8</source>
					<target>1.8</target>
				</configuration>
			</plugin>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-shade-plugin</artifactId>
				<version>2.1</version>
				<executions>
					<!-- shade in the package phase -->
					<execution>
						<phase>package</phase>
						<goals>
							<goal>shade</goal>
						</goals>
						<configuration>
							<transformers>
								<!-- the main class -->
								<transformer
									implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
									<mainClass><YOUR_MAIN_CLASS></mainClass>
								</transformer>
								<!-- concat the spi's -->
								<transformer
									implementation="org.apache.maven.plugins.shade.resource.ServicesResourceTransformer" />
							</transformers>

							<!-- remove jars signatures, after joining all jars those signatures
								becomes invalid -->
							<filters>
								<filter>
									<artifact>*:*</artifact>
									<excludes>
										<exclude>META-INF/*.SF</exclude>
										<exclude>META-INF/*.DSA</exclude>
										<exclude>META-INF/*.RSA</exclude>
									</excludes>
								</filter>
							</filters>
							<finalName>app</finalName>
						</configuration>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>
</project>
```
* Build your image: `docker build -t <your_image_name> .`


## Notice this

We have tried to use Alpine version but we have some issues with Java8, specially using snappy compression that needs some native libs from the S.O. which we had no success installing. So we decided to move away from Alpine, from now. For more details on the issue: https://github.com/gliderlabs/docker-alpine/issues/11

If you want an Alpine version, please be careful with the native requirements your application has. Our problem appeared when using KAFKA client with Snappy compression.
