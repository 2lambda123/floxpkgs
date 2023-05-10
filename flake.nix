{
  nixConfig.extra-substituters = ["https://cache.floxdev.com"];
  nixConfig.extra-trusted-public-keys = ["flox-store-public-0:8c/B+kjIaQ+BloCmNkRUKwaVPFWkriSAd0JJvuDu4F0="];

  # TODO: is this still needed?
  inputs.catalog.url = "github:flox/floxpkgs?ref=publish";
  inputs.catalog.flake = false;

  # Declaration of external resources
  # =================================

  # TODO: We name the following flake input `flox-floxpkgs` since we CLI
  #       overwrites flox-floxpkgs/nixpkgs/nixpkgs flake input.
  #       We should change that to `flox/nixpkgs-flox/nixpkgs`
  inputs.flox-floxpkgs.url = "git+ssh://git@github.com/flox/flox?ref=next";

  inputs.nixpkgs.url = "github:flox/nixpkgs-flox";
  inputs.nixpkgs.inputs.flox.follows = "flox-floxpkgs";

  inputs.flox.follows = "flox-floxpkgs";

  inputs.tracelinks.url = "git+ssh://git@github.com/flox/tracelinks?ref=main";
  inputs.tracelinks.inputs.flox.follows = "flox-floxpkgs";

  inputs.builtfilter.url = "github:flox/builtfilter?ref=builtfilter-rs";
  inputs.builtfilter.inputs.flox.follows = "flox-floxpkgs";
  # =================================

  outputs = args @ {flox-floxpkgs, ...}: flox-floxpkgs.project args (
    {
      self,
      inputs,
      lib,
      ...
    }:
      # re-call yourself with overrides, will not work if using in-memory lockfile
      let hydraOverride = path: follows: (inputs.capacitor.lib.capacitor.callFlake
        (builtins.readFile (self + "/flake.lock"))
        self "" "" "root" { }
        [ {
            path = path;
            follows = follows;
          } ]
        ).hydraJobs;
      in
# Define package set structure
    {
      # Limit the systems to fewer or more than default by ucommenting
      packages = {
        builtfilter = {capacitated, ...}: capacitated.builtfilter.packages.builtfilter-rs;
      };

      # reexport of capacitor, defaultPlugins, project, lib, templates, apps
      passthru = { inherit (inputs.flox) capacitor defaultPlugins project lib templates apps; };

      passthru."hydraJobsStaging" = hydraOverride ["nixpkgs" "nixpkgs"] ["nixpkgs" "nixpkgs-staging"];
      passthru."hydraJobsUnstable" = hydraOverride ["nixpkgs" "nixpkgs"] ["nixpkgs" "nixpkgs-unstable"];
      passthru."hydraJobsStable" = hydraOverride ["nixpkgs" "nixpkgs"] ["nixpkgs" "nixpkgs-stable"];
    });
}
