# gosted. Docker Image with OpenSSL GOST Engine and Curl


This Docker image is pre-configured with the OpenSSL GOST engine and  curl utility, designed for testing websites that use GOST TLS certificates. Ideal for developers or QA engineers needing a streamlined environment to validate secure connections based on the Russian GOST encryption standard.

### Testing with `curl`

You can use `curl` to test GOST TLS connections by specifying the `--engine gost` option for the OpenSSL engine. Here's an example:


```bash
docker run --rm -i netskol/gosted curl --engine gost -vk https://<server_name>
```
