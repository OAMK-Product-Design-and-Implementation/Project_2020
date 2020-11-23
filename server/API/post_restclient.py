
# Scans a folder for json or txt-files, POSTs them, and moves them to an archive folder
# Other files, that are not intended for the DB, should not be kept at the designated folders
# Works with RestApi.py, new address routes should be added there
# Tables are in mydb in mysql (configured by RestApi.py and databaseConnect.py)

import requests
import json
import os, os.path
import shutil
import time

directory = "D:\\OneDrive - Oulun ammattikorkeakoulu\\S2020_Projekti\\jsons\\"
archive = "D:\\OneDrive - Oulun ammattikorkeakoulu\\S2020_Projekti\\jsonarchive\\"

local = False

if local == False:
    postUrl = 'http://195.148.21.106/api/doori/post/newDoori'
else:
    postUrl = 'http://127.0.0.1:5000/api/doori/post/newDoori'

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

            if filename.endswith(".json") or filename.endswith(".txt"):
                with open(directory + filename) as jo:
                    j_data = json.load(jo)
                    print("Posting the data to: ", postUrl)
                    x = requests.post(postUrl, json = j_data)

                    if x.status_code == 200:
                        print("Code 200, success!")
                        c_flag = True
                    else:
                        print("Error", x)
                        print("The post was unsuccessful. Trying again in 10 sec.\n")
                        c_flag = False
                        time.sleep(10)
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
