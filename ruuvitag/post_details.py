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

postUrl_details = 'http://195.148.21.106/api/ruuvi/post/details'
postUrl_battery = 'http://195.148.21.106/api/devices/post/battery'

print('Starting')

time_to_sleep = 900

while True:
    for i in range(macsLenght):
        mac = macs[i]
        idDevice =  ruuviId[i]

        sensor = RuuviTag(mac)
        data = sensor.update()

        temperature = data['temperature']
        humidity = data['humidity']
        pressure = data['pressure']
        batteryData = data['battery']

        #Convert mV to percent by referring to 3.3V
        batteryPer = batteryData / 3300 * 100

        j_file_details = {
            "Devices_idDevice": idDevice,
            "Temperature": temperature,
            "Humidity": humidity,
            "AirPressure": pressure}

        j_file_battery = {
            "BatteryStatus": batteryPer,
            "Devices_idDevice": idDevice}

        print("macAddr", mac)

        detailsReq = requests.post(postUrl_details, json = j_file_details)
        batteryReq = requests.post(postUrl_battery, json = j_file_battery)

        if detailsReq.status_code == 200:
            print("Code 200, success!")
        else:
            print("Error", detailsReq)
            print("The details post was unsuccessful.\n")
            time.sleep(1)
        
        if batteryReq.status_code == 200:
            print("Code 200, success!")
        else:
            print("Error", batteryReq)
            print("The battery post was unsuccessful.\n")
            time.sleep(1)
    else:
        print("Sleep", time_to_sleep, "sec")
        time.sleep(time_to_sleep)
