# Start from the code-server Debian base image
FROM codercom/code-server:latest 

RUN sudo ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime && export TZ=America/Toronto

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem) + kite
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash
RUN sudo bash -c "$(wget -q -O - https://linux.kite.com/dls/linux/current)"

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment here. Some examples:

RUN code-server --install-extension ms-python.python --force && \
    code-server --install-extension donjayamanne.githistory --force && \
    code-server --install-extension formulahendry.code-runner --force && \
    code-server --install-extension almenon.arepl --force && \
    code-server --install-extension kiteco.kite --force && \
    code-server --install-extension ms-azuretools.vscode-docker --force
RUN sudo apt-get install -y --no-install-recommends python3-venv fluxbox tightvncserver xdg-utils python3-pip \
    nodejs gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 fonts-powerline jq python3-dev \
    libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 wget \
    libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 build-essential libxcb1 libxcomposite1 git-secret \
    libxcursor1 rcm git-secret icdiff libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
    ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release libgbm1 xclip xsel fzf ripgrep \
    dunst suckless-tools compton hsetroot xsettingsd lxappearance xclip byobu xfonts-base xfonts-100dpi xfonts-75dpi && \
    sudo rm -rf /var/lib/apt/lists/*
# RUN COPY myTool /home/coder/myTool

RUN bash -c "$(wget -q -O - https://linux.kite.com/dls/linux/current)"

RUN cd /tmp && \
    wget -q https://launchpad.net/~canonical-chromium-builds/+archive/ubuntu/stage/+build/19746659/+files/chromium-browser_84.0.4147.105-0ubuntu0.16.04.1_amd64.deb && \
    wget -q https://launchpad.net/~canonical-chromium-builds/+archive/ubuntu/stage/+build/19746659/+files/chromium-codecs-ffmpeg_84.0.4147.105-0ubuntu0.16.04.1_amd64.deb && \
    sudo dpkg -i chromium-*.deb && sudo apt-mark hold chromium-browser && sudo apt-mark hold chromium-codecs-ffmpeg && rm chromium-*.deb


COPY requirements.txt .

RUN pip3 install setuptools
RUN pip3 install --no-cache-dir -r requirements.txt
RUN git clone https://github.com/rechka/.dotfiles /home/coder/.dotfiles

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
