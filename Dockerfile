ARG VERSION=v0.31.6
# Use the official Ubuntu base image
FROM ubuntu:24.04

# Set non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget gnupg software-properties-common python3-xdg maven x11-xserver-utils \
    x11vnc xvfb unzip wget novnc net-tools openbox python3-pyqt5 && \
    rm -rf /var/lib/apt/lists/*

# Fix favicons so it matches the application
COPY ./resources/favicons/*.png /usr/share/novnc/app/images/icons/

# Fix default userdirs
COPY ./resources/user-dirs.defaults /etc/xdg/user-dirs.defaults

# Copy example data
COPY --chown=dapla:dapla ./resources/*.parquet /home/dapla/

# Create a user and group for QGis desktop
RUN groupadd -r dapla && useradd -r -g dapla -d /home/dapla -m -s /bin/bash dapla

# Set the home directory as an environment variable
ENV HOME=/home/dapla

# Create the directories
RUN chown -R dapla:dapla /home/dapla /usr/share/novnc

COPY --chown=dapla:dapla ./resources/init.sh /home/dapla


# Switch to the new user
USER dapla

# Set the working directory to the home directory
WORKDIR /home/dapla

# Install conda and install qgis using conda, as the support is better for GeoParquet.
RUN mkdir -p ~/.miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/.miniconda3/miniconda.sh
RUN bash ~/.miniconda3/miniconda.sh -b -u -p ~/.miniconda3
RUN rm -rf ~/.miniconda3/miniconda.sh
RUN ~/.miniconda3/bin/conda init bash
RUN ~/.miniconda3/bin/conda install -c conda-forge pyqt qgis gdal libgdal-arrow-parquet

# Pre-configure QGis3: Add more stuff to qgis3.ini if you want more.
RUN mkdir -p /home/dapla/.local/share/QGIS/QGIS3/profiles/default/QGIS/
COPY ./resources/qgis3.ini /home/dapla/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini

COPY --chown=dapla:dapla ./resources/dapla.png /home/dapla/.local/share 

# Bucket mountpoints.
RUN mkdir -p /home/dapla/work

RUN mkdir -p /home/dapla/.config/openbox/
COPY ./resources/rc.xml /home/dapla/.config/openbox

# Clean up the homedir
RUN rm -fr /home/dapla/Pictures /home/dapla/Videos /home/dapla/Music /home/dapla/Public /home/dapla/Templates /home/dapla/Desktop

# Set the DISPLAY environment variable
ENV DISPLAY=:1

# Expose the noVNC port
EXPOSE 6080

# Start the application using the startup script
CMD ["/home/dapla/init.sh"]