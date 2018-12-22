FROM debian:buster-slim
LABEL maintainer="ROMAN1485 <roman1485@gmail.com>"

RUN set -eux \
   && export OPENSSL_CONF=/etc/ssl/openssl.cnf && export GOST_ENGINE_VERSION=1.1.0.3 \
   && ARCHI="$(dpkg --print-architecture)" \
   && case "${ARCHI##*-}" in \
        armhf) export ENGINE_DIR="/usr/lib/arm-linux-gnueabihf/engines-1.1";; \
        amd64) export ENGINE_DIR="/usr/lib/x86_64-linux-gnu/engines-1.1";; \
            *) echo >&2 "Warning: Edit Dockerfile and set openssl engine path for your architechture";; \ 
      esac \
   && apt-get update  \
   && apt-get install --no-install-recommends --no-install-suggests -y apt-transport-https wget git curl build-essential  cmake unzip ca-certificates openssl libssl-dev  \
   && cd /usr/local/src \
   && wget "https://github.com/gost-engine/engine/archive/v${GOST_ENGINE_VERSION}.zip" \
   && unzip "v${GOST_ENGINE_VERSION}.zip" \
   && cd "engine-${GOST_ENGINE_VERSION}" \
   && mkdir build \
   && cd build \
   && cmake -DCMAKE_BUILD_TYPE=Release .. \
   && cmake --build . --config Release \
   && cp ../bin/gost.so ${ENGINE_DIR} \
   ##clean-up
   && apt-get remove --purge --auto-remove -y apt-transport-https wget git build-essential unzip cmake ca-certificates libssl-dev \
   && cd ~ && rm -rf /var/lib/apt/lists/* /usr/local/src/* \ 
   # enable GOST engine
   && sed -i '20i openssl_conf=openssl_def' "${OPENSSL_CONF}" \
   && echo "" >> "${OPENSSL_CONF}" \
   && echo "# OpenSSL default section" >> "${OPENSSL_CONF}" \
   && echo "[openssl_def]" >> "${OPENSSL_CONF}" \
   && echo "engines = engine_section" >> "${OPENSSL_CONF}" \
   && echo "" >> "${OPENSSL_CONF}" \
   && echo "[engine_section]" >> "${OPENSSL_CONF}" \
   && echo "gost = gost_section" >> "${OPENSSL_CONF}" \
   && echo "" >> "${OPENSSL_CONF}" \
   && echo "[gost_section]" >> "${OPENSSL_CONF}" \
   && echo "engine_id = gost" >> "${OPENSSL_CONF}" \
   && echo "dynamic_path = ${ENGINE_DIR}/gost.so" >> "${OPENSSL_CONF}" \
   && echo "default_algorithms = ALL" >> "${OPENSSL_CONF}" \
   && echo "CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet" >> "${OPENSSL_CONF}" \
   && unset OPENSSL_CONF GOST_ENGINE_VERSION ENGINE_DIR 

CMD ["bash"]
