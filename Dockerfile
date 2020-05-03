# Multi stage

FROM node:alpine as build
WORKDIR /usr/app/frontend
COPY package.json .
RUN npm install
COPY . .
CMD ["npm","run","build"]

FROM nginx
EXPOSE 80
COPY --from=0 /usr/app/frontend/build /usr/share/nginx/html