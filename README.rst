Overview
========

This image runs a Postfix in a container that can be connected to from locally
running containers or programs.  All mails sent to it are relayed to another
HOST which actually sends the mails into the world.  A typical use case is
running the container in a local cluster, while using your institution’s mail
relay for sending.  The Postfix can also add S/MIME signatures to the mails,
using https://github.com/croessner/sigh.

You connect to that server through port 587 (unencryptet, unauthenticated).


Building the Image
==================

::

   docker build -t bronger/postfix .

Docker 1.17 is required.  (For building, not for running.)


Running the image
=================

There are five environment variables:

``RELAY_HOST``
  Domain name of the SMTP server used for actually sending the mail.

``RELAY_PORT``
  Port for contacting the ``RELAY_HOST`` using TLS.  Yes, only login-based TLS is
  supported.  Defaults to 587.

``RELAY_USER``
  Login for the ``RELAY_HOST``.

``RELAY_PASSWORD``
  Password of ``RELAY_USER``.

``TZ``
  Timezone to use.  This is ``UTC`` by default, but may be ``Europe/Berlin``.

``LOG_OUTPUT``
  Whether Postfix, or Sigh, or both should log to stdout.  It is a
  space-separated list of names.  Allowed are the names “postfix” and “sigh”.
  Defaults to ``postfix sigh``, i.e. both.  Mind to quote it properly,
  depending on context.

``POSTFIX_EXTRA_DNS_NAMES``
  Space-separated list of additional DNS names for the self-signed certificate
  for Postfix.  “postfix” is always set, but by using this environment
  variable, you can add e.g. ``postfix.default.svc.cluster.local``.


So, for example, you could say::

  docker run --rm -e RELAY_HOST=smtp.example.com -e RELAY_USER=ralf -e RELAY_PASSWORD=ohmygod \
      bronger/postfix


Signing mails
-------------

If you mount S/MIME certificates into the container, mails from matching
senders are cryptographically signed.  For example,

::

   docker run --rm -e RELAY_HOST=smtp.example.com -e RELAY_USER=ralf -e RELAY_PASSWORD=ohmygod \
      -v mailcerts:/etc/mailcerts bronger/postfix

The certificates must be in the directory ``/etc/mailcerts`` in the container,
and they must follow the following naming scheme:

================================= ===========================================================
``ralf-at-example.com_cert.pem``  S/MIME certificate for ``ralf@example.com`` in PEM format
``ralf-at-example.com_chain.pem`` root and intermediate certificates for ``ralf@example.com``
``ralf-at-example.com_key.pem``   secret key for ``ralf@example.com``
================================= ===========================================================

You can place files for as many email addresses as you wish in that folder.
Only if the sender’s address matches, the respective S/MIME certificate is used
and the email is signed.


Kubernetes
==========

For Kubernetes, you can split it into two containers, running in a pod, like
this:

.. code-block:: yaml

    kind: Deployment
    …
        spec:
          containers:
            - name: postfix
              image: bronger/postfix
              command: [/opt/entrypoints/entrypoint-postfix.sh]
              ports:
                - containerPort: 587
              env:
                - name: RELAY_HOST
                  value: …
                - name: RELAY_PORT
                  value: …
                - name: RELAY_USER
                  value: …
                - name: RELAY_PASSWORD
                  value: …
                - name: TZ
                  value: …
                - name: POSTFIX_EXTRA_DNS_NAMES
                  value: postfix.default.svc.cluster.local
            - name: sigh
              image: bronger/postfix
              command: [/opt/entrypoints/entrypoint-sigh.sh]
              env:
                - name: TZ
                  value: …
              volumeMounts:
                - name: smime-certificates
                  mountPath: /etc/mailcerts
          …

Do always include the Sigh container, even if you don’t need signing.
