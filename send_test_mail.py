#!/usr/bin/env python

import smtplib, argparse
from email.message import EmailMessage


parser = argparse.ArgumentParser(description="Send a test mail.")
parser.add_argument("recipient", metavar="TO-ADDRESS", help="email address of the recipient")
parser.add_argument("--sender", metavar="ADDRESS", default="test@example.com",
                    help="email address of the sender (default: test@example.com)")
parser.add_argument("--envelope-sender", metavar="ADDRESS",
                    help="email address of the sender in the envelope (“return path”; default: same as --sender)")
args = parser.parse_args()


message = EmailMessage()
message["Subject"] = "Postfix test"
message["From"] = args.sender
message["To"] = args.recipient
message.set_content("Hello")

s = smtplib.SMTP("postfix.default.svc.cluster.local", 587)
s.sendmail(args.envelope_sender or args.sender, [args.recipient], message.as_string())
