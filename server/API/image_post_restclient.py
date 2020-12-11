
# A simple example post client
# Tables are in TestDataBase (configured by RestApi.py and databaseConnect.py)

import requests
import json
import time

import os, os.path
import shutil
from base64 import b64encode

# Set a folder from where program reads .jpg files and posts them to the database/server
directory = "D:\\OneDrive - Oulun ammattikorkeakoulu\\S2020_Projekti\\images\\"
# Set an archive folder where program moves files that are posted
archive = "D:\\OneDrive - Oulun ammattikorkeakoulu\\S2020_Projekti\\img_archive\\"

devID = "4"

local = False

if local == False:
    postUrl = 'http://195.148.21.106/api/devices/post/image'
    postUrl2 = 'http://195.148.21.106/api/ruuvi/post/details'
else:
    postUrl = 'http://127.0.0.1:5000/api/devices/post/location'
    postUrl2 = 'http://127.0.0.1:5000/api/devices/post/status'

while(True):

    # Reads the number of files in a folder and lists them
    file_list = os.listdir(directory)
    filecount = len(file_list)
    print("Scanning file count:", filecount)

    while(filecount > 0):

        file_list = os.listdir(directory)
        filecount = len(file_list)
        print("No. of files left:", filecount)

        for filename in file_list:
            print("File to post:", filename)
            print("From list:", file_list)
            time.sleep(1)

            if filename.endswith(".jpg"):
                headers = {'content-type': 'application/json'}
                with open(directory + filename, mode="rb") as open_file:
                    byte_content = open_file.read()
                    base64_bytes = b64encode(byte_content)
                    base64_str = base64_bytes.decode('utf-8')

                    content = {"Devices_idDevice": devID, "Names": filename, "images": base64_str}
                    #print(data)
                    print("Posting the data to: ", postUrl)
                    x = requests.post(postUrl, data = json.dumps(content), headers = headers)

                    if x.status_code == 200:
                        print("Code 200, success!")
                        c_flag = True
                    else:
                        print("Error", x)
                        print("The post was unsuccessful. Trying again in 10 sec.\n")
                        c_flag = False
                        time.sleep(5)
                        break

                if c_flag == True:
                    # move a file to an archive folder
                    shutil.move(directory + filename, archive + filename)
                    print("Processed file moved to the archive.\n")
                    time.sleep(1)
                    break
                else:
                    print("A post was unsuccessful. Trying again in 5 sec")
                    time.sleep(5)

            else:
                print("There is an incompatible file in the folder:", filename)
                print(directory, "\n")
                time.sleep(2)
                break

    time.sleep(2)        

