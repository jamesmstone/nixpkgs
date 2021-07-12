{ lib
, buildPythonPackage
, base36
, cryptography
, curve25519-donna
, ecdsa
, ed25519
, fetchFromGitHub
, h11
, pyqrcode
, pytest-asyncio
, pytest-timeout
, pytestCheckHook
, pythonOlder
, zeroconf
}:

buildPythonPackage rec {
  pname = "hap-python";
  version = "3.5.0";
  disabled = pythonOlder "3.5";

  # pypi package does not include tests
  src = fetchFromGitHub {
    owner = "ikalchev";
    repo = "HAP-python";
    rev = "v${version}";
    sha256 = "1vzlfx0gpidl0rzv4z94pziwm6rj4lrilly5pykgq984y708pcqf";
  };

  propagatedBuildInputs = [
    base36
    cryptography
    curve25519-donna
    ecdsa
    ed25519
    h11
    pyqrcode
    zeroconf
  ];

  checkInputs = [
    pytest-asyncio
    pytest-timeout
    pytestCheckHook
  ];

  # Disable tests requiring network access
  disabledTestPaths = [
    "tests/test_accessory_driver.py"
    "tests/test_hap_handler.py"
    "tests/test_hap_protocol.py"
  ];

  disabledTests = [
    "test_persist_and_load"
    "test_we_can_connect"
    "test_idle_connection_cleanup"
    "test_we_can_start_stop"
    "test_push_event"
    "test_bridge_run_stop"
  ];

  meta = with lib; {
    homepage = "https://github.com/ikalchev/HAP-python";
    description = "HomeKit Accessory Protocol implementation in python";
    license = licenses.asl20;
    maintainers = with maintainers; [ oro ];
  };
}
