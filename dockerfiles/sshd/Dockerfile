# docker build -t yuanying/sshd .
# docker run yuanying/sshd

FROM ubuntu:16.04
MAINTAINER OTSUKA, Yuanying "yuan-docker@fraction.jp"

RUN apt-get update && \
    apt-get install -y openssh-server curl vim dnsutils jq rsync && \
    apt-get clean && \
    mkdir /var/run/sshd && \
    mkdir /root/.ssh

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    chmod 700 /root/.ssh

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
