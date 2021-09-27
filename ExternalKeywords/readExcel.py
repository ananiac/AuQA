import openpyxl
import os

fpath= os.path.abspath("Inputs/testInputs.xlsx")
workbook = openpyxl.load_workbook(fpath)

def read_inputs_from_excel(sheet_index, key_column, value_column):
    ws_column = workbook.worksheets[int(sheet_index)]
    excel_inputs = {}
    for k, v in zip(ws_column [key_column], ws_column [value_column]):
        excel_inputs[k.internal_value] = v.internal_value
    return (excel_inputs)

