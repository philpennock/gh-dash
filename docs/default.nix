{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  buildPackages,
  testers,
  hugo,
}:

buildGoModule rec {
  pname = "hugo";
  version = "0.120.4";

  src = fetchFromGitHub {
    owner = "gohugoio";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-eBDlX+3Gb4bWRJ0ITwlx1c3q1RCFK2tyuKn9SALHbhI=";
  };

  vendorHash = "sha256-Tvjip76XEhmUXFP28hulPJNqjttoXE/DJLmMp1VVs8Q=";

  doCheck = false;

  proxyVendor = true;

  tags = [ "extended" ];

  subPackages = [ "." ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/gohugoio/hugo/common/hugo.vendorInfo=nixpkgs"
  ];

  postInstall =
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      ${emulator} $out/bin/hugo gen man
      installManPage man/*
      installShellCompletion --cmd hugo \
        --bash <(${emulator} $out/bin/hugo completion bash) \
        --fish <(${emulator} $out/bin/hugo completion fish) \
        --zsh  <(${emulator} $out/bin/hugo completion zsh)
    '';

  passthru.tests.version = testers.testVersion {
    package = hugo;
    command = "hugo version";
    version = "v${version}";
  };

  meta = with lib; {
    description = "A fast and modern static website engine";
    homepage = "https://gohugo.io";
    license = licenses.asl20;
    maintainers = with maintainers; [
      schneefux
      Br1ght0ne
      Frostman
    ];
  };
}
