# Base docker image
FROM node:current-alpine

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.description="Docker image based on Alpine Linux that provides both Node.js and Chromium for headless testing of JavaScript applications (e.g. Angular)." \
      org.label-schema.name="alpine-node-chromium" \
      org.label-schema.schema-version="1.0.0" \
      org.label-schema.usage="https://github.com/BjoernKW/alpine-node-chromium/blob/master/README.md" \
      org.label-schema.vcs-url="https://github.com/BjoernKW/alpine-node-chromium" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vendor="Björn Wilmsmann IT Services - BjoernKW: https://bjoernkw.com/" \
      org.label-schema.version="latest"

LABEL name="chrome-headless" \
      maintainer="" \
      version="2.0" \
      description=""

RUN echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
    && echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
    && apk add --force-broken-world --no-cache \
    libstdc++@edge \
    chromium@edge \
    harfbuzz@edge \
    nss@edge \
    freetype@edge \
    ttf-freefont@edge \
    && rm -rf /var/cache/* \
    && mkdir /var/cache/apk

# Add Chrome as a user
RUN mkdir -p /usr/src/app \
    && adduser -D chrome \
    && chown -R chrome:chrome /usr/src/app \
    && chown chrome:chrome /usr/local/lib/node_modules \
    && chown chrome:chrome /usr/local/bin

# Run Chrome as non-privileged user
USER chrome

ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/

COPY ./chrome.json /home/chrome/chrome.json

ENTRYPOINT ["chromium-browser", "--no-sandbox",  "--headless", "--disable-gpu", "--disable-software-rasterizer", "--disable-dev-shm-usage", "--disable-sync", "--disable-translate", "--disable-background-networking", "--disable-extensions", "--remote-debugging-address=0.0.0.0", "--remote-debugging-port=9222", "https://www.chromestatus.com"]
