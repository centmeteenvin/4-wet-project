import logging

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
        

def main(): 
    createDevice(DEVICE_NAME)
    deleteDevice(DEVICE_NAME)
    
if __name__ == '__main__' :
    main()