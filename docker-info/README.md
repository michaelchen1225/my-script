# Docker Cleanup & Inspection Script

### quick install

```bash
curl -O https://raw.githubusercontent.com/michaelchen1225/my-script/refs/heads/master/docker-info/docker-info.sh

chmod +x docker-info.sh

cp docker-inspect.sh /usr/local/bin/docker-info.sh
```

---

### Key features

> Quickly inspect Docker resources and identify cleanup targets

* Shows all running containers and their images
* Lists non-running containers (exited, created, paused, dead)
* Displays dangling (untagged) images
* Provides Docker disk usage summary
* Suggests common cleanup commands

---

### Output sections

* **Running containers**
* **Non-running containers**
* **Dangling images**
* **System disk usage (`docker system df`)**

---

### Suggested cleanup actions

* Remove dangling images

  ```bash
  docker image prune
  ```

* Remove all unused images

  ```bash
  docker image prune -a
  ```

* Remove all stopped containers

  ```bash
  docker container prune
  ```

---

### Usage

```bash
# Run the script
docker-inspect.sh
```

---

### Notes

* This script is **read-only** — it does not delete anything
* Always review output before running cleanup commands
* Requires Docker CLI installed and accessible
