# Use the official Ubuntu base image
FROM ubuntu:22.04

# Set non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive


# Install dependencies
RUN apt-get update && \
    apt-get install -y gnupg software-properties-common python3-xdg maven x11-xserver-utils \
    x11vnc xvfb unzip wget novnc net-tools openbox && \
    rm -rf /var/lib/apt/lists/*

# Install QGIS from official repo
RUN wget -O /etc/apt/keyrings/qgis-archive-keyring.gpg https://download.qgis.org/downloads/qgis-archive-keyring.gpg
COPY ./resources/qgis.sources /etc/apt/sources.list.d/

RUN apt-get update && \
    apt-get install -y qgis qgis-plugin-grass && \
    rm -rf /var/lib/apt/lists/*

# Fix favicons so it matches the application
COPY ./resources/favicons/*.png /usr/share/novnc/app/images/icons/

# Create a user and group for QGis desktop
RUN groupadd -r dapla && useradd -r -g dapla -d /home/dapla -m -s /bin/bash dapla

# Set the home directory as an environment variable
ENV HOME=/home/dapla

# Create the directories
RUN chown -R dapla:dapla /home/dapla /usr/share/novnc

COPY --chown=dapla:dapla ./resources/init.sh /home/dapla

# Change owner 
RUN chown -R dapla:dapla /usr/share/qgis

# Switch to the new user
USER dapla

# Set the working directory to the home directory
WORKDIR /home/dapla

# Pre-configure QGis3: Add more stuff to qgis3.ini if you want more.
RUN mkdir -p /home/dapla/.local/share/QGIS/QGIS3/profiles/default/QGIS/
COPY ./resources/qgis3.ini /home/dapla/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini

RUN mkdir -p /home/dapla/.config/openbox/
COPY ./resources/rc.xml /home/dapla/.config/openbox

# Copy example data
COPY ./resources/*.parquet /home/dapla/

# Set the DISPLAY environment variable
ENV DISPLAY=:1

# Expose the noVNC port
EXPOSE 6080

# Start the application using the startup script
CMD ["/home/dapla/init.sh"]