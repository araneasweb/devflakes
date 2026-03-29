# devflakes

Tiny personal development environment flakes for primarily personal use.

If you have a flake you'd like for me to add, make an issue, and if you want for
me to include your flake make a pr \<3

The general usage is through my `ndv` command in my nixos dotfiles, but if you
want to use the devflakes outside of that context, the command is:

```bash
nix flake init -t github:araneasweb/devflakes#$envname
```

where `$envname` is the language you want the shell for.
