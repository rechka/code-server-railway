# Start from the code-server Debian base image
FROM codercom/code-server:latest 

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment here. Some examples:

RUN code-server --install-extension ms-python.python --force && \
    code-server --install-extension donjayamanne.githistory --force && \
    code-server --install-extension formulahendry.code-runner --force 
RUN sudo apt-get install -y python3-venv python3-pip jq rcm \
    && sudo rm -rf /var/lib/apt/lists/*
# RUN COPY myTool /home/coder/myTool


COPY requirements.txt .

RUN pip3 install --no-cache-dir -r requirements.txt
RUN git clone https://github.com/rechka/.dotfiles /home/coder/.dotfiles

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
