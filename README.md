A thought experiment on storing credential configuration files in a safe way.

Idea
================

Store credential files in a secure blobs that require at least three known
pieces of information in order to get the decrypted files out of the repo.

The three pieces of required information:

  - environment : (eg: prod)
  - filename : (eg: database.yml)
  - secret key


-----------------------------------------------------------------------------

How it Works
============

Each file that needs to be stored in this secure repository should be run
through `pi-encrypt.rb`. This script will encrypt the file and place the
resultant output into a secure file in the `blobs` directory. The blob
filenames are obfuscated to hide the environment and use of the contained
data. Filenames are calculated using `HMAC-SHA1` by concatenating the
environment name (padded) and key, then digesting the filename. The files'
contents are encrypted with `AES128` by using the secret key as key and
concatenating the environment and filename as the IV.

At run time or build time, steps should be taken to gather the necessary
files by calling `pi-decrypt.rb` for each file in the environment and
providing the proper secret key.

Keys for each environment are *NOT* contained in this repository.

-----------------------------------------------------------------------------
