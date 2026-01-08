---
aliases: ["/3rd-prize-at-tg-hack/"]
title: "3rd Prize at TG:HACK"
date: 2025-04-22T13:05:05.000Z
draft: false
tags: ["Security", "CTF"]
cover:
  image: "/images/2025/04/tghack-2.jpg"
  alt: "3rd Prize at TG:HACK"
---

I recently participated in [TG:Hack](https://tghack.no/), which is Norway's largest Capture The Flag (CTF) competition. It is hosted at and is a part of Norway's largest LAN party: [The Gathering](https://www.tg.no/). The competition runs over four days, and the goal is to leverage your knowledge of computers, networking, programming, operating systems, compilers, authentication, cryptography, steganography, safe-cracking(!), and more to coerce secrets from combinations of data, programs, and hardware.

After a nail-biting last leg with strong finishes by several teams, featuring both jury interventions and pwned competition infrastructure, I was positively excited to be awarded the 3rd prize of NOK 2000.

![](/images/2025/04/thumbnail_IMG_2384.jpg)

*The oversized check I was awarded at the prize ceremony.*

My favorite challenge of the competition involved leveraging a *slight* misconfiguration to break the [Advanced Encryption Standard](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) (AES), which is used across most of the world's computer systems to prevent threat actors from accessing or tampering with communications and data. The solution required implementing an encryption oracle attack, for which I give a full technical write-up here: [Breaking AES-ECB with an Encryption Oracle Attack](/breaking-aes-ecb-with-an-encryption-oracle-attack/).

Meanwhile, enjoy a couple of photos that hopefully showcase the unique atmosphere of the event:

![](/images/2025/04/0A5AB142-3CED-4686-B7EB-191A5F5DD75F_1_105_c.jpeg)

![](/images/2025/04/0ADA4E95-C8B8-4440-AD30-EF4F22ED2D03_1_201_a-1.jpeg)

*The Gathering takes place every Easter in [Vikingskipet](https://en.wikipedia.org/wiki/Vikingskipet).*
