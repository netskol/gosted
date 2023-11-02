FROM debian:bookworm-slim


RUN set -eux \
  && export OPENSSL_CONF=/etc/ssl/openssl.cnf \
  && apt-get update \
  && apt-get install openssl openssl curl libengine-gost-openssl -y \
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
  && unset OPENSSL_CONF  \
  && apt-get purge -y --auto-remove \
  && rm -rf /var/lib/apt/lists/*

CMD ["bash"]
