FROM nginx
WORKDIR /app
COPY scripts scripts
RUN pwd
RUN ls -la
