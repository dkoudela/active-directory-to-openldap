# CentOS 7
FROM centos:7

# explicit reqs
RUN yum install -y \
    openldap \
    openldap-servers-sql \
    openldap-clients \
    openldap-devel \
    python-ldap \
    openldap-servers

# secondary reqs
RUN yum install -y \
    which \
    psmisc \sudo

# systemctl replacement
RUN curl -L https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py -o /bin/systemctl

RUN mkdir /app

COPY ./ /app

RUN mv /app/.docker/entrypoint.sh /app/entrypoint.sh \
    && chmod +x /app/entrypoint.sh \
    && rm -rf /app/.docker

WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]