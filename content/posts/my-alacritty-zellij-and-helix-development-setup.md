---
title: "My Alacritty, Zellij, and Helix Development Setup"
date: 2025-07-07T00:20:15.000Z
draft: false
tags: ["note-to-self", "#Import 2025-09-14 21:16"]
math: true
showToc: true
cover:
  image: "/images/2025/07/Screenshot-from-2025-07-07-02-22-24.png"
  alt: "My Alacritty, Zellij, and Helix Development Setup"
---

This article is a public note-to-self where I'll go through the basic configuration I use to get new computers ready for programming in just a couple of minutes. It is centered around the following pieces of software:

- [Alacritty](https://alacritty.org/), a terminal.
- [Zellij](https://zellij.dev/), a terminal multiplexer. 
- [Helix](https://helix-editor.com/), a text-editor with support for [LSP](https://en.wikipedia.org/wiki/Language_Server_Protocol), and [tree-sitter](https://tree-sitter.github.io/tree-sitter/).

In my selection process, I heavily emphasized performance, as I strongly dislike when my IDE can't keep up with my thoughts. I also favored software with sane defaults, such that almost zero configuration is required for great usability. The programs are free, cross-platform, open-source, and they all happen to be written in Rust.

## Installation
To avoid these instructions becoming obsolete the moment I hit “publish”, I will present a sequence of URLs to outline the steps required for installation. Context will be provided where necessary.

### Microsoft Windows
On Windows, my preferred method is to install Debian through the Windows Subsystem for Linux (WSL) and then install Zellij and Helix within that Debian environment.

[Install WSLInstall Windows Subsystem for Linux with the command, wsl --install. Use a Bash terminal on your Windows machine run by your preferred Linux distribution - Ubuntu, Debian, SUSE, Kali, Fedora, Pengwin, Alpine, and more are available.![](https://learn.microsoft.com/favicon.ico)Microsoft Learnmattwojo![](https://learn.microsoft.com/en-us/media/open-graph-image.png)](https://learn.microsoft.com/en-us/windows/wsl/install)*At the time of writing, all you have to do is open PowerShell and run `wsl --install`.

*[Debian - Free download and install on Windows | Microsoft StoreWith this app you get Debian for the Windows Subsystem for Linux (WSL). You will be able to use a complete Debian command line environment containing a full current stable release environment. If this is your first WSL app you might have to enable WSL first (or contact your device administrator to do so). https://docs.microsoft.com/en-us/windows/wsl/install After the installation you can start the WSL console by either clicking the “Debian” tile in the start menu or by typing “debian” in powershell or cmd. To keep your Debian environment up-to-date please use the following commands: $ sudo apt update $ sudo apt dist-upgrade The help page for this application can be found in the Debian Wiki: https://wiki.debian.org/InstallingDebianOn/Microsoft/Windows/SubsystemForLinux The source code for this application can be found at the Debian Gitlab instance: https://salsa.debian.org/debian/WSL![](https://static.ghost.org/v5.0.0/images/link-icon.svg)Microsoft Store - Download apps, games & more for your Windows PCThe Debian Project![](https://store-images.s-microsoft.com/image/apps.34483.13820785767960271.f3cbc95b-244f-43cd-81c8-b9c5afb00ffa.69d7ab63-77bf-46e0-9ff4-198f0a725727)](https://apps.microsoft.com/detail/9msvkqc78pk6?hl=en-US&gl=US)*You can also install Ubuntu. I recommend Debian because it is rock solid, and you can use Homebrew to get current versions of software.

*### Package Managers
While you can use system package managers like apt, you often get outdated versions of the software. I recommend using Homebrew for macOS and Linux, and Cargo (Rust's package manager) as a fallback.

Curl is required to install both Cargo and Homebrew. Git is required to install Homebrew. Homebrew will also prompt you to install gcc.

```bash
sudo apt update -y && sudo apt install curl git build-essential
```
*Install requirements for homebrew on Debian

*[HomebrewThe Missing Package Manager for macOS (or Linux).![](https://brew.sh/assets/img/homebrew.svg)Homebrew![](https://brew.sh/assets/img/homebrew-social-card.png)](https://brew.sh/)[Install RustA language empowering everyone to build reliable and efficient software.![](https://www.rust-lang.org/static/images/apple-touch-icon.png?v=ngJW8jGAmR)Rust![](https://www.rust-lang.org/static/images/rust-social-wide.jpg)](https://www.rust-lang.org/tools/install)### Alacritty, Zellij, Helix
I typically use one of these three commands, but you might consider following the linked instructions instead:

```bash
# Install everything with Homebrew
brew install alacritty zellij helix
```
*macOS

*
```bash
# A mix of Homebrew and Cargo. Homebrew doesn't package Alacritty for Linux.
brew install helix zellij && cargo install alacritty
```
*Linux

*On **Windows**, you must install Alacritty using the Windows installer.

```bash
brew install helix zellij
```
*Debian on Windows Subsystem for Linux

*[Alacritty - A cross-platform, OpenGL terminal emulatorAlacritty is a modern terminal emulator that comes with sensible defaults, but allows for extensive configuration. By integrating with other applications, rather than reimplementing their functionality, it manages to provide a flexible set of features with high performance.![](https://alacritty.org/alacritty-simple.svg)lacritty![](https://alacritty.org/alacritty-simple.svg)](https://alacritty.org/)[ZellijA terminal workspace with batteries included![](https://zellij.dev/favicon.ico)~/zellij/![](https://zellij.dev/img/floating-panes-preview.png)](https://zellij.dev/)[HelixA post-modern modal text editor.![](https://helix-editor.com/favicon.svg)![](https://helix-editor.com/logo.svg)](https://helix-editor.com/)## Configuration
I mostly tweak font size and themes. Though I provide my dotfiles in full, they are mostly optional.

#### Alacritty
If you are using **Windows**, you must configure Alacritty to launch the correct shell, as it defaults to PowerShell.

```toml
[terminal]
shell = { program = "debian", args = ["",] }
```
***Windows: %APPDATA%\alacritty\alacritty.toml**

*If you are using **macOS**, you must configure Alacritty to treat **option as alt **to enable the use of certain keybindings in terminal applications. 

```toml
[window]
option_as_alt = "Both" # No effect on Windows/Linux
dimensions = { columns = 160, lines = 48}

[font]
size = 14

[general]
import = [
    "~/.config/alacritty/themes/themes/rose_pine.toml"
]
```
*Linux and macOS: ~/.config/alacritty/alacritty.toml

*Setting the shell to “Debian” on Linux or macOS breaks the config, but appending the Linux/macOS-file to the Windows-file causes no issues.

#### Helix
Consider “base16_transparent” if you would rather not download or configure themes for Alacritty and Zellij. Use `:theme` in Helix to preview the included themes.

```toml
theme = "rose_pine"

```
*~/.config/helix/config.toml

*#### Zellij
Zellij ships a large default configuration file.

- Open `~/.config/zellij/config.kdl`
- Search for “theme”.
- Uncomment the relevant line, and set the desired value.

```kdl
// Choose the theme that is specified in the themes section.
// Default: default
// 
theme "rose-pine"

```
*~/.config/zellij/config.kdl

*### Themes
The default themes are mostly fine, but to get a matching look across all tools, I use the Rosé Pine theme.

[GitHub - alacritty/alacritty-theme: Collection of Alacritty color schemesCollection of Alacritty color schemes. Contribute to alacritty/alacritty-theme development by creating an account on GitHub.![](https://github.githubassets.com/assets/pinned-octocat-093da3e6fa40.svg)GitHubalacritty![](https://opengraph.githubassets.com/d1c2a244429e8c00fa6b08c0b218575f23945e0d639fc00b8eda1d1c18d046e9/alacritty/alacritty-theme)](https://github.com/alacritty/alacritty-theme)[GitHub - rose-pine/zellij: Soho vibes for ZellijSoho vibes for Zellij. Contribute to rose-pine/zellij development by creating an account on GitHub.![](https://github.githubassets.com/assets/pinned-octocat-093da3e6fa40.svg)GitHubrose-pine![](https://repository-images.githubusercontent.com/597751866/f1c5c835-f6ea-449b-b586-c8a1c9868e45)](https://github.com/rose-pine/zellij)### Language Servers
Helix uses language servers to provide autocomplete, code actions, and diagnostics. You can see a list of installed servers by running `hx --health`. Language servers must be installed separately, and often with homebrew. 

- Let's take Java as an example. Pass 'java' to `hx --health` to see if an LSP is installed:

```bash
kristoffer@INVINCIBLE:~$ hx --health java
Configured language servers:
  ✘ jdtls: 'jdtls' not found in $PATH
...
```

- Install it with Homebrew: `brew install jdtls`. And when the installation is done:

```bash
kristoffer@INVINCIBLE:~$ hx --health java
Configured language servers:
  ✓ jdtls: /home/linuxbrew/.linuxbrew/bin/jdtls
...
```

- Helix now has full support for Java. Repeat for whichever languages or file-types are needed.

💡The rust-analyzer LSP should be installed with rustup, not homebrew: `rustup component add rust-analyzer`### Bonus: JetBrains Toolbox
As someone who also uses JetBrains IDEs, I like to include their Toolbox App in my basic setup.

[JetBrains Toolbox App: Manage Your Tools with EaseOpen any of your projects in any of the IDEs with one click.![](https://www.jetbrains.com/apple-touch-icon.png?r=1234)JetBrainsJetBrains![](https://resources.jetbrains.com/storage/products/toolbox/img/meta/preview.png)](https://www.jetbrains.com/toolbox-app/)## Summary
Installing everything should take only a few minutes and gives you a complete and consistent development environment across platforms. The result looks like this on my current machine:

![](/images/2025/07/image-1.png)*In pane one, I have opened a diagnostic picker in Helix in one of the [rustlings](https://rustlings.rust-lang.org/) exercise files. Pane two is running the rustling executable. Pane three is showing the output from [Screenfetch](https://github.com/KittyKatt/screenFetch).*
