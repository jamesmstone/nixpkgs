{ lib
, buildPythonPackage
, fetchPypi
, boto3
, botocore
, pandas
, tenacity
}:

buildPythonPackage rec {
  pname = "pyathena";
  version = "2.4.1";

  src = fetchPypi {
    pname = "PyAthena";
    inherit version;
    sha256 = "9d42b4e2cdbd8c48f8157692b50681b08569aa3cac3a9694e671ec9aa40f969b";
  };

  # Nearly all tests depend on a working AWS Athena instance,
  # therefore deactivating them.
  # https://github.com/laughingman7743/PyAthena/#testing
  doCheck = false;

  propagatedBuildInputs = [
    boto3
    botocore
    pandas
    tenacity
  ];

  meta = with lib; {
    homepage = "https://github.com/laughingman7743/PyAthena/";
    license = licenses.mit;
    description = "Python DB API 2.0 (PEP 249) client for Amazon Athena";
    maintainers = with maintainers; [ turion ];
  };
}
