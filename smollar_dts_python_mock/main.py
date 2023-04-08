import logging
import time
import multiprocessing
from typing import List

import requests
import geocoder

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
baseUrl = "https://smollar-dts-api-gi3nbcbadq-ew.a.run.app/api/v1/devices/"
DEVICE_NAME = "MockDevice"

def createDevice(deviceName):
    response = requests.post(url=baseUrl + deviceName, data="Test Test")
    logger.info(response.text)

def deleteDevice(deviceName):
    response = requests.delete(url=baseUrl + deviceName)
    logger.info(response.text)

def updateDevice(deviceName, data):
    response = requests.patch(url=baseUrl + deviceName, json=data)
    logger.info(f"updated location to {data[0]['coordinate']} at {data[0]['timestamp']}")

def mocking():
    initialLocation : List[float] = geocoder.ip("me").latlng
    i : float = 0
    while(True):
        data = {
            "timestamp":{
                "seconds":time.time(),
                "nanos": 0,
            },
            "coordinate":{
                "latitude": initialLocation[0] + i,
                "longitude":initialLocation[1] + i,
            },
        }
        updateDevice(DEVICE_NAME, [data])
        i = i + 0.2
        time.sleep(4)

def main(): 
    createDevice(DEVICE_NAME)
    
    process = multiprocessing.Process(target=mocking)
    process.start()
    
    userInput = input("Press enter to stop:\n")
    process.terminate()
    
    deleteDevice(DEVICE_NAME)
    
if __name__ == '__main__' :
    main()