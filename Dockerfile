FROM danday74/nginx-lua

ENV LUAROCKS_VERSION=2.3.0
ENV LIBBSON_VERSION=1.3.5
ENV MONGOC_DRIVER_VERSION=1.3.5

WORKDIR /

RUN wget http://keplerproject.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz
RUN wget https://github.com/mongodb/libbson/releases/download/${LIBBSON_VERSION}/libbson-${LIBBSON_VERSION}.tar.gz
RUN wget https://github.com/mongodb/mongo-c-driver/releases/download/${MONGOC_DRIVER_VERSION}/mongo-c-driver-${MONGOC_DRIVER_VERSION}.tar.gz

RUN tar -xzvf luarocks-${LUAROCKS_VERSION}.tar.gz && rm luarocks-${LUAROCKS_VERSION}.tar.gz
RUN tar -xzvf libbson-${LIBBSON_VERSION}.tar.gz && rm libbson-${LIBBSON_VERSION}.tar.gz
RUN tar -xzvf mongo-c-driver-${MONGOC_DRIVER_VERSION}.tar.gz && rm mongo-c-driver-${MONGOC_DRIVER_VERSION}.tar.gz


WORKDIR /luarocks-${LUAROCKS_VERSION}
RUN ./configure --lua-suffix=jit --with-lua-include=/usr/local/include/luajit-2.0
RUN make build
RUN make install

WORKDIR /libbson-${LIBBSON_VERSION}
RUN ./configure
RUN make
RUN make install

WORKDIR /mongo-c-driver-${MONGOC_DRIVER_VERSION}
RUN ./configure
RUN make
RUN make install


RUN apt-get update && apt-get install unzip

RUN luarocks install mongorover
RUN luarocks install lua-resty-session

WORKDIR ${WEB_DIR}

RUN rm -rf /luarocks-${LUAROCKS_VERSION}
RUN rm -rf /libbson-${LIBBSON_VERSION}
RUN rm -rf /mongo-c-driver-${MONGOC_DRIVER_VERSION}

ADD ./ /app
VOLUME /app

CMD ["nginx", "-g", "daemon off;", "-c", "/app/nginx.conf"]
