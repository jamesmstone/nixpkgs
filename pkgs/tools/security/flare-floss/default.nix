{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "flare-floss";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "fireeye";
    repo = "flare-floss";
    rev = "v${version}";
    sha256 = "GMOA1+qM2A/Qw33kOTIINEvjsfqjWQWBXHNemh3IK8w=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    pyyaml
    simplejson
    tabulate
    vivisect
    plugnplay
    viv-utils
  ];

  checkInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  disabledTests = [
    # test data is in a submodule
    "test_main"
  ];

  pythonImportsCheck = [
    "floss"
    "floss.plugins"
  ];

  meta = with lib; {
    description = "Automatically extract obfuscated strings from malware";
    homepage = "https://github.com/fireeye/flare-floss";
    license = licenses.asl20;
    maintainers = teams.determinatesystems.members;
  };
}
