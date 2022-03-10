# Container image that runs your code
FROM docker

# Copies your code file from your action repository to the filesystem path `/` of the container
ADD *.sh /

RUN apk update
RUN apk install curl unzip

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" ; unzip awscliv2.zip

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
