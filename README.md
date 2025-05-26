# kube‑helper

A tiny Bash wrapper that starts, stops, restarts, and reports the status of
your **Colima** VM and **Minikube** cluster on macOS (Apple Silicon or Intel).

```text
▶️  kube-helper.sh start     # ensures Colima and Minikube are both running
🛑  kube-helper.sh stop      # shuts down the Minikube cluster then Colima
ℹ️  kube-helper.sh status    # shows Running / Stopped (coloured if the terminal supports it)
🔄  kube-helper.sh restart   # stop + start
```

## Features

* **One command controls both layers**—no more forgetting which one to start.
* **Colourful output** (green = Running, red = Stopped) when the terminal
  supports ANSI colours; plain text otherwise.
* **Zero external dependencies** beyond the tools you already need:
  * [Colima](https://github.com/abiosoft/colima)
  * [Minikube](https://github.com/kubernetes/minikube)
  * `docker` CLI (supplied by Colima)  
  Works with the stock macOS Bash 3.2.

## Prerequisites

```bash
brew install colima minikube docker lima-additional-guestagents
```

Make sure the Docker client points at Colima’s socket:

```bash
echo 'export DOCKER_HOST=unix://$HOME/.colima/default/docker.sock' >> ~/.bash_profile  # or ~/.zshrc
source ~/.bash_profile    # reload shell
```

## Installation

```bash
curl -o ~/bin/kube-helper.sh \
     https://raw.githubusercontent.com/andregca/macos-kube-helper/main/kube-helper.sh
chmod +x ~/bin/kube-helper.sh
```

## Usage

```bash
kube-helper.sh status    # quick health check
kube-helper.sh start     # spin everything up
kube-helper.sh stop      # graceful shutdown
kube-helper.sh restart   # bounce both layers
```

### Customising resources

Edit **`kube-helper.sh`** and tweak:

```bash
colima start --cpu 4 --memory 4 --disk 20      # Colima VM resources
MINIKUBE_ARGS=(--driver=docker --container-runtime=containerd)
```

## Example

```text
$ kube-helper.sh status
ℹ️  Current status
   Colima   : Running
   Minikube : Stopped
```

## Contributing

PRs are welcome—especially for:

* Additional OS / shell compatibility fixes
* Better error handling
* Nice‑to‑have flags (e.g. `--k8s-version` passthrough)

## Author

**Andre Gustavo Albuquerque**
[GitHub](https://github.com/andregca)

## License

Apache License 2.0 – see the [LICENSE](LICENSE) file.
