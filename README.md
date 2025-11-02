Below is a **complete `README.md`** you can drop into your repo root.
It documents the purpose, structure, usage, and requirements for both the Bash and PowerShell versions of your scripts.
I wrote it in a clean, professional, GitHub-friendly style with code blocks, tables, and example commands.

---

```markdown
# Quantum-Safe Dev Environment Scripts

This repository contains automation scripts for setting up a **Docker-based OpenSSL 3 development environment with post-quantum cryptography (PQC) support**, using the `openquantumsafe/oqs-ossl3` image.  
Both **Linux/macOS (Bash)** and **Windows (PowerShell)** versions are provided.

The environment includes:

- OpenSSL 3 with ML-KEM and Dilithium PQC algorithms
- Apache HTTP server with TLS enabled
- Automatic generation of a hybrid post-quantum certificate at container startup
- Optional interactive shell inside the container for development and testing

---

## 📁 Repository Structure

```

/
├── bash/
│   ├── 1.sh       # Builds image and runs container interactively
│   └── 2.sh       # Same as above but with inline comments for learning/reference
│
└── Windows/
├── 1.ps1      # PowerShell version of build + run script
└── 2.ps1      # Commented version for Windows users

````

| Folder | OS / Shell | Contents |
|--------|------------|----------|
| `bash/` | Linux / macOS (Bash) | `.sh` scripts for building & running container |
| `Windows/` | Windows PowerShell | `.ps1` equivalents of the same scripts |

---

## ✅ What the Scripts Do

| Step | Description |
|------|-------------|
| 1 | Create a temporary build context and dynamically write a `Dockerfile` |
| 2 | Build a Docker image that installs Bash, Vim, cURL, and Apache with SSL |
| 3 | Serve a demo web page inside the container |
| 4 | Auto-generate a **quantum-safe certificate** on first run using `dilithium3` + `mlkem768` |
| 5 | Drop user into an interactive shell with OpenSSL PQC tools ready |
| 6 | Expose ports `8080` (HTTP) and `8443` (HTTPS) to the host |

---

## 🔧 Requirements

### Linux/macOS
- Docker installed and running
- Bash (`/bin/bash`)
- `curl` (optional for testing container output)

### Windows
- Docker Desktop (WSL2 backend recommended)
- PowerShell 7+ recommended (works in Windows PowerShell 5.1)
- Execution policy may need to be changed:  
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
````

---

## ▶️ Usage

### On Linux/macOS

```bash
cd bash
chmod +x 1.sh
./1.sh
```

Or run the fully commented teaching version:

```bash
./2.sh
```

---

### On Windows PowerShell

```powershell
cd Windows
.\1.ps1
```

Or the commented version:

```powershell
.\2.ps1
```

---

## 🌐 After Container Starts

You should see a message like:

```
Container ready. Try:
  openssl list -signature-algorithms | grep -i dilithium
  curl -k https://localhost:8443
```

Then you will be inside a Bash shell **inside the container**.

### Test Dilithium support in OpenSSL:

```bash
openssl list -signature-algorithms | grep -i dilithium
```

### Test the HTTPS endpoint (host machine):

```bash
curl -k https://localhost:8443
```

Expected output:

```html
<h1>Quantum-Safe Dev Environment</h1>
<p>OpenSSL + Apache + ML-KEM + Dilithium</p>
```

---

## 🔐 About the Post-Quantum Certificate

The container generates a new hybrid certificate **on each fresh run**, using:

* **Dilithium3** (signature)
* **ML-KEM-768** (key encapsulation)
* Valid for 1 day (`-days 1`)
* Self-signed (`-x509`)

This enables experimentation with PQC-ready TLS stacks, browsers, proxies, etc.

---

## 🧽 Cleanup

The scripts automatically remove the temporary build folder after exit.

To remove the built image manually:

```bash
docker rmi oqs-dev
```

---

## 📜 License

Copyright 2025 Robert Kuschel
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License...

| License    | Notes                                     |
| ---------- | ----------------------------------------- |
| Apache 2.0 | ✅ Permissive + explicit patent protection |

---

## 🗺️ Roadmap (optional enhancements)

* Add `docker-compose.yml` for optional persistent volumes
* Add flag for "no cleanup" debugging mode
* Add CI workflow (GitHub Actions) to auto-build image
* Add option to enable PQC-TLS in Apache config (port 8443)
* Add Wireshark instructions for PQC handshake visibility

---

## ✉️ Maintainer

**Author:** Rob Kuschel
**Contact:** (add email or GitHub profile link here)

```
---

### Want me to tailor it further?

✅ Add screenshots  
✅ Add shields.io badges (e.g., Docker, MIT, PowerShell, Bash)  
✅ Add table of Windows vs Linux behavior  
✅ Add animated terminal GIF demo  
✅ Rewrite in more formal or more casual tone  

Just say the word and I’ll revise accordingly.
```
