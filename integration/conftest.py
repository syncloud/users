from os.path import dirname, join
from syncloudlib.integration.conftest import *

DIR = dirname(__file__)


@pytest.fixture(scope="session")
def log_dir():
    return join(DIR, 'log')


@pytest.fixture(scope="session")
def artifact_dir():
    return join(DIR, '..', 'artifact')
