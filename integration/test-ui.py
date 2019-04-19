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

def test_login(driver, mobile_driver, app_domain):
    _test_login(driver, 'desktop', app_domain)
    _test_login(mobile_driver, 'mobile', app_domain)


def _test_login(driver, mode, app_domain):
    url = "https://{0}".format(app_domain)
    driver.get(url)
    time.sleep(10)
    
    screenshots(driver, screenshot_dir, 'login-' + mode)


def test_index(driver, mobile_driver, app_domain, device_user, device_password):
    _test_index(driver, 'desktop', app_domain, device_user, device_password)
    _test_index(mobile_driver, 'mobile', app_domain, device_user, device_password)


def _test_index(driver, mode, app_domain, device_user, device_password):
    user = driver.find_element_by_name("login")
    user.send_keys(device_user)
    password = driver.find_element_by_name("password")
    password.send_keys(device_password)
    password.submit()
    time.sleep(5)
    screenshots(driver, screenshot_dir, 'index-' + mode)


def test_edit(driver, mobile_driver, app_domain, device_user, device_password):
    _test_edit(driver, 'desktop', app_domain, device_user, device_password)
    _test_edit(mobile_driver, 'mobile', app_domain, device_user, device_password)


def _test_edit(driver, mode, app_domain, device_user, device_password):
    driver.find_element_by_xpath("//a[contains(text(),'Self Modify')]").click()
   
    #password = driver.find_element_by_name("password")
    #password.send_keys(device_password)
    #password.submit()
    time.sleep(5)
    screenshots(driver, screenshot_dir, 'edit-' + mode)
