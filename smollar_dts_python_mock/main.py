import logging
import time
import multiprocessing
from typing import List
import math
import random

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
    location : List[float] = geocoder.ip("me").latlng
    i : float = 0
    while(True):
        data = {
            "timestamp":{
                "seconds":time.time(),
                "nanos": 0,
            },
            "coordinate":{
                "latitude": location[0],
                "longitude": location[1],
            },
        }
        updateDevice(DEVICE_NAME, [data])
        angle = random.random() * math.pi/2
        location[0] = location[0] + math.cos(angle) * 0.01
        location[1] = location[1] + math.sin(angle) *0.01
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