#!/bin/bash
# TODO 1: strict mode (exit on error, unset variables and failed pipes)
set -euo pipefail
MIN_NODE_MAJOR=22
# TODO 2: log() function that prints "[HH:MM:SS] message"
log() {
    echo "[$(date '+%H:%M:%S')] $*"
}


# TODO 3: change to the directory that contains this script
cd "$(dirname "${BASH_SOURCE[0]}")"
# TODO 4: if node is not installed, install the LTS version with nvm
if ! command -v node &>/dev/null; then
  log "Node.js not found. Installing via nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts && nvm use --lts
else
  log "✅ Node.js: $(node --version)"
fi
# TODO 5: log an error and exit 1 if the Node major version is below
NODE_MAJOR="$(node --version | sed 's/^v//' | cut -d. -f1)"
if [ "$NODE_MAJOR" -lt "$MIN_NODE_MAJOR" ]; then
  log "❌ Node ${MIN_NODE_MAJOR}+ required, found $(node --version)"
  exit 1
fi
# TODO 7: Docker check. Missing: log a warning with the install URL and
if ! command -v docker &>/dev/null; then
  log "⚠ Docker not found. Install:
https://docs.docker.com/engine/install/ubuntu/"
else
log "✅ Docker: $(docker --version | cut -d' ' -f3 | tr -d ',')"
fi
# TODO 8: Git check. Missing: log "sudo apt install git" and exit 1. Present:


 
if ! command -v git &>/dev/null; then
  log "❌ Git not found. Run: sudo apt install git"
  exit 1
fi
log "✅ Git: $(git --version | cut -d' ' -f3)"

# Under MIN_NODE_MAJOR: APP_PORT defaults to 3000 and can be overridden from
APP_PORT=3000
# TODO 9: exit 1 with an error if APP_PORT is already in use (use lsof; if
if lsof -i :"$APP_PORT" >/dev/null 2>&1; then
  echo "Error: port $APP_PORT is already in use." >&2
  exit 1
fi
# TODO 10: install the app dependencies in app/. If that fails, the script must stop.
cd app/
npm install
# TODO 11: log the Node, npm and Git versions

# TODO 12: change into app/ and start the app on APP_PORT
APP_PORT="$APP_PORT" npm start
