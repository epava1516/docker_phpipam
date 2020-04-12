FROM nginx:stable
COPY files /tmp/files
RUN chmod +x /tmp/files/install.sh /tmp/files/config.sh && \
    /tmp/files/install.sh
ENTRYPOINT ["/tmp/files/config.sh"]