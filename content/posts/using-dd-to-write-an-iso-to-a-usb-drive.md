---
aliases: ["/using-dd-to-write-an-iso-to-a-usb-drive/"]
title: "Using dd to Write an .iso to a USB Drive"
date: 2025-09-14T17:16:05.000Z
draft: false
tags: ["Linux", "Note"]
---

`dd` is one of those commands for which I have to look up proper usage every usage because I use it regularly but not often. As such, this is a public note-to-self, which may or may not be useful to the reader. 

## Prerequisites
The `dd` binary is, to my knowledge, included on macOS and all major Linux distributions.

## Writing the File

```bash
dd if= of= status=progress

```

- The **if** option tells `dd` to read from the provided path instead of stdin.
- The **of** option tells `dd` to write to the provided path instead of stdout. 
- The **status** option tells `dd` to show periodic transfer statistics.

The status option is primarily included because the program can otherwise seem unresponsive upon writing large .iso files, as the transfer to disk can take several minutes to complete.

## Find the Path to the Target Disk
Chances are any system that ships with `dd` also ships with `df`. You can use the latter to identify the path to the target disk.

```bash
df --block-size=GB

```

The `block-size` ⁣option tells df to show relevant size measures in units of gigabytes so the listed disks are easier to tell apart.
