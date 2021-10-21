import subprocess
from subprocess import call
import os
from ExternalKeywords import readExcel
import datetime
import sys

#Gets the current date and time
date_format = datetime.datetime.now().strftime("%F_%X")

# path variables
dir_path=os.getcwd()
tc_path=dir_path+'/Testcases'
gt_path=dir_path+'/Testcases/GuardTests'
rp_path=dir_path+'/Reports'
se_path=dir_path+'/ExternalKeywords'

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
        if (command_input[i][h] != None) and  h !="testcase":
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
                    # print(output_xml)
                    xml_to_combine =""
                    for xml in output_xml:
                        xml_to_combine = xml_to_combine+" "+rp_path+"/"+xml
                    # print("value of final xml"+ xml_to_combine)
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
                        execution_command = execution_command + " -T " + gt_path+"/"+test_name[0]+" "+tc_path+"/"+ test_name[1]
                else:
                    execution_command = execution_command + " "+tc_path+"/"+command_input[i][h]
    command_for_execution.append(execution_command)
# print(command_for_execution)

#Fetch the count of pabot process
cmd = 'ps -ef | grep pabot | wc -l'
pabot_output = subprocess.getstatusoutput(cmd)
print(pabot_output)

#check if the pabot process is not running and execute the commands
if (pabot_output[1] <=str(2)):
    print("No automated tests are running so starting the test execution")
    # Executing the testcases and redirecting the output to executionLog.txt
    for i in range(dic_row - 2):
        print("executing the command: " + command_for_execution[i])
        try:
            output_report = subprocess.getstatusoutput(command_for_execution[i])
        except Exception:
            print("Error in testcase execution")
        with open("Reports/executionLog.txt", "a") as logfile:
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
        with open("Reports/executionLog.txt", "a") as logfile:
            for line in output_report[1]:
                fileout = logfile.write(line)
else:
    print("Automated test are running so the test execution is aborted")

#Execute send email
file_name=se_path+"/sendemail.py"
print(file_name)
call(["python3", file_name, suite_name])


