FROM openjdk:8-jdk
 
ENV JENKINS_VERSION=2.164.3
ENV GITHUB_VERSION="2.11.2"
ENV HELM_VERSION="v2.13.1"
ENV KUBECTL_VERSION="v1.13.5"
ENV JENKINS_UC="https://updates.jenkins.io"

RUN apt-get update \
    && apt-get install -y sudo make wget curl libltdl7 uuid-runtime \
    && curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
    && apt-get install -y nodejs gettext-base \
    && npm install -g n \
    && n 8.9.1 


WORKDIR /app

#http://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/war-stable//jenkins.war
RUN mkdir -p /usr/share/jenkins \
    && wget -O /usr/share/jenkins/jenkins.war http://ftp-nyc.osuosl.org/pub/jenkins/war-stable/$JENKINS_VERSION/jenkins.war \
    && wget -O hub.tar.gz https://github.com/github/hub/releases/download/v$GITHUB_VERSION/hub-linux-amd64-$GITHUB_VERSION.tgz \
    && tar xfz hub.tar.gz && rm -f hub.tar.gz \
    && hub-linux-amd64-$GITHUB_VERSION/install \
    && rm -rf hub-linux-amd64-$GITHUB_VERSION/ \
    && wget -O /app/helm.tar.gz "https://storage.googleapis.com/kubernetes-helm/helm-$HELM_VERSION-linux-amd64.tar.gz" \
    && tar xfzv helm.tar.gz && mv /app/linux-amd64/helm /usr/local/bin && rm -rf helm.tar.gz linux-amd64 \
    && helm init -c && helm plugin install https://github.com/chartmuseum/helm-push \
    && wget -O /app/kubectl "https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl" \
    && chmod +x /app/kubectl \
    && mv /app/kubectl /usr/local/bin/kubectl


ENV JENKINS_HOME=/var/jenkins_home
ENV JAVA_OPTS='"-Dhudson.model.DirectoryBrowserSupport.CSP=", "-Dmail.smtp.starttls.enable=true"'
ENV JENKINS_HOME="/var/jenkins_home"
ENV COPY_REFERENCE_FILE_LOG="/var/jenkins_home/jenkins.log"
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY jenkins-support /usr/local/bin/jenkins-support
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
RUN /usr/local/bin/install-plugins.sh \
    dashboard-view:2.10 \
    pipeline-stage-view:2.11 \  
    parameterized-trigger:2.35.2 \  
    #bitbucket:1.1.5 \  
    git:3.10.0 \  
    github:1.29.4 \
    pipeline-utility-steps:2.3.0 \
    pipeline-github-lib:1.0 \
    job-dsl:1.74 \
    build-pipeline-plugin:1.5.8 \
    ssh-agent:1.17 \
    ws-cleanup:0.37 \
    ssh-steps:1.2.1 \
    htmlpublisher:1.18
ENTRYPOINT ["/bin/bash", "-c", "/usr/local/bin/jenkins.sh"]
