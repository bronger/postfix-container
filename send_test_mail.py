#!/usr/bin/python3

import smtplib
from email.mime.text import MIMEText

title = 'My title'
msg_content = '<h2>{title} > <font color="green">OK</font></h2>\n'.format(title=title)
message = MIMEText(msg_content, 'html')
message['From'] = 'juser@fz-juelich.de'
message['To'] = 't.bronger@fz-juelich.de'
message['Subject'] = 'Any subject'
msg_full = message.as_string()
s = smtplib.SMTP("mail-juser", 587)
s.sendmail("juser@fz-juelich.de", ["t.bronger@fz-juelich.de"], msg_full)
