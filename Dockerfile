FROM debian:buster-slim
LABEL openssl=1.1

RUN set -eux \
  && export OPENSSL_CONF=/etc/ssl/openssl.cnf \
  && apt-get update \
  && apt-get install openssl wget openssl curl -y \
  # get Gost engine deb packet
  && cd /tmp && wget http://ftp.ru.debian.org/debian/pool/main/libe/libengine-gost-openssl1.1/"${GOST_PACKAGE}" \
  && dpkg -i /tmp/"${GOST_PACKAGE}" \
  # enable GOST engine
  && sed -i '/\[openssl_init\]/ a engines = engine_section' "${OPENSSL_CONF}" \
  && echo "engines = engine_section" >> "${OPENSSL_CONF}" \
  && echo "" >> "${OPENSSL_CONF}" \
  && echo "# Engine section" >> "${OPENSSL_CONF}" \
  && echo "[engine_section]" >> "${OPENSSL_CONF}" \
  && echo "gost = gost_section" >> "${OPENSSL_CONF}" \
  && echo "" >> "${OPENSSL_CONF}" \
  && echo "# Engine gost section" >> "${OPENSSL_CONF}" \
  && echo "[gost_section]" >> "${OPENSSL_CONF}" \
  && echo "engine_id = gost" >> "${OPENSSL_CONF}" \
  && echo "dynamic_path = /usr/lib/$(uname -m)-linux-gnu/engines-3/gost.so" >> "${OPENSSL_CONF}" \
  && echo "default_algorithms = ALL" >> "${OPENSSL_CONF}" \
  && echo "CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet" >> "${OPENSSL_CONF}" \
  # clean up
  && apt-get remove --purge --auto-remove -y wget \
  && unset OPENSSL_CONF && unset GOST_PACKAGE \
  && rm -rf /var/lib/apt/lists/* /tmp/*.deb

CMD ["bash"]
