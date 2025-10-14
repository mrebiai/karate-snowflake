FROM eclipse-temurin:21-jdk AS builder

COPY src /src
COPY gradle /gradle
COPY build.gradle.kts settings.gradle.kts gradle.properties gradlew /

RUN ./gradlew build --no-daemon

FROM eclipse-temurin:21-jre AS runtime

COPY --from=builder /build/libs/bridge-*-SNAPSHOT.jar /bridge.jar

ENTRYPOINT ["java", "-jar", "/bridge.jar"]