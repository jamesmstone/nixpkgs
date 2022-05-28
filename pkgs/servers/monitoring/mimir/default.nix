{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "mimir";
  version = "2.1.0";

  src = fetchFromGitHub {
    rev = "${pname}-${version}";
    owner = "grafana";
    repo = pname;
    sha256 = "sha256-n7Vzp/GQIC+Mryu9SycMZ3ScPo5O+5tA4TdigpKzmLU=";
  };

  vendorSha256 = null;

  subPackages = [
    "cmd/mimir"
    "cmd/mimirtool"
  ];

  ldflags = let t = "github.com/grafana/mimir/pkg/util/version";
  in [
    ''-extldflags "-static"''
    "-s"
    "-w"
    "-X ${t}.Version=${version}"
    "-X ${t}.Revision=unknown"
    "-X ${t}.Branch=unknown"
  ];

  meta = with lib; {
    description =
      "Grafana Mimir provides horizontally scalable, highly available, multi-tenant, long-term storage for Prometheus. ";
    homepage = "https://github.com/grafana/mimir";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ happysalada bryanhonof ];
    platforms = platforms.unix;
  };
}
