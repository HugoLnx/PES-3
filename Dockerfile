# Based on manual compile instructions at http://wiki.nginx.org/HttpLuaModule#Installation
FROM ubuntu:14.04

ENV VER_NGINX_DEVEL_KIT=0.2.19
ENV VER_LUA_NGINX_MODULE=0.9.16
ENV VER_NGINX=1.7.10
ENV VER_LUAJIT=2.0.4
ENV VER_UPLOAD_MODULE=2.2

ENV NGINX_DEVEL_KIT ngx_devel_kit-${VER_NGINX_DEVEL_KIT}
ENV LUA_NGINX_MODULE lua-nginx-module-${VER_LUA_NGINX_MODULE}
ENV NGINX_ROOT=/nginx
ENV WEB_DIR ${NGINX_ROOT}/html

ENV LUAJIT_LIB /usr/local/lib
ENV LUAJIT_INC /usr/local/include/luajit-2.0

ENV LUAROCKS_VERSION=2.3.0
ENV LIBBSON_VERSION=1.3.5
ENV MONGOC_DRIVER_VERSION=1.3.5

RUN apt-get -qq update
RUN apt-get -qq -y install wget git-core

# ***** BUILD DEPENDENCIES *****

# Common dependencies (Nginx and LUAJit)
RUN apt-get -qq -y install make
# Nginx dependencies
RUN apt-get -qq -y install libpcre3
RUN apt-get -qq -y install libpcre3-dev
RUN apt-get -qq -y install zlib1g-dev
RUN apt-get -qq -y install libssl-dev
# LUAJit dependencies
RUN apt-get -qq -y install gcc
# Lua rocks dependencies
RUN apt-get -qq -y install unzip

# ***** DOWNLOAD AND UNTAR *****

# Download
RUN wget http://nginx.org/download/nginx-${VER_NGINX}.tar.gz
RUN wget http://luajit.org/download/LuaJIT-${VER_LUAJIT}.tar.gz
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v${VER_NGINX_DEVEL_KIT}.tar.gz -O ${NGINX_DEVEL_KIT}.tar.gz
RUN wget https://github.com/openresty/lua-nginx-module/archive/v${VER_LUA_NGINX_MODULE}.tar.gz -O ${LUA_NGINX_MODULE}.tar.gz
#RUN wget https://github.com/vkholodkov/nginx-upload-module/archive/${VER_UPLOAD_MODULE}.tar.gz -O nginx-upload-module-${VER_UPLOAD_MODULE}.tar.gz
RUN git clone -b${VER_UPLOAD_MODULE} https://github.com/vkholodkov/nginx-upload-module.git nginx-upload-module-${VER_UPLOAD_MODULE}

# Untar
RUN tar -xzvf nginx-${VER_NGINX}.tar.gz && rm nginx-${VER_NGINX}.tar.gz
RUN tar -xzvf LuaJIT-${VER_LUAJIT}.tar.gz && rm LuaJIT-${VER_LUAJIT}.tar.gz
RUN tar -xzvf ${NGINX_DEVEL_KIT}.tar.gz && rm ${NGINX_DEVEL_KIT}.tar.gz
RUN tar -xzvf ${LUA_NGINX_MODULE}.tar.gz && rm ${LUA_NGINX_MODULE}.tar.gz
#RUN tar -xzvf nginx-upload-module-${VER_UPLOAD_MODULE}.tar.gz && rm nginx-upload-module-${VER_UPLOAD_MODULE}.tar.gz

# ***** BUILD FROM SOURCE *****

# LuaJIT
WORKDIR /LuaJIT-${VER_LUAJIT}
RUN make
RUN make install

# Nginx with LuaJIT
WORKDIR /nginx-${VER_NGINX}
RUN ./configure --prefix=${NGINX_ROOT} --with-ld-opt="-Wl,-rpath,${LUAJIT_LIB}" --add-module=/${NGINX_DEVEL_KIT} --add-module=/${LUA_NGINX_MODULE} --add-module=/nginx-upload-module-${VER_UPLOAD_MODULE}
RUN make -j2
RUN make install
RUN ln -s ${NGINX_ROOT}/sbin/nginx /usr/local/sbin/nginx



# ***** INSTALLING LUA ROCKS AND ROCKS *****
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

# ***** PROJECT DEPENDENCIES *****
RUN apt-get -qq -y install poppler-utils

RUN luarocks install mongorover
RUN luarocks install lua-resty-session
RUN luarocks install lua-cjson
RUN luarocks install multipart
RUN luarocks install luafilesystem
RUN luarocks install penlight
RUN luarocks install lua-resty-template

# ***** CLEANUP *****
RUN rm -rf /nginx-${VER_NGINX}
RUN rm -rf /LuaJIT-${VER_LUAJIT}
RUN rm -rf /${NGINX_DEVEL_KIT}
RUN rm -rf /${LUA_NGINX_MODULE}
RUN rm -rf /luarocks-${LUAROCKS_VERSION}
RUN rm -rf /libbson-${LIBBSON_VERSION}
RUN rm -rf /mongo-c-driver-${MONGOC_DRIVER_VERSION}

# ***** MISC *****
WORKDIR ${WEB_DIR}
EXPOSE 80
EXPOSE 443
ADD ./ /app
VOLUME /app

CMD ["nginx", "-g", "daemon off;", "-c", "/app/nginx.conf"]
