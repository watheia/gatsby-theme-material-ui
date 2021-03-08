FROM node:14 as builder

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get upgrade -qy && \
    apt-get -qy install xorg xvfb gtk2-engines-pixbuf && \
    apt-get -qy install dbus-x11 xfonts-base xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable && \
    apt-get -qy install imagemagick x11-apps && \
    Xvfb -ac :99 -screen 0 1024x768 & export DISPLAY=:99

WORKDIR /home/builder
ADD . .
RUN yarn && yarn workspace www build

FROM node:14-alpine

RUN apk update

# Copy built files
COPY --from=builder /home/builder/www/public /app
# COPY --from=builder /home/builder/packages/screenplay/target/site/serenity/ /app/screenplay/

EXPOSE 5000
CMD ["npx", "serve", "/app"]
