import smtplib
import sys
from email.message import EmailMessage

# Suitename sent from the command line
suite_name = sys.argv[1]

# Sending email for no execution
msg = EmailMessage()
msg['Subject'] = 'AuQA test run result of ' + suite_name
msg['From'] = 'auqa@vigilent.com'
msg['To'] = 'AuQaTeam@vigilent.com'
msg.set_content("""
        Hello Team,

                Automated tests are running so the current test execution of """ + suite_name + """ is aborted
        Thanks,
        AuQA Team""")

try:
    smtpObj = smtplib.SMTP('172.17.1.70', 25)
    smtpObj.send_message(msg)
    smtpObj.quit()
    print("Successfully sent email")
except Exception:
    print("Error: unable to send email")