import openpyxl
import os
# from ExternalKeywords import common

auqa_dir= os.path.dirname(os.path.abspath('/home/fc/automation/AuQA/execution.py'))
print(auqa_dir)
fpath= os.path.join(auqa_dir,'Inputs','testInputs.xlsx')
print(fpath)
workbook = openpyxl.load_workbook(fpath)

def read_inputs_from_excel(sheet_name, key_column, value_column):
    ws_column = workbook.get_sheet_by_name(sheet_name)
    excel_inputs = {}
    for k, v in zip(ws_column [key_column], ws_column [value_column]):
        excel_inputs[k.internal_value] = v.internal_value
    return (excel_inputs)

# This function reads the first row of the sheet as the header and pairs it with the subsequent row as the key value pair
def read_command_inputs_from_excel(sheet_name):
    ws= workbook[sheet_name]
    rows= ws.rows
    headers = [cell.value for cell in next(rows)]
    all_rows =[]
    for row in rows:
        excel_command_inputs = {}
        for title, cell in  zip(headers, row):
            excel_command_inputs[title]= cell.value
        all_rows.append(excel_command_inputs)
    return(all_rows)


def get_header(sheet_name):
    ws= workbook[sheet_name]
    rows= ws.rows
    excel_headers = [cell.value for cell in next(rows)]
    return(excel_headers)
