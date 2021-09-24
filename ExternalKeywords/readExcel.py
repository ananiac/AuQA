import openpyxl
import os

fpath= os.path.abspath("Inputs/testInputs.xlsx")
workbook = openpyxl.load_workbook(fpath)

def readBasicHotAbsoluteGuardInputsFromExcel():
    ws_column = workbook.worksheets[0]
    basicHotAbsoluteGuardInputs = {}
    for k, v in zip(ws_column ['A'], ws_column ['B']):
        basicHotAbsoluteGuardInputs[k.internal_value] = v.internal_value
    return (basicHotAbsoluteGuardInputs)
