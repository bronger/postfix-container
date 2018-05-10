Overview
========

This image runs a Postfix in a container that can be connected to locally.  All
mails sent to it are relayed to another HOST which actually sends the mails
into the world.  A typical use case is running the container in a local
cluster, while using your institution's mail relay for sending.  The Postfix
can also add S/MIME signatures to the mails, using
https://github.com/croessner/sigh.

You connect to that server through port 587 (unencryptet, unauthenticated).


Building the Image
==================

::

   docker build -t bronger/postfix .

Docker 1.17 is required.  (For building, not for running.)


Running the image
=================

There are four environment variables:

``RELAY_HOST``
  Domain name of the SMTP server used for actually sending the mail.

``RELAY_PORT``
  Port for contacting the ``RELAY_HOST`` using TLS.  Yes, only login-based TLS is
  supported.  Defaults to 587.

``RELAY_USER``
  Login for the ``RELAY_HOST``.

``RELAY_PASSWORD``
  Password of ``RELAY_USER``.


So, for example, you could say::

  docker run --rm -e RELAY_HOST=smtp.example.com -e RELAY_USER=ralf -e RELAY_PASSWORD=ohmygod \
      bronger/postfix


Signing mails
-------------

If you mount S/MIME certificates into the container, mails from matching
senders are cryptographically signed.  For example,

::

   docker run --rm -e RELAY_HOST=smtp.example.com -e RELAY_USER=ralf -e RELAY_PASSWORD=ohmygod \
      -v mailcerts:/etc/mailcerts
      bronger/postfix

The certificates must be in the directory ``/etc/mailcerts`` in the container,
and they must follow the following naming scheme:

================================= ===========================================================
``ralf-at-example.com_cert.pem``  S/MIME certificate for ``ralf@example.com`` in PEM format
``ralf-at-example.com_chain.pem`` root and intermediate certificates for ``ralf@example.com``
``ralf-at-example.com_key.pem``   secret key for ``ralf@example.com``
================================= ===========================================================

You can place files for as many email addresses as you wish in that folder.
Only if the sender's address matches, the respective S/MIME certificate is used
and the email is signed.
