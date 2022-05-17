FROM ubuntu:latest

WORKDIR /app
COPY . .
RUN pwd
RUN ls -la



