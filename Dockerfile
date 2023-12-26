FROM python:3.10

COPY prebuildfs /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN install_packages ca-certificates gettext-base tree

# Create directories and user for PrivacyIdea and set ownership
RUN mkdir -p /data/privacyidea/keys \
    /var/log/privacyidea \
    /etc/privacyidea && \
    adduser --gecos "PrivacyIdea User" \
    --disabled-password \
    --home /home/privacyidea \
    --uid 100001 \
    privacyidea && \
    usermod -g 100001 privacyidea && \
    chown -R privacyidea:privacyidea /var/log/privacyidea /data/privacyidea /etc/privacyidea

# Set environment variables for uWSGI and Nginx
ENV UWSGI_INI=/etc/uwsgi/uwsgi.ini \
    UWSGI_CHEAPER=2 \
    UWSGI_PROCESSES=16 \
    DB_VENDOR=sqlite \
    PI_HOME=/opt/privacyidea \
    VIRTUAL_ENV=/opt/privacyidea

# Set environment variables for Python
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Set the PrivacyIdea version to install
ARG PI_VERSION=3.9.1

# Create a virtual environment for PrivacyIdea and install its dependencies
RUN python3 -m venv $VIRTUAL_ENV && \
    pip3 install -r /opt/requirements.txt

# Copy the rootfs directory to the root of the container filesystem
COPY rootfs /

EXPOSE 8080

ENTRYPOINT ["/opt/privacyidea/bin/uwsgi", "--ini", "/etc/uwsgi/uwsgi.ini"]

WORKDIR /opt/privacyidea

USER privacyidea

VOLUME [ "/data/privacyidea" ]
