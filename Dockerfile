FROM node:22

ENV DEBIAN_FRONTEND=noninteractive

# # Install Python 3.12, venv, and Playwright deps
# RUN apt-get update && \
#     apt-get install -y curl gnupg build-essential wget unzip git \
#     ca-certificates python3.12 python3.12-venv python3.12-distutils \
#     software-properties-common ffmpeg libnss3 libatk1.0-0 libatk-bridge2.0-0 \
#     libxcomposite1 libxdamage1 libxrandr2 libgbm1 libasound2 libxss1 libgtk-3-0 \
#     && ln -s /usr/bin/python3.12 /usr/bin/python3 && \
#     apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt update && \
apt install -y \
curl \
gnupg \
build-essential \
wget \
unzip \
git \
ca-certificates \
software-properties-common \
ffmpeg \
libnss3 \
libatk1.0-0 \
libatk-bridge2.0-0 \
libxcomposite1 \
libxdamage1 \
libxrandr2 \
libgbm1 \
libasound2 \
libxss1 \
libgtk-3-0

RUN apt update && \
    apt install -y python3 python3-venv python3-pip

# Create the python virtual environment
RUN python3 -m venv /venv

# Install pip for Python 3.12
# RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Create working dir
WORKDIR /app

# Copy Node app
COPY package*.json ./
RUN npm install

# create a virtual environment for Python
# RUN python3 -m venv .venv

# # Activate the virtual environment and install Python dependencies
# RUN . .venv/bin/activate && \
#     pip install browser-use && \
#     pip install "browser-use[memory]"

# Install Playwright and its dependencies
# RUN npx playwright install chromium --with-deps --no-shell

# Copy all app files
COPY . .

# Activate the virtual environment and install Python dependencies
RUN ./venv/bin/activate && \
    pip install -r requirements.txt
    
# Expose the Node app port
EXPOSE 3001

CMD ["node", "index.js"]
