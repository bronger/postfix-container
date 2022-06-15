#!/usr/bin/env python

import smtplib, argparse
from email.message import EmailMessage


parser = argparse.ArgumentParser(description="Send a test mail.")
parser.add_argument("recipient", metavar="TO-ADDRESS", help="email address of the recipient")
parser.add_argument("--sender", metavar="ADDRESS", default="test@example.com",
                    help="email address of the sender (default: test@example.com)")
parser.add_argument("--envelope-sender", metavar="ADDRESS",
                    help="email address of the sender in the envelope (“return path”; default: same as --sender)")
parser.add_argument("--host", default="localhost", help="hostname or IP of the MTA (default: localhost)")
parser.add_argument("--port", default=587, type=int, help="port number of the MTA (default: 587)")
args = parser.parse_args()


message = EmailMessage()
message["Subject"] = "Postfix test"
message["From"] = args.sender
message["To"] = args.recipient
message.set_content("Hello")

s = smtplib.SMTP(args.host, args.port)
s.sendmail(args.envelope_sender or args.sender, [args.recipient], message.as_string())
