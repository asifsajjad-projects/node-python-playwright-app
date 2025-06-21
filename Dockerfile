FROM node:22

ENV DEBIAN_FRONTEND=noninteractive

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


# Create working dir
WORKDIR /app

# Copy Node app
COPY package*.json ./
RUN npm install

# Copy all app files
COPY . .

# Activate the virtual environment and install Python dependencies
RUN ./venv/bin/activate && \
    pip install -r requirements.txt
    
# Expose the Node app port
EXPOSE 3001

CMD ["node", "index.js"]
