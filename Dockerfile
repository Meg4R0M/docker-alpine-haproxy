FROM alpine:3.7

ARG HAPROXY_MAJOR
ARG HAPROXY_VERSION
ARG HAPROXY_MD5
ARG WITH_LUA
ARG BUILD_DATE

# Build-time metadata as defined at http://label-schema.org
LABEL maintainer="Florian Durano <psykoterro@gmail.com>" \
    org.label-schema.name="HAProxy" \
	org.label-schema.description="A TCP/HTTP reverse proxy for high availability environments" \
	org.label-schema.url="http://www.haproxy.org" \
	org.label-schema.version=$HAPROXY_VERSION \
	org.label-schema.vcs-url="https://github.com/psykoterro/docker-alpine-haproxy" \
	org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.schema-version="1.0"

# Create a system group and user to be used by HAProxy.
RUN addgroup haproxy && adduser -S -g haproxy haproxy

# Need to create a directory for HAProxy to be able to `chroot`.
# This is a security measurement.
# Refer to http://cbonte.github.io/haproxy-dconv/configuration-1.5.html#chroot.
RUN mkdir /var/lib/haproxy

COPY scripts/build.sh /
RUN chmod +x /build.sh
RUN /build.sh

ADD conf/haproxy.cfg /etc/haproxy/haproxy.cfg
ADD scripts/bootstrap.sh /root/bootstrap.sh
RUN chmod +x /root/bootstrap.sh

#CMD [ "/usr/sbin/haproxy-systemd-wrapper", "-p", "/run/haproxy.pid", "-f", "/etc/haproxy/haproxy.cfg" ]
CMD ["/root/bootstrap.sh"]

EXPOSE 80 443 8000