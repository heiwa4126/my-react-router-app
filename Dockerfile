FROM node:22-bookworm-slim AS development-dependencies-env
COPY . /app
WORKDIR /app
RUN [ -f package-lock.json ] && npm ci || npm i

FROM node:22-bookworm-slim AS production-dependencies-env
COPY --from=development-dependencies-env /app/package-lock.json /app/package.json /app/
WORKDIR /app
RUN npm ci --omit=dev

FROM node:22-bookworm-slim AS build-env
COPY . /app/
COPY --from=development-dependencies-env /app/package-lock.json /app/
COPY --from=development-dependencies-env /app/node_modules /app/node_modules
WORKDIR /app
RUN npm run build

# FROM node:22-bookworm-slim
# FROM gcr.io/distroless/nodejs22-debian12:debug
FROM gcr.io/distroless/nodejs22-debian12
COPY --from=development-dependencies-env /app/package.json /app/package-lock.json /app/
COPY --from=production-dependencies-env /app/node_modules /app/node_modules
COPY --from=build-env /app/build /app/build
WORKDIR /app
# CMD ["npm", "run", "start"]
CMD ["./node_modules/.bin/react-router-serve", "./build/server/index.js"]
