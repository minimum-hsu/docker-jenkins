FROM jenkins

# Set the number of executors
COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

USER root

# Install Packages
RUN \
  apt-get update \
  && apt-get install -y python3 make curl wget git \
  && (curl -fsSL https://get.docker.com/ | sh) \
  && gpasswd -a jenkins docker \
  && (curl https://bootstrap.pypa.io/get-pip.py | python3) \
  && ln -sf python3.4 /usr/bin/python

# Install Python packages
RUN pip3 install elasticsearch pyaml docker-compose docopt

# Install gosu
ENV GOSU_VERSION 1.7
RUN \
  rm -rf /var/lib/apt/lists/* \
  && wget -q -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -q -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

# Install Jenkins Plugins
COPY plugins.txt /usr/share/jenkins/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

ENTRYPOINT service docker start && gosu jenkins /bin/tini -- /usr/local/bin/jenkins.sh

