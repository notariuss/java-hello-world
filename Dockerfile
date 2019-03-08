FROM java
COPY target/helloworld-springboot-0.0.1-SNAPSHOT.jar /app

CMD ["java", "-jar", "/app/helloworld-springboot-0.0.1-SNAPSHOT.jar"]