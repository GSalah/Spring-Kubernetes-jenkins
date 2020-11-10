FROM openjdk:11
ARG JAR_FILE=build/libs/*.jar
COPY ${JAR_FILE} build/libs/app.jar
ENTRYPOINT ["java","-jar","build/libs/app.jar"]