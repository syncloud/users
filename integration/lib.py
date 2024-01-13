from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By


def login_with_admin(selenium, device_user, device_password):
    selenium.open_app()
    selenium.screenshot('index')
    selenium.find_by_xpath("//a[text()='Log In']").click()
    selenium.find_by_xpath("//input[@name='user_id']").send_keys(device_user)
    password = selenium.driver.find_element_by_name("password")
    password.send_keys(device_password)
    selenium.screenshot('login-credentials')
    password.submit()
    selenium.find_by_xpath("//a[text()='Log Out']")
    selenium.screenshot('main')
