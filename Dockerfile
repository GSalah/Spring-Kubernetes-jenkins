FROM openjdk:11
COPY build/libs/*.jar home/spring/app.jar
#COPY build/libs/*.jar app.jar
ENTRYPOINT ["java","-jar","/home/spring/app.jar"]