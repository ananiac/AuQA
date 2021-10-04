import smtplib
import os
from email.message import EmailMessage

report_path= os.path.abspath("Reports/report.html")
output_path= os.path.abspath("Reports/output.xml")
log_path= os.path.abspath("Reports/log.html")
template_path= os.path.abspath("ExternalKeywords/emailTemplate.txt")

def attach_file(file_name_with_path,sub_type):
   with open(file_name_with_path, "rb") as file:
      file_content = file.read()
      file_name = file.name
      msg.add_attachment(file_content, maintype="application", subtype=sub_type, filename=file_name)

msg = EmailMessage()
msg['Subject'] = 'This is testemail on 4OCt- plz forward to anania if received'
msg['From'] = 'auqa@vigilent.com'
msg['To'] = 'drkirby@vigilent.com'
msg.set_content("""
                This is the test email sent from AUQA
                Automation suite execution is completed.PFA Reports.
                Detailed test run results are in the folder created by latest date at location http://10.252.9.35/testReports/""")

with open(template_path) as template:
   email_content=template.read()
   msg.set_content(email_content)

attach_file(report_path,".html")
attach_file(output_path,"xml")
attach_file(log_path,"html")

try:
   smtpObj = smtplib.SMTP('172.17.1.70', 25)
   smtpObj.send_message(msg)
   smtpObj.quit()
   print("Successfully sent email")
except Exception:
   print("Error: unable to send email")