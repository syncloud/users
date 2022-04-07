from os.path import dirname

from syncloudlib.integration.conftest import *

DIR = dirname(__file__)


@pytest.fixture(scope="session")
def project_dir():
    return join(DIR, '..')


@pytest.fixture(scope="session")
def new_username(ui_mode):
    return ui_mode[:2]


@pytest.fixture(scope="session")
def new_mail(ui_mode):
    return "test-{}@example.com".format(ui_mode)


@pytest.fixture(scope="session")
def new_group(ui_mode):
    return "new_group-{}".format(ui_mode)
