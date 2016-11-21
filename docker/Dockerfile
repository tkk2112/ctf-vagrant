FROM ubuntu:16.04

MAINTAINER Maintainer Thomas Kristensen
LABEL Description="ctf image" Version="0.2"

COPY setup.sh /root/setup.sh
RUN chmod +x /root/setup.sh
RUN cd /root && ./setup.sh /root

# Install decompile
COPY decompile /usr/bin/decompile
RUN chmod +x /usr/bin/decompile

# Setup ssh
RUN apt-get install -y openssh-server \
    && echo root:root | chpasswd \
    && sed -i 's/prohibit-password/yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && sed 's/UsePrivilegeSeparation yes/UsePrivilegeSeparation no/' -i /etc/ssh/sshd_config \
    && mkdir -p /root/.ssh \
    && mkdir -p /var/run/sshd
COPY insecure_id_rsa.pub /root/.ssh/authorized_keys
EXPOSE 22

# Clean up (commented until squash hits stable)
#RUN apt-get autoremove -y
#RUN apt-get clean
#RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

# set locale
RUN unset DEBIAN_FRONTEND
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

CMD ["/usr/sbin/sshd", "-D"]