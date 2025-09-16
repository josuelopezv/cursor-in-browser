FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

LABEL maintainer="arfo_dublo@boards.digital" \
    org.opencontainers.image.authors="arfo_dublo@boards.digital" \
    org.opencontainers.image.source="https://github.com/Arfo-du-blo/cursor-in-browser/" \
    org.opencontainers.image.title="Cursor in browser" \
    org.opencontainers.image.description="Cursor container image allowing access via web browser"

# Set version, display and download link for Cursor
ENV DISPLAY=:1
ENV CURSOR_DOWNLOAD_URL=https://downloads.cursor.com/production/6af2d906e8ca91654dd7c4224a73ef17900ad735/linux/x64/Cursor-1.6.26-x86_64.AppImage

# Set version and download link for Chromium AppImage
# NOTE: It's recommended to periodically check the GitHub releases page for the latest stable Chromium AppImage:
# https://github.com/ivan-hc/Chromium-Web-Browser-appimage/releases
ENV CHROMIUM_DOWNLOAD_URL="https://github.com/ivan-hc/Chromium-Web-Browser-appimage/releases/download/continuous/Chromium-stable-140.0.7339.127-x86_64.AppImage"

# Update and install necessary packages
RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl wget fuse python3.11-venv libfuse2 python3-xdg libgtk-3-0 \
    libnotify4 libatspi2.0-0 libsecret-1-0 libnss3 desktop-file-utils fonts-noto-color-emoji git ssh-askpass && \
    # Clean up apt cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Update and install dotnet
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends dotnet-sdk-9.0 && \
    # Clean up apt cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download Chromium AppImage and manage permissions
RUN echo "**** install Chromium AppImage ****" && \
    curl --location --output /usr/local/bin/Chromium.AppImage $CHROMIUM_DOWNLOAD_URL && \
    chmod a+x /usr/local/bin/Chromium.AppImage

# Cleanup package install (moved earlier for apt clean up)
RUN apt-get autoclean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# Download Cursor AppImage and manage permissions
RUN curl --location --output Cursor.AppImage $CURSOR_DOWNLOAD_URL && \
    chmod a+x Cursor.AppImage

# Environment variables
ENV CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8443" \
    CUSTOM_USER="" \
    PASSWORD="" \
    SUBFOLDER="" \
    TITLE="Chromium Browser" \
    FM_HOME="/cursor"

# Add local files and Cursor icon
COPY root/ /
COPY cursor_icon.png /cursor_icon.png

# Expose ports and volumes
EXPOSE 8080 8443
VOLUME ["/config","/cursor"]
