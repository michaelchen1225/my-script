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

### iexec

Run commands interactively inside a Kubernetes container without typing the full `kubectl exec` syntax.

**Common use cases**
- Quickly open a shell in a pod.
- Select a pod interactively when multiple pods exist.
- Reduce typing for frequent debugging.

**Example**
```bash
kubectl iexec
```

Or directly execute a command:

```bash
kubectl iexec -- ls /app
```

### image

List container images used by Pods, Deployments, StatefulSets, and other workloads.

**Common use cases**
- Audit image versions.
- Find outdated images.
- Verify deployed container tags.

**Example**
```bash
kubectl image pods
```

Example output:

```text
nginx:1.30
redis:7.2
busybox:1.37
```

### krew

Manage Krew plugins.

**Common use cases**
- Install plugins.
- Upgrade plugins.
- List installed plugins.

**Examples**

Install a plugin:

```bash
kubectl krew install neat
```

Upgrade all plugins:

```bash
kubectl krew upgrade
```

List installed plugins:

```bash
kubectl krew list
```

### neat

Remove unnecessary metadata from Kubernetes resource YAML.

**Common use cases**
- Clean exported manifests.
- Generate reusable YAML.
- Remove runtime-generated fields.

**Example**

Instead of:

```bash
kubectl get deployment nginx -o yaml
```

Use:

```bash
kubectl get deployment nginx -o yaml | kubectl neat
```

The output excludes fields such as:
- `managedFields`
- `resourceVersion`
- `uid`
- `status`

### ns

Quickly switch the current Kubernetes namespace.

**Common use cases**
- Avoid repeatedly using `-n`.
- Switch between development and production namespaces.

**Example**

```bash
kubectl ns production
```

Verify:

```bash
kubectl config view --minify
```

### pod-lens

Display Pods with useful runtime information in a concise, human-friendly format.

**Common use cases**
- Quickly inspect Pod health.
- View restart counts and readiness.
- Troubleshoot large namespaces.

**Example**

```bash
kubectl pod-lens
```

Typical information includes:
- Ready status
- Restarts
- Age
- Node
- IP
- Container status

### sick-pods

Find Pods that are unhealthy or require attention.

**Common use cases**
- Detect `CrashLoopBackOff` Pods.
- Find `Pending` Pods.
- Identify `ImagePullBackOff` and `Error` states.

**Example**

```bash
kubectl sick-pods
```

Example output:

```text
payments-api-6f8f7   CrashLoopBackOff
redis-0              Pending
nginx-7d5b           ImagePullBackOff
```

### status

Show a summarized health/status view of Kubernetes resources.

**Common use cases**
- Quickly check cluster health.
- Review workload readiness.
- Troubleshoot deployments.

**Example**

```bash
kubectl status
```

Typical summary includes:
- Deployments
- StatefulSets
- DaemonSets
- Pods
- Ready/Available counts

### view-allocation

Display CPU and memory requests/limits allocated across nodes.

**Common use cases**
- Check node resource allocation.
- Identify overcommitted nodes.
- Plan cluster capacity.

**Example**

```bash
kubectl view-allocation
```

Example output:

```text
NODE         CPU Requests   CPU Limits   Memory Requests   Memory Limits
worker-01    58%            120%         64%               95%
worker-02    32%            60%          41%               70%
```

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
