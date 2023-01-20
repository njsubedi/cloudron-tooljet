FROM cloudron/base:4.0.0@sha256:31b195ed0662bdb06a6e8a5ddbedb6f191ce92e8bee04c03fb02dd4e9d0286df

RUN mkdir -p /app/code /app/pkg
WORKDIR /app/code

# Get rid of preinstalled node version, as Tooljet strictly requires node 14.x and npm@7.20.0
RUN sudo rm -rf /usr/local/node-* && \
    curl -L https://deb.nodesource.com/setup_14.x | sudo -E bash - && \
    sudo apt-get install -y --no-install-recommends nodejs \
    curl g++ gcc autoconf automake bison libc6-dev \
    libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev libtool \
    libyaml-dev make pkg-config sqlite3 zlib1g-dev libgmp-dev \
    libreadline-dev libssl-dev libmysqlclient-dev build-essential \
    freetds-dev libpq-dev libaio1 && \
    npm i -g npm@7.20.0

RUN curl -o instantclient-basiclite.zip https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip -SL && \
    unzip instantclient-basiclite.zip && \
    sudo mv instantclient*/ /usr/lib/instantclient && \
    rm instantclient-basiclite.zip && \
    sudo ln -s /usr/lib/instantclient/libclntsh.so.19.1 /usr/lib/libclntsh.so && \
    sudo ln -s /usr/lib/instantclient/libocci.so.19.1 /usr/lib/libocci.so && \
    sudo ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2 && \
    sudo ln -s /lib64/ld-linux-x86-64.so.2 /usr/lib/ld-linux-x86-64.so.2

ENV LD_LIBRARY_PATH="/usr/lib/instantclient"
ENV NODE_ENV=production
ARG TOOLJET_VERSION=develop
ENV NODE_OPTIONS="--max-old-space-size=8192"

## source (https://github.com/ToolJet/ToolJet/)
RUN curl -L https://github.com/ToolJet/ToolJet/archive/${TOOLJET_VERSION}.tar.gz | tar -xz -C /app/code --strip-components 1 -f -

RUN npm install -g n && n 14.17.3 && npm i -g npm@7.20.0

# Build plugins
RUN node -v && npm -v && npm --prefix plugins install && \
    NODE_ENV=production npm --prefix plugins run build && \
    npm --prefix plugins prune --production

RUN npm --prefix frontend install && \
    npm --prefix frontend uninstall webpack-cli && \
    npm --prefix frontend install --dev webpack-cli && \
    npm --prefix frontend run build --verbose && \
    npm --prefix frontend prune --production

RUN npm install -g @nestjs/cli && \
    npm --prefix server install && \
    npm --prefix server run build --verbose

RUN npm install dotenv@10.0.0 joi@17.4.1

# Replace the paths in frontend module. Tooljet tries to do this at runtime; failing to do so in Read-only system.
# https://github.com/ToolJet/ToolJet/blob/1bd3e10a701c9cd5320fa5f4b48857e041264be9/server/src/app.module.ts#L114
RUN sed -i -e 's;__REPLACE_SUB_PATH__/api;/api;g' -e 's;__REPLACE_SUB_PATH__;/;g' /app/code/frontend/build/index.html && \
    sed -i -e 's;__REPLACE_SUB_PATH__/api;/api;g' -e 's;__REPLACE_SUB_PATH__;;g' /app/code/frontend/build/runtime.js && \
    sed -i -e 's;__REPLACE_SUB_PATH__/api;/api;g' -e 's;__REPLACE_SUB_PATH__;;g' /app/code/frontend/build/main.js

ADD start.sh /app/pkg/

RUN ln -s /app/data/env /app/code/.env

CMD [ "/app/pkg/start.sh" ]

