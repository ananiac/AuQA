   import smtplib
   from email.message import EmailMessage

   msg = EmailMessage()
   msg['Subject'] = 'This is testemail on 4OCt- plz forward to anania if received'
   msg['From'] = 'auqa@vigilent.com'
   msg['To'] = 'drkirby@vigilent.com'
   # msg.set_content(" This is the test email sent from AUQA ")

   with open('emailTemplate.txt') as template:
      email_content=template.read()
      msg.set_content(email_content)

   try:
      smtpObj = smtplib.SMTP('172.17.1.70', 25)
      smtpObj.send_message(msg)
      smtpObj.quit()
      print("Successfully sent email")
   except Exception:
      print("Error: unable to send email")