# kubectl krew plugin installer

### quick install

```bash
curl -O https://raw.githubusercontent.com/michaelchen1225/my-script/refs/heads/master/install-krew/krew-plug.sh

chmod +x krew-plug.sh

cp install-krew-plugins.sh /usr/local/bin/krew-plug.sh
```

---

### Key features

> Install commonly used kubectl krew plugins in one go

* Automatically checks if krew is installed
* Updates krew plugin index before installation
* Batch installs multiple useful plugins
* Simple and fast setup for Kubernetes tooling

---

### Installed plugins

* iexec
* image
* krew
* neat
* ns
* pod-lens
* sick-pods
* status
* view-allocations

---

### Usage

```bash
# Run the script
krew-plug.sh
```

---

### Notes

* Make sure `kubectl` is installed and configured

* Krew must be installed before running this script

* If krew is missing, the script will exit with a reference link

* You can modify the `PLUGINS` array to customize your setup
