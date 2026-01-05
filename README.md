# 🔍 DeepReconX

**DeepReconX** is an aggressive subdomain enumeration and validation framework designed for **bug bounty hunters**, **penetration testers**, and **security researchers**.

It combines **passive intelligence**, **smart permutations**, **DNS resolution**, **web probing**, and **critical vulnerability scanning** into a single automated pipeline.

---

## ✨ Features

- 🚀 Passive subdomain enumeration (Subfinder, Chaos)
- 🧠 Intelligent permutation generation (AlterX, DNSGen)
- ⚡ High-performance DNS resolution (PureDNS)
- 🌐 Live web service detection (Httpx)
- 🧪 Critical & high-severity vulnerability scanning (Nuclei)
- 🎨 Colorized output & banners
- 🕒 Timestamped logging
- 🧩 Dependency validation
- ⚙️ Fast & silent modes

---

## 🛠️ Tools Used

DeepReconX integrates the following open-source tools:

- subfinder
- chaos
- alterx
- dnsgen
- puredns
- dnsx
- httpx
- nuclei

---

## 📦 Installation

### 1️⃣ Clone the repository
```bash
git clone https://github.com/Hotwrist/deepreconX.git
cd deepreconX
chmod +x deepreconx.sh
```
---
## 🔌 DNS Resolvers (Required for PureDNS)

DeepReconX uses **PureDNS** for high-performance DNS resolution.

You must provide a list of **trusted DNS resolvers** in a file named:

```text
resolvers.txt
```
which I have already provided.
---
## 🚀 Usage
```bash
./deepreconx.sh example.com
```
### ⚡ Fast Mode (skip Nuclei)
```bash
./deepreconx.sh example.com --fast
```

### 🔇 Silent Mode
```bash
./deepreconx.sh example.com --silent
```

---
## 📂 Output Structure
```bash
output/example.com/
├── subfinder.txt
├── chaos.txt
├── all_subs.txt
├── perms.txt
├── alterx_candidates.txt
├── dnsgen.txt
├── mutations.txt
├── final_candidates.txt
├── resolved.txt        # VALID SUBDOMAINS
├── dns_info.txt
├── httpx_live.txt      # LIVE WEB SERVICES
├── nuclei_findings.txt # CRITICAL/HIGH ISSUES
└── run.log
```
## ⚠️ Disclaimer
This tool is intended for authorized security testing, bug bounty programs, and educational purposes only.

❌ Unauthorized scanning of systems you do not own or have permission to test is illegal.

The author assumes no responsibility for misuse.

## 👤 Author

```bash
John Ebinyi Odey
Offensive Security Researcher
Internal Network & Web Application Penetration Tester
C++ & Security Tool Developer
```
