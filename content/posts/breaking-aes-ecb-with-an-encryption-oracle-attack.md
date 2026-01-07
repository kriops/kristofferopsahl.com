---
title: "Breaking AES-ECB with an Encryption Oracle Attack"
date: 2025-04-29T12:42:53.000Z
draft: false
tags: ["Python", "Security", "#Import 2025-09-14 21:16"]
math: true
showToc: true
cover:
  image: "/images/2025/04/20250416223203-a79d4303.jpg"
  alt: "Breaking AES-ECB with an Encryption Oracle Attack"
---

This is a write-up of one of the challenges from this year's [TG:Hack](https://tghack.no/). I wrote about my participation in another post: [3rd Prize at TG:Hack](/3rd-prize-at-tg-hack/).

## Background
TG:Hack is a Capture-the-Flag competition where the objective is to identify and leverage security flaws in various entities. As evidence of a successful hack, you must extract small secrets, i.e., flags, and provide them back to the organizer. The flags are strings that look like this: `TG25{some_secret_value}`.

This challenge was categorized as *pwn*, which normally implies the goal might be a full system compromise, and was presented as follows:

![](/images/2025/04/qwe.png)*Screenshot from ctf.tghack.no*I immediately noticed: 

- It involves breaking the AES encryption algorithm.
- The name (*Pad That Thang*) suggests we're looking for a padding attack.
- There is a server from which I need to coerce a secret.

I did **not** notice that we were provided with the server implementation, so I will show how I approached and solved the challenge despite this. In retrospect, I could have avoided the reconnaissance phase altogether.

