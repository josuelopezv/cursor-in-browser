FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# Set version, display and download link for Cursor
ENV DISPLAY=:1
ENV CURSOR_DOWNLOAD_URL=https://downloads.cursor.com/production/6af2d906e8ca91654dd7c4224a73ef17900ad735/linux/x64/Cursor-1.6.26-x86_64.AppImage

# Update and install necessary packages
RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl wget fuse python3.11-venv libfuse2 python3-xdg libgtk-3-0 \
    libnotify4 libatspi2.0-0 libsecret-1-0 libnss3 desktop-file-utils fonts-noto-color-emoji git ssh-askpass xdg-utils \
    fonts-liberation && \
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

# Install Google Chrome Stable and configure xdg-open
RUN echo "**** install Google Chrome Stable ****" && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome-stable_current_amd64.deb && \
    dpkg -i /tmp/google-chrome-stable_current_amd64.deb || apt-get install -y --no-install-recommends -f && \
    rm /tmp/google-chrome-stable_current_amd64.deb && \
    # Configure xdg-open to use google-chrome
    # Ensure google-chrome is in the alternatives for x-www-browser
    update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/google-chrome 200 && \
    # Set google-chrome as the default browser for http and https schemes
    xdg-settings set default-web-browser google-chrome.desktop

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
    TITLE="Cursor Ai Web" \
    FM_HOME="/cursor"

# Add local files and Cursor icon
COPY root/ /
COPY cursor_icon.png /cursor_icon.png

# Expose ports and volumes
EXPOSE 8080 8443
VOLUME ["/config","/cursor"]
