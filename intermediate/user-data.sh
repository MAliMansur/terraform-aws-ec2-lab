#!/usr/bin/env bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y nginx

# Current AWS Ubuntu images normally include SSM Agent. These commands also
# install/start it when the snap is available but the agent is missing.
if command -v snap >/dev/null 2>&1; then
  snap install amazon-ssm-agent --classic || true
  systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent || true
fi

INSTANCE_HOSTNAME="$(hostname)"

cat > /var/www/html/index.html <<HTML
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Terraform EC2 Lab</title>
    <style>
      body { font-family: Arial, sans-serif; max-width: 760px; margin: 80px auto; padding: 0 24px; color: #172033; }
      .card { border: 1px solid #d9deea; border-radius: 14px; padding: 32px; box-shadow: 0 8px 24px rgba(23, 32, 51, 0.08); }
      h1 { color: #5c4ee5; }
      code { background: #f1f3f9; padding: 3px 7px; border-radius: 5px; }
    </style>
  </head>
  <body>
    <main class="card">
      <h1>Terraform deployment successful</h1>
      <p>This Nginx server was created by the intermediate AWS EC2 lab.</p>
      <p>Instance hostname: <code>${INSTANCE_HOSTNAME}</code></p>
    </main>
  </body>
</html>
HTML

systemctl enable --now nginx
