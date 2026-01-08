---
title: "My Alacritty, Zellij, and Helix Development Setup"
date: 2025-07-07T00:20:15.000Z
draft: false
tags: ["Tooling", "Note"]
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

To avoid these instructions becoming obsolete the moment I hit "publish", I will present a sequence of URLs to outline the steps required for installation. Context will be provided where necessary.

### Microsoft Windows

On Windows, my preferred method is to install Debian through the Windows Subsystem for Linux (WSL) and then install Zellij and Helix within that Debian environment.

**[Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install)** - At the time of writing, all you have to do is open PowerShell and run `wsl --install`.

**[Debian from Microsoft Store](https://apps.microsoft.com/detail/9msvkqc78pk6?hl=en-US&gl=US)** - You can also install Ubuntu. I recommend Debian because it is rock solid, and you can use Homebrew to get current versions of software.

### Package Managers

While you can use system package managers like apt, you often get outdated versions of the software. I recommend using Homebrew for macOS and Linux, and Cargo (Rust's package manager) as a fallback.

Curl is required to install both Cargo and Homebrew. Git is required to install Homebrew. Homebrew will also prompt you to install gcc.

```bash
sudo apt update -y && sudo apt install curl git build-essential
```

*Install requirements for homebrew on Debian*

- **[Homebrew](https://brew.sh/)** - The Missing Package Manager for macOS (or Linux).
- **[Install Rust](https://www.rust-lang.org/tools/install)** - Includes Cargo, Rust's package manager.

### Alacritty, Zellij, Helix

I typically use one of these three commands, but you might consider following the linked instructions instead:

```bash
# Install everything with Homebrew
brew install alacritty zellij helix
```

*macOS*

```bash
# A mix of Homebrew and Cargo. Homebrew doesn't package Alacritty for Linux.
brew install helix zellij && cargo install alacritty
```

*Linux*

On **Windows**, you must install Alacritty using the Windows installer.

```bash
brew install helix zellij
```

*Debian on Windows Subsystem for Linux*

**Links:**
- [Alacritty](https://alacritty.org/) - A cross-platform, OpenGL terminal emulator
- [Zellij](https://zellij.dev/) - A terminal workspace with batteries included
- [Helix](https://helix-editor.com/) - A post-modern modal text editor

## Configuration

I mostly tweak font size and themes. Though I provide my dotfiles in full, they are mostly optional.

#### Alacritty

If you are using **Windows**, you must configure Alacritty to launch the correct shell, as it defaults to PowerShell.

```toml
[terminal]
shell = { program = "debian", args = ["",] }
```

*Windows: %APPDATA%\alacritty\alacritty.toml*

If you are using **macOS**, you must configure Alacritty to treat **option as alt** to enable the use of certain keybindings in terminal applications.

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

*Linux and macOS: ~/.config/alacritty/alacritty.toml*

Setting the shell to "Debian" on Linux or macOS breaks the config, but appending the Linux/macOS-file to the Windows-file causes no issues.

#### Helix

Consider "base16_transparent" if you would rather not download or configure themes for Alacritty and Zellij. Use `:theme` in Helix to preview the included themes.

```toml
theme = "rose_pine"
```

*~/.config/helix/config.toml*

#### Zellij

Zellij ships a large default configuration file.

1. Open `~/.config/zellij/config.kdl`
2. Search for "theme".
3. Uncomment the relevant line, and set the desired value.

```kdl
// Choose the theme that is specified in the themes section.
// Default: default
//
theme "rose-pine"
```

*~/.config/zellij/config.kdl*

### Themes

The default themes are mostly fine, but to get a matching look across all tools, I use the Rosé Pine theme.

- [Alacritty themes](https://github.com/alacritty/alacritty-theme) - Collection of Alacritty color schemes
- [Zellij Rosé Pine](https://github.com/rose-pine/zellij) - Soho vibes for Zellij

### Language Servers

Helix uses language servers to provide autocomplete, code actions, and diagnostics. You can see a list of installed servers by running `hx --health`. Language servers must be installed separately, and often with homebrew.

1. Let's take Java as an example. Pass 'java' to `hx --health` to see if an LSP is installed:

```bash
kristoffer@INVINCIBLE:~$ hx --health java
Configured language servers:
  ✘ jdtls: 'jdtls' not found in $PATH
...
```

2. Install it with Homebrew: `brew install jdtls`. And when the installation is done:

```bash
kristoffer@INVINCIBLE:~$ hx --health java
Configured language servers:
  ✓ jdtls: /home/linuxbrew/.linuxbrew/bin/jdtls
...
```

3. Helix now has full support for Java. Repeat for whichever languages or file-types are needed.

> 💡 The rust-analyzer LSP should be installed with rustup, not homebrew: `rustup component add rust-analyzer`

### Bonus: JetBrains Toolbox

As someone who also uses JetBrains IDEs, I like to include their [Toolbox App](https://www.jetbrains.com/toolbox-app/) in my basic setup.

## Summary

Installing everything should take only a few minutes and gives you a complete and consistent development environment across platforms. The result looks like this on my current machine:

![](/images/2025/07/image-1.png)

*In pane one, I have opened a diagnostic picker in Helix in one of the [rustlings](https://rustlings.rust-lang.org/) exercise files. Pane two is running the rustling executable. Pane three is showing the output from [Screenfetch](https://github.com/KittyKatt/screenFetch).*
