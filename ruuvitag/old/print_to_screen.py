import os
from datetime import datetime

from ruuvitag_sensor.ruuvi import RuuviTagSensor

# Change here your own device's mac-address
mac = 'C1:05:25:89:4A:F0'
#mac = 'DD:39:47:16:BA:F5'
#mac = 'EF:12:4E:E0:FC:95'
#macs = ['C1:05:25:89:4A:F0', 'DD:39:47:16:BA:F5', 'EF:12:4E:E0:FC:95']
mov_check = 0
door_moved = 0
mov = 0

print('Starting')

def print_data(received_data):
    received_mac = received_data[0]
    data = received_data[1]

    mov = data['movement_counter']
    global mov_check
    global door_moved
    mov_counter_gap = 256 #movement_counter is 8 a bit counter so reset after 256

    #check if door is moved
    if mov > mov_check:
        mov_check = mov
        door_moved = 1
    elif mov_check >= mov_counter_gap:
        mov_check = 0
    elif mov == mov_check and door_moved == 1:
        door_moved = 0

    line_check = str.format('MovementCheck: {0}', mov_check)

    line_batt = str.format('BatteryStatus: {0}', data['battery'])
    line_sen = str.format('Sensor - {0}', received_mac)
    line_door = str.format('IsDoorMoved: {0}', door_moved)
    line_tem = str.format('Temperature: {0} C', data['temperature'])
    line_hum = str.format('Humidity:    {0}', data['humidity'])
    line_pre = str.format('Pressure:    {0}', data['pressure'])
    line_doo = str.format('IsDoorMoved: {0}', door_moved)
    line_check = str.format('MovementCounter: {0}', data['movement_counter'])

    # Clear screen and print sensor data
    os.system('clear')
    print('Press Ctrl+C to quit.\n\r\n\r')
    print(str(datetime.now()))
    print(line_batt)
    print(line_sen)
    print(line_tem)
    print(line_hum)
    print(line_pre)
    print(line_door)
    print(line_check)
    print('\n\r\n\r.......')


RuuviTagSensor.get_datas(print_data, mac)
#RuuviTagSensor.get_datas(print_data, macs)