All code in the article can be viewed on [GitHub](https://github.com/kriops/EncryptionOracleAttack), including the [provided server implementation](https://github.com/kriops/EncryptionOracleAttack/blob/main/server.py).

## Theory
This section seeks to introduce the key concepts in this article. Readers at least superficially familiar with cryptanalysis and modern cryptography might consider jumping ahead to the next section.

### Exclusive Disjunction
Exclusive Disjunction (XOR) is a logical operation that with two inputs can be informally understood as exclusively \(A\) or exclusively \(B\), but not both \(A\) and \(B\). It is denoted by the \( \oplus \) symbol, such that \( XOR(A, B) = A \oplus B \) and has the following truth table:

\[ \begin{array}{c|c|c} A & B & A \oplus B \\ \hline 0 & 0 & 0 \\ 0 & 1 & 1 \\ 1 & 0 & 1 \\ 1 & 1 & 0 \end{array} \]

For the purposes of this article, XOR can be viewed as a masking operation. Given the binary representation of some arbitrary data, one can derive a corresponding masked message through the bitwise application of some binary mask of the same length. I.e.:

\[ \text{message} \oplus \text{mask} = \text{masked message} \]

Unmasking is done by applying the mask to the masked message:

\[ \text{masked message} \oplus \text{mask} = \text{message} \]

It is impossible to unmask the message without knowledge of the mask, which is why data masked with a cryptographically random mask is completely indistinguishable from random data. As an example, let \(\text{mask}=0101\) and \(\text{message}=0011\). Then by bitwise application of  XOR:

\[ 0011 \oplus 0101 = 0110 \]

We apply the same mask to the masked message:

\[ 0110 \oplus 0101  =  0011 \]

Which indeed yields the original message.

💡Using XOR to mask and unmask data forms the basis for a provably unbreakable cryptographic system known as one-time pads (OTP). Securely implementing OTP requires you to exchange keys of length equivalent to the plaintext, which creates a Catch-22 for use cases where you cannot viably exchange keys out-of-band or offline. Which are most use cases. And if you recycle keys, a threat actor can simply XOR two ciphertexts to recover the recycled key.### Advanced Encryption Standard
The Advanced Encryption Standard (AES) is a modern, secure and widespread system for cryptography. A thorough understanding of the algorithm is not required to follow this article, but some relevant properties must be recognized:

- **Symmetric**: The same key is used for encryption and decryption.
- **Block cipher**: A fixed amount of data is encrypted at a time. Plaintext is broken up into blocks before encryption. Incomplete blocks are padded with data to allow encryption.
- **Unbroken**: No practical attacks exist against correctly implemented AES.

AES relies on the XOR operation, yet a single key equivalent to 16, 24, or 32 characters can be used to encrypt arbitrary amounts of data. This makes AES significantly more practical than OTP for almost all applications. Key exchange can be done over insecure channels through public key encryption. In fact, nearly all your browser traffic is encrypted with AES after exchanging keys through a process known as the [Diffie-Hellman key exchange](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange), as part of the TLS/SSL/HTTPS family of protocols.

### AES Modes of Operation
AES specifies different modes of operation, with differing characteristics in terms of security and performance, and for any given use case it is crucial to understand which mode(s) are appropriate. 

#### Electronic Codebook Mode
The Electronic Codebook Mode (ECB) is the naive application of AES, which entails directly encrypting a message with a key. This can be described in terms of the function pair

\[ \begin{aligned} \text{AES}_e(\text{key}, \text{plaintext}) &\mapsto \text{ciphertext} \\ \text{AES}_d(\text{key}, \text{ciphertext}) &\mapsto \text{plaintext} \end{aligned} \] 

where \(\text{AES}_e\) and \(\text{AES}_d\) respectively denote the encryption and decryption operations.

ECB features attractive performance characteristics due to independent encryption of blocks, though it is only secure for high-entropy plaintext because patterns therein, e.g., repeated blocks, can often be gleaned from the ciphertext.

#### Cipher Block Chaining Mode
The Cipher Block Chaining Mode (CBC) allows secure encryption of arbitrary data, by applying a random mask to the data before encryption, thus stripping it of any discernable patterns. 

Consider a message split into \(n\) blocks of plaintext \(p_1, p_2, \dots, p_n\), with corresponding ciphertexts \(c_1, c_2, \dots, c_n\). To ensure sufficient entropy, a single-block mask called an initialization vector (\(\text{IV}\)) is generated by means of a cryptographically secure random number generator. The mask is then applied to the first block of plaintext, and the result encrypted:

\[ \text{AES}_e(\text{key}, p_1 \oplus \text{IV}) = c_1 \]

The same mask can never be reused for different blocks or messages. Rather than generating a new mask for every block of plaintext, one can leverage the fact that \(c_1\) is now guaranteed to appear indistinguishable from random data to a threat actor. When the initial block has been encrypted, subsequent blocks of plaintext are masked with the ciphertext of preceding blocks:

\[ \text{AES}_e(\text{key}, p_2 \oplus c_1) = c_2 \\ \text{AES}_e(\text{key}, p_3 \oplus c_2) = c_3 \\ \dots \\ \text{AES}_e(\text{key}, p_n \oplus c_{n-1}) = c_n \]

Advantages of CBC include a single IV being able to seed the secure masking of an unlimited number of blocks. Furthermore, the requirements related to storing, transporting, and sourcing entropy for an \(IV\) is usually negligible. Disadvantages include ciphertext being pricier to calculate, and parallelization being prevented by the linear dependence between blocks.

### ASCII Encoding
The simplest way to represent characters as bytes is the American Standard Code for Information Interchange (ASCII) character encoding. A byte consists of eight bits, meaning a byte can contain \( 2^8 = 256 \) different combinations of bits, though only the printable characters are relevant for this article:

Group Name
ASCII Range
Characters

Space
32
(Space)

Punctuation
33-47
!"#$%&'()*+,-./

Digits
48-57
0123456789

Punctuation
58-64
:;<=>?@

Uppercase Letters
65-90
ABCDEFGHIJKLMNOPQRSTUVWXYZ

Punctuation
91-96
[]^_`

Lowercase Letters
97-122
abcdefghijklmnopqrstuvwxyz

Punctuation
123-126
{|}~

## Discussion
Breaking weak encryption is seldom about analytically arriving at an exact solution, but rather about sufficiently reducing the search space such that a brute force attack becomes feasible, if not trivial.

For context, the expected time it takes to brute-force a 256-bit AES-key is about 40 000 000 000 000 000 000 000 000 000 000 000 000 000 **times the age of the universe**, according to [one internet comment](https://old.reddit.com/r/theydidthemath/comments/1x50xl/time_and_energy_required_to_bruteforce_a_aes256/). 128-bits is substantially less, yet the expected time to break it is still measured in [billions times the lifetimes of the universe](https://crypto.stackexchange.com/questions/48667/how-long-would-it-take-to-brute-force-an-aes-128-key).

### Reconnaissance
#### The Encryption Oracle
The first step of any attack is to gather information. I first connected to the server to see what it does:

```bash
$ nc localhost 12333
Enter plaintext: Hello, world!
Encrypted: 58368ce36ef102f3617a37a45bd77a640148e73358ddc97dd0c9b81c93518f6433365d396f89b3f5231ede8d7d4cfb45
```

- The server prompted me: `Enter plaintext:`
- I responded `Hello, world!`
- The server responded `Encrypted: 58368ce36ef102f3617a37a45bd77a640148e73358ddc97dd0c9b81c93518f6433365d396f89b3f5231ede8d7d4cfb45`

Something that answers the question, “Given a plaintext, what is the corresponding ciphertext?” is the literal definition of an encryption oracle.

#### Electronic Codebook Mode
With basic interaction figured out, I move on to try different plaintext structures. Sending a long repeating message turns out to induce repetition in the ciphertext:

```bash
$ nc localhost 12333
Enter plaintext: QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
Encrypted: e9ebccfc5e702f6dd24fc4eb884e1c7ce9ebccfc5e702f6dd24fc4eb884e1c7c930aad78bad4db5bb9e6de89a90833df45c7239446f26ec7fad560dd6978f6fb
```
*The plaintext consists of the letter Q repeated 32 times.

*Here the ciphertext is broken into 32-character chunks for convenience:

Character no.
Response Substring

0-31
**e9ebccfc5e702f6dd24fc4eb884e1c7c**

32-63
**e9ebccfc5e702f6dd24fc4eb884e1c7c**

64-95
930aad78bad4db5bb9e6de89a90833df

96-127
45c7239446f26ec7fad560dd6978f6fb

Given ciphertext repetitions, the server is likely running AES in ECB mode.

#### Block Size
I chose to send the previous message with exactly 32 characters because I know that AES only specifies support for 16-byte blocks. One character is encoded with one byte, yielding exactly one repetition. While consistent with my assumption about block size, it does not constitute proof. This is proof:

Plaintext
First Block of Ciphertext

QQQQQQQQQQQQQQ
4920252f896a3e429f26b76b4a4d79cd

QQQQQQQQQQQQQQQ
42e8c8b4f9f381482dccb64590a4facb

QQQQQQQQQQQQQQQQ
**e9ebccfc5e702f6dd24fc4eb884e1c7c**

QQQQQQQQQQQQQQQQQ
**e9ebccfc5e702f6dd24fc4eb884e1c7c**

The ciphertext repeats for the plaintexts of length 16 and greater. Thus, the block size must indeed be exactly 16 bytes.

#### Response Size
AES is a block cipher, which means the plaintext must be extended to a multiple of the block size, i.e., 16 bytes, before encryption is possible. Encrypting anything between 1 and 16 bytes should yield exactly one full block of ciphertext. Encrypting a single-character message, however, returns two blocks of ciphertext:

```bash
$ nc localhost 12333
Enter plaintext: Q
Encrypted: 930aad78bad4db5bb9e6de89a90833df45c7239446f26ec7fad560dd6978f6fb
```
Taking the competition context into account, my immediate presumption is that the flag is simply appended to the plaintext before encryption.

#### Summary of Reconnaissance
I have determined AES in ECB mode is used to encrypt arbitrarily supplied plaintext by an oracle. I hypothesize the flag is appended to the plaintext before it is encrypted. The block size is confirmed to be 16 bytes.

💡Everything I have discovered so far, including my hypothesis, was plain as day in the server code supplied with the challenge. Always read the full text in exercises!### Proof of Concept
There is a straightforward way to validate and test what I know and hypothesize so far. My premises are:

- The flag, which starts with `TG25{`, gets appended to the plaintext.
- The plaintext gets broken into 16-character blocks before encryption.
- Equal blocks of plaintext result in equal blocks of ciphertext.

The test is simple. I ask the oracle to encrypt `AAAAAAAAAAATG25{AAAAAAAAAAA`:

```bash
$ nc localhost 12333
Enter plaintext: AAAAAAAAAAATG25{AAAAAAAAAAA
Encrypted: abac81c9f79df7df012bf66ec62880c9abac81c9f79df7df012bf66ec62880c9028fbbf987b527b67538ca964b94353530bec1fe8b27492488662892e04b17eb
```
If my hypothesis is correct, the server will extend the second block so it equals the first, which will cause the first two blocks of ciphertext to be equal. And, indeed:

Block 1
Block 2

Supplied Plaintext
AAAAAAAAAAATG25{
AAAAAAAAAAA

Extended Plaintext
AAAAAAAAAAATG25{
AAAAAAAAAAATG25{

Ciphertext
**abac81c9f79df7df012bf66ec62880c9**
**abac81c9f79df7df012bf66ec62880c9**

Thus, the hypothesis is validated.

💡Knowing the first characters of the flag is not a requirement, and the first loop of the technique I am about to implement yields the same result.### The Attack
The proof of concept showed it is possible to leverage the encryption oracle to confirm the presence of known bytes in the extended plaintext. The technique must be generalized to also identify unknown bytes, likely from the set of printable ASCII characters. Either way, the attack will be simple:

- Supply plaintext such that after the server extends it, there is a baseline block with 15 known bytes, i.e., one unknown byte.
- For each printable ASCII character, have the oracle encrypt a similar block, except completed with a known character.
- Compare ciphertexts for the known blocks with the baseline block. Equal ciphertexts mean the next byte of the flag has been identified.
- Repeat steps 1-3 until the flag is extracted, but with one more known byte for each iteration.

This is a brute-force attack, but the difference to the naive approach is stark: The size of the search space has been reduced from \(2^{128} \approx 3.4 \times 10^{38}\) to at most \(3200\), which essentially amounts to a \(100\%\) reduction. 

#### Implementation

```python
import re
import string

from message_sender import MessageSender

FLAG_PATTERN = re.compile(r"^TG25\{\S+\}$")
BLOCK_SIZE = 16

if __name__ == "__main__":
    sender = MessageSender(block_size=BLOCK_SIZE)
    flag = ""
    while FLAG_PATTERN.fullmatch(flag) is None:
        baseline_plaintext = "Q" * (
                BLOCK_SIZE + (BLOCK_SIZE - 1) - (len(flag) % BLOCK_SIZE)
        )
        baseline_ciphertext = sender.send(baseline_plaintext)

        for c in string.printable:
            guess_plaintext = baseline_plaintext + flag + c
            guess_ciphertext = sender.send(guess_plaintext)
            chunk_num = 1 + (len(flag) // 16)
            if baseline_ciphertext[chunk_num] == guess_ciphertext[chunk_num]:
                flag += c
                break
```
*Print statements are removed for readability. [MessageSender](https://github.com/kriops/EncryptionOracleAttack/blob/main/message_sender.py) conceals some boilerplate networking code. 

*I think the code mostly speaks for itself, but some points of clarification might be useful:

- For convenience, MessageSender.send() returns a list of strings, where each string corresponds to exactly one block of ciphertext. 
- To avoid accidentally closing sockets by sending empty strings, I added a full block of data before any known bytes. This means that the zero-indexed block one is the first baseline block.
- Whenever the number of known bytes is a multiple of the block size, i.e., 16, the next block to the right becomes the baseline block. Whenever this happens, the plaintext length must decrease by \(\text{block size} - 1\).

#### Execution
The following excerpt from the logs shows how the plaintext flag fills out as bytes are discovered. Notice hos the number of Q characters are the same in the baseline and the guesses. As the flag reaches 16 characters, the baseline is reset to zero known bytes, and the target block changes from 1 to 2.

```
Guess | QQQTG25{4nY_Bl0N --> ['4dd57b3777963f4be5cd074d3a9e48ee', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QQQTG25{4nY_Bl0T --> ['c3664b4d5ae1965c23bdb4a831c3787b', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QQQTG25{4nY_Bl0W --> ['3a87bbdfc7d905023b5eb7286b73e5d5', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Match | Block: 1 | Character: W | Updated Flag: TG25{4nY_Bl0W

Baseline | QQ --> ['b99a9948c20a8af6b593b9b30d83af9d', '6661f5e343c27321ed8bdd4f49dc901a']
Guess | QQTG25{4nY_Bl0W{ --> ['7c52dd38311d00e64439a3d3b3e7ebb5', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QQTG25{4nY_Bl0W} --> ['302a92b4e5d6fbd88ebcf0b4ab2e48ee', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QQTG25{4nY_Bl0Wf --> ['b99a9948c20a8af6b593b9b30d83af9d', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Match | Block: 1 | Character: f | Updated Flag: TG25{4nY_Bl0Wf

Baseline | Q --> ['930aad78bad4db5bb9e6de89a90833df', '45c7239446f26ec7fad560dd6978f6fb']
Guess | QTG25{4nY_Bl0Wf{ --> ['baf91b19e56ac13d94bf5c2e099427e8', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QTG25{4nY_Bl0Wf} --> ['f09d3a380ee40e7aed57043a6abba72e', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QTG25{4nY_Bl0Wff --> ['bf32dfc009abc6ecbc7159a0d9171081', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QTG25{4nY_Bl0Wf1 --> ['930aad78bad4db5bb9e6de89a90833df', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Match | Block: 1 | Character: 1 | Updated Flag: TG25{4nY_Bl0Wf1

Baseline |  --> ['e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | TG25{4nY_Bl0Wf1{ --> ['d46f58045eedcb8e46ea690291deb6b2', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | TG25{4nY_Bl0Wf1} --> ['11f70a13dbb1c56861cb4dedc0b367a8', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | TG25{4nY_Bl0Wf1f --> ['ff76f1b84c1783aab1ed64c16453625c', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | TG25{4nY_Bl0Wf11 --> ['22a8462bb76efc3f8cc4f360f90ef15f', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | TG25{4nY_Bl0Wf15 --> ['e14db44dd1e30896b0157db4cb1e9337', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Match | Block: 1 | Character: 5 | Updated Flag: TG25{4nY_Bl0Wf15

Baseline | QQQQQQQQQQQQQQQ --> ['42e8c8b4f9f381482dccb64590a4facb', '08d580785871554f0d5717ea5e8ee406', 'f82c012bca6216d0cbb2cc0335eac17c']
Guess | QQQQQQQQQQQQQQQTG25{4nY_Bl0Wf15{ --> ['42e8c8b4f9f381482dccb64590a4facb', 'c38d925673fcb09c07ddd6d2364e98a6', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QQQQQQQQQQQQQQQTG25{4nY_Bl0Wf15} --> ['42e8c8b4f9f381482dccb64590a4facb', '69bfc975e72c906dda9e43acec70e691', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QQQQQQQQQQQQQQQTG25{4nY_Bl0Wf15f --> ['42e8c8b4f9f381482dccb64590a4facb', '7bf5b050863b965d807968409994a9a4', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QQQQQQQQQQQQQQQTG25{4nY_Bl0Wf151 --> ['42e8c8b4f9f381482dccb64590a4facb', '99d09549512bb2146f5f429db99c25a4', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QQQQQQQQQQQQQQQTG25{4nY_Bl0Wf155 --> ['42e8c8b4f9f381482dccb64590a4facb', 'dc4728b2ce4cdb69e473afe82d1e424e', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QQQQQQQQQQQQQQQTG25{4nY_Bl0Wf15H --> ['42e8c8b4f9f381482dccb64590a4facb', '08d580785871554f0d5717ea5e8ee406', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Match | Block: 2 | Character: H | Updated Flag: TG25{4nY_Bl0Wf15H

Baseline | QQQQQQQQQQQQQQ --> ['4920252f896a3e429f26b76b4a4d79cd', '3a704a9b70043de9dbb724bd9825646e', '48dee7e78618064b2ff02a40b9274027']
Guess | QQQQQQQQQQQQQQTG25{4nY_Bl0Wf15H{ --> ['4920252f896a3e429f26b76b4a4d79cd', '06753ceae26dc9a92c2aeed857f2701c', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
Guess | QQQQQQQQQQQQQQTG25{4nY_Bl0Wf15H} --> ['4920252f896a3e429f26b76b4a4d79cd', '033f149e043b51c94e393edb1954d8b1', 'e14db44dd1e30896b0157db4cb1e9337', '92d83fb7da4d6573df88ebeffef1e81f']
```
*The logs are generated from a slightly cheating version of the attack, which only guesses characters that exist at least once in the solution.

*## Conclusion
My main takeaway from the challenge is that Crypto is hard, and even if you do not roll your own, you must be mindful to not break the security model of whichever algorithm or implementation you are using. I also felt a little pinch of excitement from the fact that a proper break of AES might very well lead to the near complete collapse of modern society, thought that is of course highly unlikely.
