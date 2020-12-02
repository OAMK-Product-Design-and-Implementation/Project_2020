
# Scans a folder for json or txt-files, POSTs them, and moves them to an archive folder
# Other files, that are not intended for the DB, should not be kept at the designated folders
# Works with RestApi.py, new address routes should be added there (server side)
# Tables are in mydb in mysql (configured by RestApi.py and databaseConnect.py)

import requests
import json
import os, os.path
import shutil
import time

# Set a folder from where program reads json/txt files and posts them to the database
directory = "D:\\OneDrive - Oulun ammattikorkeakoulu\\S2020_Projekti\\jsons\\"
# Set an archive folder where program moves files that are posted
archive = "D:\\OneDrive - Oulun ammattikorkeakoulu\\S2020_Projekti\\jsonarchive\\"

local = False

if local == False:
    postUrl = 'http://195.148.21.106/api/devices/post/location'
    postUrl2 = 'http://195.148.21.106/api/devices/post/status'
else:
    postUrl = 'http://127.0.0.1:5000/api/devices/post/location'
    postUrl2 = 'http://127.0.0.1:5000/api/devices/post/status'


def post():
    with open(directory + filename) as jo:
        j_data = json.load(jo)
        print("Posting the data to: ", Url)
        x = requests.post(Url, json = j_data)

        if x.status_code == 200:
            print("Code 200, success!")
            c_flag = True
        else:
            print("Error", x)
            print("The post was unsuccessful. Trying again in 10 sec.\n")
            c_flag = False
            time.sleep(10)

    if c_flag == True:
        # move a file to an archive folder
        timestr = time.strftime("%Y%m%d-%H%M%S") # give datetime to a filename to avoid overwrites
        shutil.move(directory + filename, archive + filename + "_" + timestr + ".json")
        print("Processed file moved to the archive.\n")
        time.sleep(1)

    else:
        print("A post was unsuccessful. Trying again in 5 sec")
        time.sleep(5)


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

            if filename.endswith("location.json") or filename.endswith("location.txt"):
                Url = postUrl
                post()

            elif filename.endswith("status.json") or filename.endswith("status.txt"):
                Url = postUrl2
                post()
            
            else:
                break

    time.sleep(2)        
