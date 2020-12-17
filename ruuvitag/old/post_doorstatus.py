import requests
import json
import time
from ruuvitag_sensor.ruuvi_rx import RuuviTagReactive

tags = [
    'C1:05:25:89:4A:F0',
    'DD:39:47:16:BA:F5',
    'EF:12:4E:E0:FC:95'
]

#C1:05:25:89:4A:F0 = ruuvi1
#DD:39:47:16:BA:F5 = ruuvi2
#EF:12:4E:E0:FC:95 = ruuvi3
#ruuvi1 Door_idDoor = 3
#ruuvi2 Door_idDoor = 4
#ruuvi3 Door_idDoor = 5

postUrl = 'http://195.148.21.106/api/ruuvi/post/doorstatus'

ruuvi_rx = RuuviTagReactive()

print('Starting')

def postDoorStatus(Door_idDoor):
    print("Door_idDoor", Door_idDoor)

    j_file = {
            "OpenOrNot": "1",
            "Door_idDoor": Door_idDoor}

    x = requests.post(postUrl, json = j_file)

    if x.status_code == 200:
        print("Code 200, success!")
    else:
        print("Error", x)
        print("The post was unsuccessful.\n")
        time.sleep(1)

#Send OpenOrNot status "1" when ever RuuviTag detects movement

ruuvi_rx.get_subject().\
    filter(lambda x: x[0] == tags[0]).\
    distinct_until_changed(lambda x: x[1]['movement_counter']).\
    subscribe(lambda x: postDoorStatus(3))

ruuvi_rx.get_subject().\
    filter(lambda x: x[0] == tags[1]).\
    distinct_until_changed(lambda x: x[1]['movement_counter']).\
    subscribe(lambda x: postDoorStatus(4))

ruuvi_rx.get_subject().\
    filter(lambda x: x[0] == tags[2]).\
    distinct_until_changed(lambda x: x[1]['movement_counter']).\
    subscribe(lambda x: postDoorStatus(5))