# First build stage
FROM dart:stable AS build

MAINTAINER NicklasXYZ

WORKDIR /usr/src

# Resolve app dependencies
WORKDIR /app

# Copy app source code (except anything in .dockerignore) and AOT compile app
COPY . .
RUN ls -la && dart pub get && dart compile exe bin/server.dart -o bin/server


# Final build stage
FROM alpine:3.15 AS app

COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

# Make the function watchdog executable
RUN chmod +x /app/bin

# Add non root user
RUN addgroup -S app && adduser -S -g app app \
    && mkdir -p /home/app \
    && chown -R app /home/app

USER app

ENV PORT 8080
EXPOSE 8080


# Start the webserver and leave the process in the foreground
CMD ["/bin/sh", "-lc", "/app/bin/server"]
