FROM node:alpine
WORKDIR /usr/app/frontend
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

FROM nginx
EXPOSE 80
COPY --from=0 /usr/app/frontend/build /usr/share/nginx/html
