# Build the dashboard and serve it with nginx.
#   docker build -t safarichap-admin \
#     --build-arg API_URL=https://api.safarichap.co.tz \
#     --build-arg FIREBASE_WEB_API_KEY=... --build-arg FIREBASE_WEB_APP_ID=... .
#   docker run -p 8081:80 safarichap-admin
FROM ghcr.io/cirruslabs/flutter:3.44.8 AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
ARG API_URL=https://api.safarichap.co.tz
ARG FIREBASE_WEB_API_KEY=
ARG FIREBASE_WEB_APP_ID=
RUN dart run build_runner build --delete-conflicting-outputs \
 && flutter build web --release \
      --dart-define=API_URL=${API_URL} \
      --dart-define=FIREBASE_WEB_API_KEY=${FIREBASE_WEB_API_KEY} \
      --dart-define=FIREBASE_WEB_APP_ID=${FIREBASE_WEB_APP_ID}

FROM nginx:1.27-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/security_headers.conf /etc/nginx/snippets/security_headers.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
