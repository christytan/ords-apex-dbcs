#######################################################################
#                            IMPORT SECTION                           #
#######################################################################

import sys
import simplejson as json
import requests

#######################################################################
#                               TWEET LOAD SECTION                       #
#######################################################################

post_rest_endpoint=sys.argv[1]

data = []
files=sys.argv[2]
with open(files,"r", encoding='utf-8') as f:
        for line in f:
                data.append(json.loads(line))

totalRecords=len(data)
s = requests.Session()
failure_counts = 0
for i in data:
        try:
                i = json.dumps(i)
                r = s.post(post_rest_endpoint,data=i)

                if r.status_code!= 200:
                        failure_counts +=1
        except BaseException as e:
                print("Error on_data: %s" % str(e))
                break
print("Total Tweets inserted = ",totalRecords-failure_counts)
