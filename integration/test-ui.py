import os
import shutil
import time
import pytest
from os.path import dirname, join, exists

from syncloudlib.integration.hosts import add_host_alias
from syncloudlib.integration.screenshots import screenshots
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

DIR = dirname(__file__)
screenshot_dir = join(DIR, 'screenshot')
TMP_DIR = '/tmp/syncloud/ui'

@pytest.fixture(scope="session")
def module_setup(request, device, log_dir, ui_mode):
    request.addfinalizer(lambda: module_teardown(device, log_dir, ui_mode))


def module_teardown(device, log_dir, ui_mode):
    device.activated()
    device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)
    device.run_ssh('journalctl > {0}/journalctl.ui.{1} log'.format(TMP_DIR, ui_mode), throw=False)
    device.run_ssh('cp /var/log/syslog {0}/syslog.ui.{1}.log'.format(TMP_DIR, ui_mode), throw=False)
      
    device.scp_from_device('{0}/*'.format(TMP_DIR), join(log_dir, 'log'))


def test_start(module_setup, app, device_host):
    if not exists(screenshot_dir):
        os.mkdir(screenshot_dir)

    add_host_alias(app, device_host)

def test_login(driver, app_domain, ui_mode):
    url = "https://{0}".format(app_domain)
    driver.get(url)
    time.sleep(10)
    
    screenshots(driver, screenshot_dir, 'login-' + ui_mode)


def test_index(driver, app_domain, device_user, device_password, ui_mode):
    user = driver.find_element_by_name("login")
    user.send_keys(device_user)
    password = driver.find_element_by_name("password")
    password.send_keys(device_password)
    password.submit()
    time.sleep(5)
    screenshots(driver, screenshot_dir, 'index-' + ui_mode)


def test_edit(driver, app_domain, device_user, device_password, ui_mode):
    driver.find_element_by_xpath("//a[contains(text(),'Self Modify')]").click()
   
    password = driver.find_element_by_id("password1")
    password.send_keys(device_password)
    password1 = driver.find_element_by_id("#password2")
    password1.send_keys(device_password)
    password1.submit()
    
    wait = WebDriverWait(driver, 10)
    done_message = (By.XPATH, "//span[@data-notify='message' and contains(text(),'Self modification done')]")
    wait.until(EC.presence_of_element_located(done_message))
    screenshots(driver, screenshot_dir, 'edit-' + ui_mode)
    wait.until(EC.invisibility_of_element_located(done_message))


def test_new_user(driver, app_domain, device_user, device_password, ui_mode):
    new_user_btn = "//a[contains(text(),'Add User')]"
    wait = WebDriverWait(driver, 10)
    wait.until(EC.presence_of_element_located((By.XPATH, new_user_btn)))
    screenshots(driver, screenshot_dir, 'add-user-before-open-' + ui_mode)

    driver.find_element_by_xpath(new_user_btn).click()
    time.sleep(5)
    screenshots(driver, screenshot_dir, 'add-user-after-open-' + ui_mode)

    save_btn = "//button[contains(string(),'Add User')]"
    wait.until(EC.presence_of_element_located((By.XPATH, save_btn)))
   
    driver.find_element_by_id("attr.name").send_keys("Last Name")
    driver.find_element_by_id("attr.first-name").send_keys("First Namr")
    driver.find_element_by_name("attr.password1").send_keys("Password1!")
    driver.find_element_by_name("attr.password2").send_keys("Password1!")
    driver.find_element_by_id("attr.email").send_keys("test@example.com")

    screenshots(driver, screenshot_dir, 'add-user-before-save-' + ui_mode)

    driver.find_element_by_xpath(save_btn).click()
    time.sleep(5)
    screenshots(driver, screenshot_dir, 'add-user-saved-' + ui_mode)
