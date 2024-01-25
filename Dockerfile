# Use the official Ubuntu base image
FROM ubuntu:22.04

# Set non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

COPY ./resources/qgis.sources /etc/apt/sources.list.d/

# Install dependencies
RUN apt-get update && \
    apt-get install -y gnupg software-properties-common python3-xdg maven x11-xserver-utils \
    x11vnc xvfb unzip wget novnc net-tools openbox qgis qgis-plugin-grass && \
    rm -rf /var/lib/apt/lists/*

# Fix favicons so it matches the application
COPY ./resources/favicons/*.png /usr/share/novnc/app/images/icons/

#RUN mkdir -m755 -p /etc/apt/keyrings  # not needed since apt version 2.4.0 like Debian 12 and Ubuntu 22 or newer
RUN wget -O /etc/apt/keyrings/qgis-archive-keyring.gpg https://download.qgis.org/downloads/qgis-archive-keyring.gpg

# Create a user and group for QGis desktop
RUN groupadd -r dapla && useradd -r -g dapla -d /home/dapla -m -s /bin/bash dapla

# Set the home directory as an environment variable
ENV HOME=/home/dapla

# Create the directories
RUN chown -R dapla:dapla /home/dapla /usr/share/novnc

COPY --chown=dapla:dapla ./resources/init.sh /home/dapla
COPY --chown=dapla:dapla ./resources/kart.ssb.no-wfs.xml /home/dapla
COPY --chown=dapla:dapla ./resources/kart.ssb.no-wms.xml /home/dapla


# Switch to the new user
USER dapla

# Set the working directory to the home directory
WORKDIR /home/dapla

# Set the DISPLAY environment variable
ENV DISPLAY=:1

# Expose the noVNC port
EXPOSE 6080

# Start the application using the startup script
CMD ["/home/dapla/init.sh"]