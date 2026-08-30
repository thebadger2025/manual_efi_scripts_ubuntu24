To achieve this, you need a "one-shot" service. A one-shot service is designed to perform a specific task and then exit.
By setting the Type=oneshot and using the RemainAfterExit=no (which is the default) configuration, the service will
transition to an inactive state once the script finishes.

Since systemd services are managed by the init system, they have the authority to start/stop other services and perform
cleanup, provided they are run with sufficient privileges (which they are by default).

Here is the architectural breakdown and the implementation.

### 1. The Worker Script

First, create the script that will perform the actual logic. This script needs to be "self-destructing."

File: /usr/local/bin/setup-and-cleanup.sh

```bash
  #!/bin/bash

  # 1. Enable and start the target server
  echo "Enabling and starting the target server..."
  systemctl enable target-server.service
  systemctl start target-server.service

  # 2. Perform any other necessary setup here...
  echo "Setup complete."

  # 3. Self-destruct: Delete this script
  echo "Cleaning up: Deleting script..."
  rm -- "$0"
```

Note: $0 is a shell variable that holds the path to the currently executing script.

Important: Make the script executable:
sudo chmod +x /usr/local/bin/setup-and-cleanup.sh

────────────────────────────────────────────────────────────────────────────────

### 2. The systemd Service Unit

Now, create the service that triggers this script.

File: /etc/systemd/system/bootstrap-orchestrator.service

```ini
  [Unit]
  Description=Bootstrap Orchestrator: Enables server and cleans up
  After=network.target

  [Service]
  Type=oneshot
  # Execute the script
  ExecStart=/usr/local/bin/setup-and-cleanup.sh
  # Ensure the service is considered 'finished' immediately after the script exits
  RemainAfterExit=no

  [Install]
  WantedBy=multi-user.target
```

────────────────────────────────────────────────────────────────────────────────

### 3. Deployment Steps

To put this into action, follow these steps:

1. Create the target server service (if it doesn't exist) so the script has something to enable.
2. Reload systemd to recognize the new service:
   ```bash
     sudo systemctl daemon-reload
   ```
3. Enable and start your orchestrator:
   ```bash
     sudo systemctl enable bootstrap-orchestrator.service
     sudo systemctl start bootstrap-orchestrator.service
   ```

### How it works in sequence:

1. systemd starts bootstrap-orchestrator.service.
2. The service runs setup-and-cleanup.sh.
3. The script tells systemd to enable/start target-server.service.
4. The script deletes itself using rm -- "$0".
5. The script exits.
6. systemd sees the process has ended. Because Type=oneshot and RemainAfterExit=no, the bootstrap-orchestrator service
   is marked as inactive (dead).
7. The target-server is now running and enabled for future boots.

### ⚠️ Safety Warnings

- Testing: Always test the script manually (sudo /usr/local/bin/setup-and-cleanup.sh) before putting it in a service to
  ensure the rm command doesn't target anything unexpected.
- Error Handling: In a production environment, you should add set -e at the top of your bash script. This ensures that
  if the systemctl start command fails, the script stops immediately and does not proceed to delete itself, allowing you
  to debug the failure.
- Permissions: The script must be owned by root (or a user with sudo privileges) to ensure it can manage other services
  and delete itself from /usr/local/bin.