<div align="center">
<h1>My DWM Rice [WIP]</h1>

Yoinked some stuff from [Nyx's DWM](https://github.com/nnyyxxxx/dwm).

<h1>Installation</h1>

The installation script is designed for a minimal <a href="https://wiki.archlinux.org/title/Arch_Linux" target="_blank">Arch Linux</a> install, but may work on some <a href="https://wiki.archlinux.org/title/Arch-based_distributions" target="_blank">Arch-based distros</a>.

</div>

> [!IMPORTANT]
> This rice relies on having a permament existing `dwm/` directory. **Don't remove the directory after setup.**

#### To install, execute the following commands:
> [!CAUTION]
> The might overwrite your existing dotfiles. Make sure to back everything up.

```bash
git clone --depth 1 https://github.com/adamperkowski/dwm.git
cd dwm
./install.sh
```

#### To update, execute the following commands:

```bash
cd $DWM_DIR
./update.sh
```

You might need to re-run `./install.sh` after an update.
