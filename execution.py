import subprocess
from subprocess import call
import os
from ExternalKeywords import readExcel
import datetime
import sys

#Gets the current date and time
date_format = datetime.datetime.now().strftime("%F_%X")

# path variables
auqa_dir= os.path.dirname(os.path.abspath('/home/fc/automation/AuQA/execution.py'))
tc_path=os.path.join(auqa_dir,'Testcases')
gt_path=os.path.join(auqa_dir,'Testcases','GuardTests')
ot_path=os.path.join(auqa_dir,'Testcases','OverrideTests')
pt_path=os.path.join(auqa_dir,'Testcases','UITests')
rp_path=os.path.join(auqa_dir,'Reports')
se_path=os.path.join(auqa_dir,'ExternalKeywords')
log_file=os.path.join(auqa_dir,'Reports','executionLog.txt')

#Suitename sent from the command line which is same as the excel sheet name for suite
suite_name = sys.argv[1]


# Reading the excel as dictionary and fetching the rows and column header as key value pair
command_input={}
command_input= readExcel.read_command_inputs_from_excel(suite_name)
header= readExcel.get_header(suite_name)
dic_row =len(command_input)

#Formulating the commands from excel inputs
command_for_execution =[]
for i in range(dic_row):
    execution_command =""
    for h in header:
        if (command_input[i][h] != None) and  h !="testcase" and command_input[i]['runmode'] == "yes":
            if(h == "command"):
                execution_command = execution_command + command_input[i][h]
            elif(h == "name" ):
                execution_command = execution_command + " --name"+" '"+command_input[i][h]+"_"+date_format+"' "
            elif(h == "reporttitle"):
                execution_command = execution_command + " --reporttitle" + ' "' +command_input[i][h]+ '" '
            elif (h == "output dir"):
                execution_command = execution_command + " --outputdir " + command_input[i][h]
            elif (h == "output"):
                if (command_input[i]['testcase'] =="combinereport") and (".xml/" in command_input[i][h]):
                    output_xml = (command_input[i][h]).split("/")
                    xml_to_combine =""
                    for xml in output_xml:
                        xml_to_combine = xml_to_combine+" "+os.path.join(rp_path,xml)
                    execution_command = execution_command + " --output output.xml "+xml_to_combine
                else:
                    execution_command = execution_command + " --output " + command_input[i][h]
            elif (h == "environment"):
                execution_command = execution_command + " --variable " +"environment:"+ command_input[i][h]
            elif (h == "groupname"):
                execution_command = execution_command + " -v " + "groupname:" + command_input[i][h]
            elif (h == "testname"):
                if ".robot/" in command_input[i][h]:
                    test_name=(command_input[i][h]).split("/",1)
                if(command_input[i]['testcase'] !="cleanReports" and command_input[i]['testcase'] !="moveReports" ):
                    if("Guard" in command_input[i]['testcase']):
                        execution_command = execution_command + " -T " + os.path.join(gt_path ,test_name[0]) + " " + os.path.join(tc_path, test_name[1])
                    elif ("Override" in command_input[i]['testcase']):
                        execution_command = execution_command + " -T " + os.path.join(ot_path, test_name[0]) + " " + os.path.join(tc_path, test_name[1])
                    elif ("Popup" in command_input[i]['testcase']):
                        execution_command = execution_command + " -T " + os.path.join(pt_path, test_name[0])
                else:
                    execution_command = execution_command + " " + os.path.join(tc_path, command_input[i][h])
    command_for_execution.append(execution_command)
    # print(execution_command)
#Fetch the count of pabot process
cmd = 'ps -ef | grep pabot | wc -l'
pabot_output = subprocess.getstatusoutput(cmd)
pabot_count = int(pabot_output[1])
print("count of pabot process is: "+str(pabot_count))

#check if the pabot process is not running and execute the commands
if (pabot_count <=2):
    print("No automated tests are running so starting the test execution")
    # Executing the testcases and redirecting the output to executionLog.txt
    for i in range(dic_row - 2):
        print("executing the command: " + command_for_execution[i])
        try:
            output_report = subprocess.getstatusoutput(command_for_execution[i])
        except Exception:
            print("Error in testcase execution")
        with open(log_file, "a") as logfile:
            for line in output_report[1]:
                fileout = logfile.write(line)
    #rebot command has to be separated from the loop of test execution else creates issue while combining the xml
    #Executing the rebot to combine the output xml  and move the reports folder to testReports
    for x in range(dic_row-2, dic_row):
        print("executing the command: " + command_for_execution[x])
        try:
            output_report = subprocess.getstatusoutput(command_for_execution[x])
        except Exception:
            print("Error in command execution")
        with open(log_file, "a") as logfile:
            for line in output_report[1]:
                fileout = logfile.write(line)
    # Execute send email
    file_name = os.path.join(se_path, "sendemail.py")
    print(file_name)
    call(["python3", file_name, suite_name])
else:
    print("Automated tests are running so the current test execution is aborted")
    # Execute send email
    file_name = os.path.join(se_path, "sendemailNoExecution.py")
    print(file_name)
    call(["python3", file_name, suite_name])



