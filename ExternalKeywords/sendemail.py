   import smtplib
   from email.message import EmailMessage

   msg = EmailMessage()
   msg['Subject'] = 'This is testemail on 4OCt- plz forward to anania if received'
   msg['From'] = 'auqa@vigilent.com'
   msg['To'] = 'drkirby@vigilent.com'
   # msg.set_content(" This is the test email sent from AUQA ")

   def attach_file(file_name_with_path):
      with open(file_name_with_path, "rb") as file:
         file_content = file.read()
         print("file data in binary", file_content)
         file_name = file.name
         print("file name", file_name)
         msg.add_attachment(file_content, maintype="application", subtype=".html", filename=file_name)

   with open('emailTemplate.txt') as template:
      email_content=template.read()
      msg.set_content(email_content)

   attach_file("Reports/report.html")
   attach_file("Reports/log.html")
   attach_file("Reports/output.xml")

   try:
      smtpObj = smtplib.SMTP('172.17.1.70', 25)
      smtpObj.send_message(msg)
      smtpObj.quit()
      print("Successfully sent email")
   except Exception:
      print("Error: unable to send email")