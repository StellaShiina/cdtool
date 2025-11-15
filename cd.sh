set -e

# node,npm based on nvm
export NVM_DIR="${HOME}/.nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"
[ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"

# vars
WORK_DIR=/root/dev/gocd
ACCOUNT=StellaShiina
PROJECT=cs3604-trae-base-project
REPO_URL="https://github.com/${ACCOUNT}/${PROJECT}.git"
# project cmd
SERVICE_NAME=12306
BACKEND_ENTRY=cmd/server/main.go
BACKEND_BIN=12306-server
BACKEND_PATH=/opt/12306/12306-server
FRONTEND_PATH=/var/www/dev/12306/main

echo "Start CD"

######
echo "Cloning or update repo"

cd "$WORK_DIR"

if [[ -d $PROJECT ]]; then
    cd $PROJECT
    git checkout main
    git pull
else
    git clone $REPO_URL
    cd $PROJECT
    git checkout main
fi

#####
echo "Restart docker compose"

docker compose down -v && docker compose up -d

echo "$DOCKER_LOG"

#####
echo "Build and run backend"
cd backend

go mod tidy
go build -o "$BACKEND_BIN" "$BACKEND_ENTRY"

systemctl stop "$SERVICE_NAME"

mv "$BACKEND_BIN" "$BACKEND_PATH"

systemctl start "$SERVICE_NAME"
systemctl enable "$SERVICE_NAME"

#####
echo "Build and deploy frontend"
cd ../frontend

npm install
npm run build

cp -r dist/* "$FRONTEND_PATH"
