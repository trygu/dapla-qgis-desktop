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
RUN chown -R onyxia:users /home/onyxia /usr/share/novnc

COPY --chown=onyxia:users ./resources/init.sh /home/onyxia

# Install conda and install qgis using conda, as the support is better for GeoParquet.
ADD https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh /tmp/miniconda.sh
RUN chmod +x /tmp/miniconda.sh && \
    mkdir -p ~/.miniconda3 && \
    bash /tmp/miniconda.sh -b -u -p ~/.miniconda3 && \
    rm -rf /tmp/miniconda.sh && \
    ~/.miniconda3/bin/conda init bash && \
    ~/.miniconda3/bin/conda install -c conda-forge pyqt qgis gdal libgdal-arrow-parquet && \
    mkdir -p /home/onyxia/.local/share/QGIS/QGIS3/profiles/default/QGIS/ 

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
