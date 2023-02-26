Run:

```
docker run --rm -it --entrypoint="" linuxserver/openssh-server sh -c \
  "echo 3 | /keygen.sh > grep -A1 'PRIVATE KEY'" > my_keys.pem
```

to generate ed25519 asymmetric encryption key pairs.

Then in private GitHub repo -> Settings -> Deploy keys -> Add deploy key and copy public key found in my_keys.pem to here and remove it from the file.

Use the my_keys.pem in a container that needs access to this repo.
