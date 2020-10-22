import json
import requests
from collections import defaultdict

filename = 'C:\temp\DevOps_data_set.txt'
months = ['May']
servers = ["BBAOMACBOOKAIR2"]
url = 'https://foo.com/bar'

# Load log data
with open(filename) as file_object:
    lines = file_object.readlines()

table = {}
rowNumber = 1

for line in lines:
	row = ''
	month = line[0:3]
	if month in months:
		row += '00' + line[7:9] + '-' + ('0000' + 
			str(int(line[7:9]) +1))[-4:] + '$' #timeWindow
		deviceName = line[16:31]
		if deviceName in servers:
			row += deviceName.strip() + '$' #deviceName
			row += line[line.index("[") + 1:line.index("]")].strip() \
				+ '$' #processId
			row += line[32:line.index("[")].strip() + '$' #processName
			row += line[line.index("]")+2:].strip() #description
		else:
			row += '$$$'
			row += line[16:].strip() #description
		table[rowNumber] = row
	else:
		table[max(table.keys())] += line.strip() #add description
	
	rowNumber += 1

# aggregate log data
aggregate = defaultdict(list)
for key, value in sorted(table.items()):
    aggregate[value].append(key)

# convert to json
json_object = []
for key, value in aggregate.items():
	item = {}
	item['timeWindow'] = key.split('$')[0]
	item['deviceName'] = key.split('$')[1]
	item['processId'] = key.split('$')[2]
	item['processName'] = key.split('$')[3]
	item['description'] = key.split('$')[4]
	item['numberOfOccurrence'] = len(value)
	json_object.append(item)

# post json data
requests.post(url, data = json.dumps(json_object))


