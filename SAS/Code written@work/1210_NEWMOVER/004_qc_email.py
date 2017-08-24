import smtplib
import mimetypes
from email.mime.multipart import MIMEMultipart
from email import encoders
from email.message import Message
from email.mime.audio import MIMEAudio
from email.mime.base import MIMEBase
from email.mime.image import MIMEImage
from email.mime.text import MIMEText
import time

sendfrom = "sendmail@cogensia.com"
sendto = "felixlu@cogensia.com"

msg = MIMEMultipart()
msg["subject"] = "WEEKLY NEW MOVER UPDATE QC"
msg["from"] = sendfrom
msg["to"] = sendto

text = "hello,\n\nnew mover weekly update has been accomplished!\n\nplease see the attachments for qc.\n\nthank you!" 
filename = "/project/CACDIRECT/CODE/DEVELOPMENT/1210_NEWMOVER/LOGS/qc_newmover_update_" + str(time.strftime("%m-%d-%Y")) +".csv"
f = open(filename)

attachment = MIMEText(f.read(),_subtype=None)
attachment.add_header("Content-Disposition", 'attachment', filename=filename)
part1 = MIMEText(text, 'plain')
msg.attach(attachment)
msg.attach(part1)
s=smtplib.SMTP('localhost')
s.sendmail(sendfrom,sendto,msg.as_string())
s.quit()
f.close()
