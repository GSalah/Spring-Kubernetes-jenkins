FROM openjdk:11
RUN mkdir /app
COPY build/libs/*.jar /app/spring-boot-application.jar/
ENTRYPOINT ["java","-jar","/app/spring-boot-application.jar"]