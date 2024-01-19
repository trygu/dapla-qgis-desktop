# dapla-qgis-desktop

This project allows you to run QGIS, a popular open-source Geographic Information System (GIS) software, within a Docker container using noVNC for remote desktop access. It has been created with the intention of being compatible with Onyxia (onyxia.sh), a platform for easily deploying and managing data analysis environments.

## What is QGIS?

QGIS (Quantum GIS) is a user-friendly and powerful open-source desktop GIS application that provides a wide range of tools for working with geographic data. It's used by professionals and enthusiasts alike for tasks such as mapping, spatial analysis, data visualization, and more. Whether you're a geospatial expert or a beginner, QGIS is a versatile and valuable tool for working with geographic information.

## How to Use this Docker Container

To use this Docker container and run QGIS, follow these steps:

1. **Prerequisites**:
   - Install Docker: [Docker Installation Guide](https://docs.docker.com/get-docker/)
   - Ensure you have `docker-compose` installed.

2. **Clone this Repository**:
   ```bash
   git clone https://github.com/trygu/dapla-qgis-desktop.git
   ```

3. **Build the Docker Container**:
   ```bash
   cd dapla-qgis-desktop
   docker-compose build
   ```

4. **Run the Docker Container**:
   ```bash
   docker-compose up -d
   ```

5. **Access QGIS**:
   - Open your web browser and navigate to `http://localhost:6080/`.
   - You will be greeted with a noVNC login page; use the default password provided in the `docker-compose.yml` file (make sure to change it for production use).

6. **Start Using QGIS**:
   - Once logged in, you will have access to a QGIS desktop environment running in the container. You can start creating, editing, and analyzing geographic data right from your browser.

7. **Clean Up**:
   - When you're finished, you can stop and remove the container using:
   ```bash
   docker-compose down
   ```

## Customize and Extend

Feel free to customize this Docker container to suit your specific needs. You can modify the Dockerfile, add plugins, and configure QGIS settings as required. This project provides a foundation for running QGIS in a containerized environment, making it easier to manage and share GIS projects.

## Running in Onyxia (onyxia.sh)

This project has been designed with compatibility for Onyxia in mind. You can easily deploy it within the Onyxia platform to take advantage of its data analysis capabilities and resources.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

