import os

def incrementByOne(counter):
    counter= int(counter)
    counter +=1
    return counter

    #Duplicates of values are not allowed in dict for this sort function
def get_keys_list_after_sorting_dict_by_value(dic):
    sorted_values = sorted(dic.values())  # Sort the values
    sorted_dict = {}
    for i in sorted_values:
        for k in dic.keys():
            if dic[k] == i:
                sorted_dict[k] = dic[k]
                break
    return sorted_dict.keys()

global auqa_dir
auqa_dir= os.path.dirname(os.path.abspath('/home/fc/automation/AuQA/execution.py')) #/home/fc/automation/AuQA/
