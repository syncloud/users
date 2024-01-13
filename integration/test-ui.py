import time
from os.path import dirname, join
from subprocess import check_output
from integration.lib import login_with_admin
import pytest
from syncloudlib.integration.hosts import add_host_alias

DIR = dirname(__file__)
TMP_DIR = '/tmp/syncloud/ui'

new_password = "Ngpqy8Bfk123!"


@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir, ui_mode):
    def module_teardown():
        device.activated()
        device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)
        device.run_ssh('journalctl > {0}/journalctl.ui.{1}.log'.format(TMP_DIR, ui_mode), throw=False)
        device.run_ssh('cp /var/log/syslog {0}/syslog.ui.{1}.log'.format(TMP_DIR, ui_mode), throw=False)
        device.run_ssh('LD_LIBRARY_PATH=/snap/platform/current/openldap/lib '
                       '/snap/platform/current/openldap/sbin/slapcat '
                       '-F /var/snap/platform/common/slapd.d > {0}/ldap.ldif-{1}.log'.format(TMP_DIR, ui_mode),
                       throw=False)
        device.scp_from_device('{0}/*'.format(TMP_DIR), join(artifact_dir, 'log'))
        check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)

    request.addfinalizer(module_teardown)


def test_start(module_setup, app, domain, device_host, device):
    add_host_alias(app, device_host, domain)
    device.run_ssh('date', retries=10, throw=True)
    time.sleep(10)


def test_login_with_admin(selenium, device_user, device_password):
    login_with_admin(selenium, device_user, device_password)


def test_new_user(selenium, new_username, new_mail):
    open_new_account_page(selenium)
    selenium.screenshot('add-user-after-open')
    selenium.find_by_id("sn").send_keys("Last")
    selenium.find_by_id("givenname").send_keys("First")
    selenium.find_by_id("cn").clear()
    selenium.find_by_id("cn").send_keys(new_username)
    selenium.find_by_name("password").send_keys(new_password)
    selenium.find_by_name("password_match").send_keys(new_password)
    selenium.find_by_id("mail").send_keys(new_mail)
    selenium.screenshot('add-user-before-save')

    selenium.find_by_xpath("//button[text()='Create account']").click()
    selenium.find_by_xpath("//p[contains(text(),'The account was created')]")
    selenium.screenshot('add-user-saved')


def test_new_user_login(selenium, new_username):
    logout(selenium)
    selenium.find_by_xpath("//input[@name='user_id']").send_keys(new_username)
    password = selenium.driver.find_element_by_name("password")
    password.send_keys(new_password)
    selenium.screenshot('new-user-login-credentials')
    password.submit()
    selenium.find_by_xpath("//a[text()='Log Out']")
    selenium.screenshot('new-user-main')


def logout(selenium):
    selenium.find_by_xpath("//a[text()='Log Out']").click()
    selenium.find_by_xpath("//a[text()='Log In']").click()


def test_login_with_admin_second(selenium, device_user, device_password):
    logout(selenium)
    selenium.find_by_xpath("//input[@name='user_id']").send_keys(device_user)
    password = selenium.driver.find_element_by_name("password")
    password.send_keys(device_password)
    selenium.screenshot('login-credentials-second')
    password.submit()
    selenium.find_by_xpath("//a[text()='Log Out']")
    selenium.screenshot('main-second')


def test_modify_user(selenium, new_username, new_mail):
    selenium.find_by_xpath("//a[contains(text(),'Account Manager')]").click()
    selenium.find_by_xpath("//a[text()='Users']").click()
    selenium.find_by_xpath("//a[text()='{}']".format(new_username)).click()
    username = selenium.find_by_xpath("//input[@id='cn']")
    mail = selenium.find_by_xpath("//input[@id='mail']")
    selenium.screenshot('modify-user')
    assert username.get_attribute('value') == new_username
    assert mail.get_attribute('value') == new_mail
    selenium.find_by_name("password").send_keys(new_password)
    selenium.find_by_name("password_match").send_keys(new_password)
    selenium.find_by_xpath("//button[text()='Update account details']").click()
    selenium.find_by_xpath("//p[contains(text(),'The account has been updated')]")
    selenium.screenshot('modify-user-password')


def test_new_group(selenium, new_group):
    selenium.find_by_xpath("//a[contains(text(),'Account Manager')]").click()
    selenium.find_by_xpath("//a[text()='Groups']").click()
    selenium.find_by_xpath("//button[text()='New group']").click()
    new_group_id = selenium.find_by_id("group_name")
    selenium.screenshot('add-group')
    new_group_id.send_keys(new_group)
    selenium.find_by_xpath("//button[text()='Add']").click()
    selenium.find_by_xpath("//h3[text()='{}']".format(new_group))
    selenium.screenshot('add-group-after-save')
     

def test_group_modify(selenium, new_username):
    selenium.find_by_xpath("//li[text()='{}']".format(new_username)).click()
    selenium.find_by_xpath("//button[contains(@class,'move-left')]").click()
    selenium.screenshot('group-modify-before-save')
    selenium.find_by_xpath("//button[text()='Save']").click()
    selenium.find_by_xpath("//a[text()='Users']").click()
    selenium.find_by_xpath("//button[contains(text(),'New user')]")
    selenium.screenshot('add-group-users')


def test_new_user_login_second(selenium, new_username):
    logout(selenium)
    selenium.find_by_xpath("//input[@name='user_id']").send_keys(new_username)
    password = selenium.driver.find_element_by_name("password")
    password.send_keys(new_password)
    selenium.screenshot('new-user-login-credentials-second')
    password.submit()
    selenium.find_by_xpath("//a[text()='Log Out']")
    selenium.screenshot('new-user-main-second')


def open_new_account_page(selenium):
    selenium.find_by_xpath("//a[contains(text(),'Account Manager')]").click()
    selenium.find_by_xpath("//a[text()='Users']")
    selenium.find_by_xpath("//button[contains(text(),'New user')]").click()
    selenium.find_by_xpath("//div[text()='New account']")


def test_user_no_first_last_name(selenium, device_user, device_password, new_mail):
    logout(selenium)
    login_with_admin(selenium, device_user, device_password)
    open_new_account_page(selenium)
    # selenium.find_by_id("sn").send_keys("Last")
    # selenium.find_by_id("givenname").send_keys("First")
    selenium.find_by_id("cn").clear()
    selenium.find_by_id("cn").send_keys('no-first-last-name')
    selenium.find_by_name("password").send_keys(new_password)
    selenium.find_by_name("password_match").send_keys(new_password)
    selenium.find_by_id("mail").send_keys(new_mail)
    selenium.find_by_xpath("//button[text()='Create account']").click()
    selenium.find_by_xpath("//li[contains(text(),'First Name is required')]")
    selenium.find_by_xpath("//li[contains(text(),'Last Name is required')]")


def test_teardown(driver):
    driver.quit()

