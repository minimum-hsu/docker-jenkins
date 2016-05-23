FROM jenkins

# Set the number of executors
COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

USER root

# Install Packages
RUN \
  apt-get update \
  && apt-get install -y python3 make curl wget git \
  && (curl -fsSL https://get.docker.com/ | sh) \
  && (curl https://bootstrap.pypa.io/get-pip.py | python3)

# Install Python packages
RUN \
  pip3 install elasticsearch pyaml docker-compose

USER jenkins
