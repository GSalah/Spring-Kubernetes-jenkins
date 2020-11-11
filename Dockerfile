FROM openjdk:11
RUN mkdir /app
COPY build/libs/*.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]