{ pkgs ? (import <nixpkgs> {}) }:
with pkgs;
with (import ./dep.nix { inherit pkgs; });
let
  crictl = buildGoPackage {
    name = "crictl";

    src = fetchFromGitHub {
      owner = "kubernetes-incubator";
      repo = "cri-tools";
      rev = "e03736e429bcd0dba6f46cf6d6f7ccf0f5c70cc3";
      sha256= "sha256-vKNBgWdPBHboAUh+CrdP/mNPIRnCXyQPlO6DotVEePg=";
    };

    goPackagePath = "github.com/kubernetes-incubator/cri-tools";
    subPackages = ["cmd/crictl"];
    deps = null;
  };


in stdenv.mkDerivation rec {
  name = "kubernix-dev";
  goPackagePath = "github.com/moretea/kubernix";
  buildInputs = [ go crictl jq dep ];

  CRI_RUNTIME_ENDPOINT = "/tmp/kubernix.sock";

  shellHook = ''
    projectGoPath=$(mktemp -d)
    mkdir -p $projectGoPath/src/$(dirname ${goPackagePath})
    ln -s $(pwd) $projectGoPath/src/${goPackagePath}
    export GOPATH=$projectGoPath:$GOPATH
    alias build='go build github.com/moretea/kubernix/cmd/kubernix'
  '';
}
