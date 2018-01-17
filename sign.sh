#!/bin/bash

SENDMAIL="/usr/sbin/sendmail -G -i"
CERTS="/etc/mailcerts"
EX_UNAVAILABLE=69
SENDER="$2"
RECIPIENT="$4"
SENDER_ESCAPED=`echo -n "$SENDER" | sed s/@/-at-/`
RECIPIENT_ESCAPED=`echo -n "$RECIPIENT" | sed s/@/-at-/`
if [ -f "$CERTS/${SENDER_ESCAPED}_cert.pem" -a -f "$CERTS/${SENDER_ESCAPED}_key.pem" ]
then
    MESSAGEFILE="/tmp/message.$$"
#    trap "rm -f $MESSAGEFILE; rm -f $MESSAGEFILE.signed" 0 1 2 3 15
    umask 077
    cat > $MESSAGEFILE || { echo "Cannot save mail to file"; exit $EX_UNAVAILABLE; }
    HOME=/home/filter openssl smime -sign -in $MESSAGEFILE -out $MESSAGEFILE.signed \
            -signer "$CERTS/${SENDER_ESCAPED}_cert.pem" -inkey "$CERTS/${SENDER_ESCAPED}_key.pem" \
        || { echo Problem signing message; exit $EX_UNAVAILABLE; }
    # if [ -f "$CERTS/${RECIPIENT_ESCAPED}_cert.pem" ]
    # then
    #     SUBJECT=$(reformail -x "Subject:" < $MESSAGEFILE)
    #     HOME=/home/filter openssl smime -encrypt -des3 -out $MESSAGEFILE.signed \
    #             -from "$SENDER" -to "$RECIPIENT" -subject "$SUBJECT" \
    #             "$CERTS/${RECIPIENT_ESCAPED}_cert.pem" < $MESSAGEFILE \
    #         || { echo "Problem encrypting message"; exit $EX_UNAVAILABLE; }
    # fi
    $SENDMAIL "$@" < $MESSAGEFILE.signed
    exit $?
else
    cat | $SENDMAIL "$@"
    exit $?
fi
