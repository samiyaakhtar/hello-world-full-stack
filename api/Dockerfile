FROM node:11-alpine

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY package.json ./
COPY yarn.lock ./

RUN yarn

COPY . /usr/src/app
COPY bin /usr/src/app/bin

EXPOSE 9000

CMD ["yarn", "start"]