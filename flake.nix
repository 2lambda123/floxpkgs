rec {
  nixConfig.extra-substituters = ["https://cache.floxdev.com?trusted=1"];

  inputs.capacitor.url = "github:flox/capacitor";
  inputs.capacitor.inputs.root.follows = "/";

  inputs.flox-extras.url = "github:flox/flox-extras";
  inputs.flox-extras.inputs.capacitor.follows = "capacitor";

  inputs.catalog.url = "github:flox/floxpkgs?ref=publish";
  inputs.catalog.flake = false;

  inputs.nixpkgs.url = "github:flox/nixpkgs-flox";
  inputs.nixpkgs.inputs.flox-extras.follows = "flox-extras";


  inputs.self-unstable.follows = "/";
  inputs.self-unstable.inputs.nixpkgs.url = "github:flox/nixpkgs-flox/unstable";
  inputs.self-staging.follows = "/";
  inputs.self-staging.inputs.nixpkgs.url = "github:flox/nixpkgs-flox/staging";

  # Declaration of external resources
  # =================================

  inputs.flox.url = "git+ssh://git@github.com/flox/flox?ref=main";
  inputs.flox.flake = false;

  inputs.nix-editor.url = "github:vlinkz/nix-editor";
  inputs.nix-editor.inputs.nixpkgs.follows = "nixpkgs";
  # nix has a bug where it can't add a follows two inputs deep, so add this hack to make naersk
  # follow nixpkgs
  inputs.naersk.url = "github:nix-community/naersk";
  inputs.naersk.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix-editor.inputs.naersk.follows = "naersk";

  inputs.builtfilter.url = "github:flox/builtfilter?ref=builtfilter-rs";
  inputs.builtfilter.inputs.capacitor.follows = "capacitor";
  # =================================

  nixConfig.bash-prompt = "[flox] \\[\\033[38;5;172m\\]λ \\[\\033[0m\\]";
  outputs = args @ {capacitor, ...}: capacitor args (import ./flox.nix);
}
