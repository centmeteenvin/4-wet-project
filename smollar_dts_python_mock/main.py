import logging
import time
import multiprocessing

import requests
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
    logger.info(response.text)

def mocking():
    while(True):
        data = {
            "timestamp":{
                "seconds":time.time(),
                "nanos": 0,
            },
            "coordinate":{
                "latitude":51.0,
                "longitude":4.0,
            },
        }
        updateDevice(DEVICE_NAME, [data])
        time.sleep(1)

def main(): 
    createDevice(DEVICE_NAME)
    
    process = multiprocessing.Process(target=mocking)
    process.start()
    
    userInput = input("Press enter to stop:\n")
    process.terminate()
    
    deleteDevice(DEVICE_NAME)
    
if __name__ == '__main__' :
    main()