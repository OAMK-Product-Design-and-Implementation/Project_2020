import requests
import json
import time

from ruuvitag_sensor.ruuvitag import RuuviTag

# Change here your own device's mac-address
macs = ['C1:05:25:89:4A:F0',
        'DD:39:47:16:BA:F5',
        'F7:BE:C3:4A:32:95',
        'EF:12:4E:E0:FC:95']

#These ids are assigned for RuuviTag in the database
ruuviId = ['11','12',"13","14","15"]

macsLenght = len(macs)

postUrl = 'http://195.148.21.106/api/ruuvi/post/doorstatus'
messageUrl = 'http://195.148.21.106/api/devices/post/message'

ruuvi1 = 0
ruuvi2 = 0
ruuvi3 = 0
ruuvi4 = 0

checkMovement = [ruuvi1, ruuvi2, ruuvi3, ruuvi4]

ruuvi1bool = False
ruuvi2bool = False
ruuvi3bool = False
ruuvi4bool = False

firsTimeDetect = [ruuvi1bool, ruuvi2bool, ruuvi3bool, ruuvi4bool]

print('Starting')

for i in range(macsLenght):
        print("Sweep", i)
        mac = macs[i]
        idDevice =  ruuviId[i]

        sensor = RuuviTag(mac)
        data = sensor.update()

        checkMovement[i] = data['movement_counter']
        firsTimeDetect[i] = False

while True:
    for i in range(macsLenght):
        mac = macs[i]
        idDevice =  ruuviId[i]

        sensor = RuuviTag(mac)
        data = sensor.update()

        movement = data['movement_counter']

        #Post if detected movement
        if movement != checkMovement[i]:
            j_file = {
            "OpenOrNot": "1",
            "Door_idDoor": idDevice}

            messageJ_file = {"Messagetype": "Intruder", "Explanation": "Intruder", "Devices_idDevice": idDevice}

            print("Movement detected from", mac)
            checkMovement[i] = movement
            firsTimeDetect[i] = True

            postOne = requests.post(postUrl, json = j_file)
            postMessage = requests.post(messageUrl, json = messageJ_file)

            if postOne.status_code == 200:
                print("Code 200, success!")
            else:
                print("Error", postOne)
                print("The details post was unsuccessful after 1.\n")

            if postMessage.status_code == 200:
                print("Code 200, success!")
            else:
                print("Error", postMessage)
                print("MessagePost was unsuccessful.\n")
            
            #time.sleep(1)
        #If no movement detection
        else:
            if firsTimeDetect[i] == True:
                print("No movement detected with True from", mac)
                
                j_file = {
                "OpenOrNot": "0",
                "Door_idDoor": idDevice}

                print("Posting 0 from", mac)
                checkMovement[i] = movement

                postZero = requests.post(postUrl, json = j_file)

                if postZero.status_code == 200:
                    print("Code 200, success!")
                else:
                    print("Error", postZero)
                    print("The details post was unsuccessful after 0.\n")

                firsTimeDetect[i] = False
                #time.sleep(1)
            else:
                print("No movement detected with False from", mac)
                #time.sleep(1)
