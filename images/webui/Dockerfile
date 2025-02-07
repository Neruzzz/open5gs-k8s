# Use the official Node.js 19 image as a parent image
FROM node:19 

COPY source /usr/src/open5gs/webui

WORKDIR /usr/src/open5gs/webui

RUN npm clean-install && \
    npm run build

CMD ["sh", "-c", "tail -f /dev/null"]