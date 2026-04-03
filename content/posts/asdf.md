---
title: "How to securely erase a Hard-Disk Drive"
date: 2026-04-03T21:42:17.000Z
draft: false
tags: ["Linux", "Note"]
---

Hard-disk drives (HDDs) should be securely erased before being sold or recycled. This is a public note-to-self on how to achieve this in a simple and timely manner. 

### Prerequisites
The `shred` binary, which to my knowledge is included in all major Linux distributions. Moreover, you need a HDD which will be subject to secure erasure. 

**You can NOT use `shred` to SECURELY erase solid-state drives (SSDs) or so-called non-volatile memory express (NVMe) devices.** This is due to physical differences in the mechanism used to store information.

### Securely Erasing the HDD

Shred works by overwriting a target file or disk with noise, then optionally writing zero-bytes to obfuscate the erasure:

```bash
sudo shred --verbose --iterations=1 --zero <path-to-taget>
```

Your target can be a file or a disk (everything is a file). Disks typically have paths like `/dev/sdX`. Consider using `df --block-size=GB` to identify the correct path to your target HDD.

- The **verbose** option tells `shred` to report progress. The command can take hours or days to run, so this is highly recommended. 
- The **iterations** option tells `shred` how many overwrites to perform. The default is three, but one is sufficient under all but extreme threat models. 
- The **zero** option tells `shred` to obfuscate the erasure by writing the target with zero-bytes.
