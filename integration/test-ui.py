import os
import shutil
import time
from os.path import dirname, join, exists

from syncloudlib.integration.hosts import add_host_alias
from syncloudlib.integration.screenshots import screenshots

DIR = dirname(__file__)
screenshot_dir = join(DIR, 'screenshot')


def test_start(app, device_host):
    if exists(screenshot_dir):
        shutil.rmtree(screenshot_dir)
    os.mkdir(screenshot_dir)

    add_host_alias(app, device_host)


def test_index(driver, mobile_driver, user_domain):
    url = "https://{0}".format(user_domain)
    driver.get(url)
    mobile_driver.get(url)
    time.sleep(10)
    
    screenshots(driver, 'index')
    screenshots(mobile_driver, 'index-mobile')
