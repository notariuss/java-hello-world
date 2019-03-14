FROM java

COPY target/helloworld-springboot-0.0.1-SNAPSHOT.jar /app/helloworld-springboot-0.0.1-SNAPSHOT.jar

CMD ["java", "-jar", "/app/helloworld-springboot-0.0.1-SNAPSHOT.jar"]