import smtplib
import os
import sys
import subprocess
import pathlib
from email.message import EmailMessage

auqa_dir= os.path.dirname(os.path.abspath('/home/fc/automation/AuQA/execution.py'))
report_path= os.path.join(auqa_dir,'Reports','report.html')

#Fetch the ip address of host machine
ipaddress= (subprocess.check_output(['hostname', '-s', '-I']).decode('utf-8')[:-1]).strip()

#Suitename sent from the command line
suite_name = sys.argv[1]

# Fetch the latest folder in testReports folder
latest= max(pathlib.Path("/home/fc/automation/testReports").glob('*/'), key=os.path.getmtime)
latest_folder = os.path.split(latest)[1]

#Sending email with the message and attachment
msg = EmailMessage()
msg['Subject'] = 'AuQA test run result of '+suite_name
msg['From'] = 'auqa@vigilent.com'
msg['To'] = 'AuQaTeam@vigilent.com'
msg.set_content("""
		Hello Team,

                Automation suite execution of """+suite_name+""" is completed.PFA Reports.
                Detailed test run results are placed in the folder """+latest_folder+" at location http:/"+ipaddress+"""/testReports/

		Thanks,
		AuQA Team""")

with open(report_path, "rb") as file:
    file_content = file.read()
    file_name = file.name
    msg.add_attachment(file_content, maintype="application", subtype=".html", filename=file_name)

try:
    smtpObj = smtplib.SMTP('172.17.1.70', 25)
    smtpObj.send_message(msg)
    smtpObj.quit()
    print("Successfully sent email")
except Exception:
    print("Error: unable to send email")