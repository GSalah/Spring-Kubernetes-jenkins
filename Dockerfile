FROM openjdk:11
ADD build/libs/*.jar app.jar
#COPY build/libs/*.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]