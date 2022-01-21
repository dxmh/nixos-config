{ pkgs, ... }:

{

  vim-snazzy = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-snazzy";
    version = "2022-01-21";
    src = pkgs.fetchFromGitHub {
      owner = "connorholyday";
      repo = "vim-snazzy";
      rev = "d979964b4dc0d6860f0803696c348c5a912afb9e";
      sha256 = "0a9m48dv05fp8vc0949gr5yhj8wp09p7f125waazwd5ax8f591p9";
    };
  };

}
