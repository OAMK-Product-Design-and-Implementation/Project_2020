import base64
import os
import databaseConnect as db
import re
import json

fileLocationTrue = "C://Users//teemu//OneDrive//Asiakirjat//Koulujuttuja//testImage.jpg"
fileLocation = "C:/Users/teemu/OneDrive/Asiakirjat/Koulujuttuja/"
fileType = "jpg"

imagename = ["testImage", "testImage - Copy"]
#get single image according to the name. Returns it in base64 format
def getImage(fileName):
    try:
        fileName = fileName.strip()
        filepath = os.path.join(fileLocation+fileName+"."+fileType)
        with open(filepath, "rb") as image:
            imageFile = base64.b64encode(image.read())
        image.close()
        return imageFile

    except IOError:
        print("File not found")


# Gets multiple images according to the given image names. Returns it in base64 format with imagename attached.
# returns the whole data in json format.
def getMultipleImages(fileNames):
    imageFiles = {"images": []}
    for name in fileNames:
        try:
            fileName = name.strip()
            filepath = os.path.join(fileLocation+name+"."+fileType)
            with open(filepath, "rb") as image:
                imageFile = str(base64.b64encode(image.read()))
                imageFiles["images"].append({name:imageFile}) 
            image.close()
        
        except IOError:
            print("File " + name + " not found")
    images = json.dumps(imageFiles)

    return images

# Saves image on the disk
def saveImage(fileName, fileData):

    fileName = fileName.strip()
    fullFileName = os.path.join(fileLocation+fileName+"."+fileType)
    
    with open(fullFileName, 'wb') as f:
        f.write(fileData.decode('base64'))
        print("Writing done, imagename: " + fileName)
    f.close()

# SQL query for getting image names for specific device
def getImageSQLQueryDeviceID(deviceID):

    query = '''Select Names from Images Where Devices_idDevice = "{}"'''.format(str(deviceID))

    imageNames = str(db.sqlQuery(query))
    
    imageNames = imageNames.replace("(","")
    imageNames = imageNames.replace(")","")
    imageNames = imageNames.replace(",","")
    imageNames = imageNames.split(" ")

    return imageNames


getMultipleImages(imagename)