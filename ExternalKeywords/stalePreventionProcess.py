import requests
import json
import urllib3
import pandas as pd
urllib3.disable_warnings()

query = """query rackSensorPoints {
            site {
              groups: children(selector: {type: Group,name: "GRP00"}) @skip(if:false) {
                oid name
               racks: children(selector:{type: Rack},){

                  oid
                  displayName
              points: children{
                oid
                name
                  type}
                  }
                }
              }
            }"""
mutation=""" mutation pointWrite { pointWrite(requests: [{oid: ${oid}, value: ${temp}}]) { index reason }}"""
url="https://10.252.9.37/api/public/graphql"
headers = {"Vigilent-Api-Token": "EekHfQugKTtGuy3yWhKt6WN9"}
           #"Content-Type":"application/json"}


def run_query(query): # A simple function to use requests.post to make the API call. Note the json= section.
    request = requests.post('https://10.252.9.37/api/public/graphql',verify=False ,json={'query': query}, headers=headers)
    if request.status_code == 200:
        print(request.status_code)
        print(request.text)
        return request.json()

    else:
        raise Exception("Query failed to run by returning code of {}. {}".format(request.status_code, query))

run_query(query)

result = run_query(query) # Execute the query
remaining_rate_limit = result["data"]["site"]["groups"] # Drill down the dictionary
print("Remaining rate limit - {}".format(remaining_rate_limit))
#json_data = json.loads(r.text)
df_data=result["data"]["site"]["groups"]
df=pd.DataFrame(df_data)