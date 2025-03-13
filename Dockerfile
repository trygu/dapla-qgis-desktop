ARG VERSION=v0.32.0
# Use the official Ubuntu base image
FROM ubuntu:24.04

# Set non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y gnupg maven net-tools novnc openbox python3-pyqt5 python3-xdg software-properties-common \
    unzip wget x11-xserver-utils x11vnc xvfb && \
    rm -rf /var/lib/apt/lists/*

# Fix favicons so it matches the application
COPY ./resources/favicons/*.png /usr/share/novnc/app/images/icons/

# Fix default userdirs
COPY ./resources/user-dirs.defaults /etc/xdg/user-dirs.defaults

# Create a user and group for QGis desktop
RUN useradd -r -g users -d /home/onyxia -m -s /bin/bash onyxia

# Copy example data
COPY --chown=onyxia:users ./resources/*.parquet /home/onyxia/

# Set the home directory as an environment variable
ENV HOME=/home/onyxia

# Create the directories
RUN mkdir -p /home/onyxia/.cache/dconf && \
    mkdir -p /home/onyxia/.local/share/QGIS/QGIS3/profiles/default/python && \
    mkdir -p /home/onyxia/.local/share/QGIS/QGIS3/profiles/default && \
    touch /home/onyxia/.local/share/QGIS/QGIS3/profiles/default/qgis.db && \
    chown -R onyxia:users /home/onyxia /usr/share/novnc

COPY --chown=onyxia:users ./resources/init.sh /home/onyxia

# Install conda and install qgis using conda, as the support is better for GeoParquet.
ADD https://github.com/conda-forge/miniforge/releases/download/24.11.3-2/Miniforge3-24.11.3-2-Linux-aarch64.sh /tmp/mambaforge.sh
RUN chmod +x /tmp/mambaforge.sh && \
    mkdir -p /opt/conda && \
    bash /tmp/mambaforge.sh -b -u -p /opt/conda && \
    rm -rf /tmp/mambaforge.sh && \
    /opt/conda/bin/conda init bash && \
    /opt/conda/bin/conda install -c conda-forge pyqt qgis gdal libgdal-arrow-parquet && \
    mkdir -p /home/onyxia/.local/share/QGIS/QGIS3/profiles/default/QGIS/

# Set environment path
ENV PATH="/opt/conda/bin:$PATH"

# Switch to the new user
USER onyxia

# Set the working directory to the home directory
WORKDIR /home/onyxia

COPY ./resources/qgis3.ini /home/onyxia/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini
COPY --chown=onyxia:users ./resources/dapla.png /home/onyxia/.local/share 

# Bucket mountpoints.
RUN mkdir -p /home/onyxia/work && \
    mkdir -p /home/onyxia/.config/openbox/

COPY ./resources/rc.xml /home/onyxia/.config/openbox

# Clean up the homedir
RUN rm -fr /home/onyxia/Pictures && \
    rm -fr /home/onyxia/Videos && \
    rm -fr /home/onyxia/Music && \
    rm -fr /home/onyxia/Public && \
    rm -fr /home/onyxia/Templates && \
    rm -fr /home/onyxia/Desktop

# Set the DISPLAY environment variable
ENV DISPLAY=:1

# Expose the noVNC port
EXPOSE 6080

# Start the application using the startup script
CMD ["/home/onyxia/init.sh"]