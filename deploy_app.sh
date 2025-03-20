# 定义变量
GIT_REPO="https://github.com/TeenaWhiteGabrial/easy-mock.git"
APP_DIR="/usr/src/code/easy-mock"
APP_BRANCH="naive"
DOCKER_COMPOSE_FILE="docker-compose.yml"
APP_PORT=3100  # 你的应用服务端口
MONGO_PORT=27017  # MongoDB服务端口
APP_CONTAINER_NAME="topaz-app"  # 应用容器名称
MONGO_CONTAINER_NAME="mongodb"  # MongoDB容器名称
# 删除代码仓库
rm -rf "$APP_DIR"
# 尝试克隆 Git 仓库
echo "---------------下载仓库代码--------------------"
git clone --branch "$APP_BRANCH" "$GIT_REPO" "$APP_DIR"
# 进入应用目录
echo "---------------进入应用目录--------------------"
cd "$APP_DIR"
# 停止并移除现有的 Docker 容器
echo "---------------停止docker容器--------------------"
docker compose -f "$DOCKER_COMPOSE_FILE" down
# 检查并停止占用APP_PORT的进程
echo "--------------检查应用端口：$APP_PORT -----------"
sudo lsof -i :$APP_PORT | grep LISTEN
if [ $? -eq 0 ]; then
  echo "-------------- 端口 $APP_PORT 被占用, 删除$APP_PORT 端口------------"
  sudo lsof -ti :$APP_PORT | xargs sudo kill -9
fi
# 检查并停止占用MONGO_PORT的进程
echo "--------------检查mongoDB端口: $MONGO_PORT -----------"
sudo lsof -i :$MONGO_PORT | grep LISTEN
if [ $? -eq 0 ]; then
  echo "-------------- 端口 $MONGO_PORT 被占用, 删除 $MONGO_PORT 端口------------"
  sudo lsof -ti :$MONGO_PORT | xargs sudo kill -9
fi
# 检查并删除现有的应用容器
if [ "$(docker ps -aq -f name=$APP_CONTAINER_NAME)" ]; then
  echo "-----------应用容器已启用，正在停止-------------------"
  docker stop $APP_CONTAINER_NAME
  docker rm $APP_CONTAINER_NAME
fi
# 检查并删除现有的 MongoDB 容器
if [ "$(docker ps -aq -f name=$MONGO_CONTAINER_NAME)" ]; then
  echo "----------数据库容器已启用，正在停止---------------"
  docker stop $MONGO_CONTAINER_NAME
  docker rm $MONGO_CONTAINER_NAME
fi
# 构建和启动容器
echo "--------------构建并启动容器中-------------"
docker compose -f "$DOCKER_COMPOSE_FILE" up --build -d
# 检查是否成功启动容器
if [ $? -ne 0 ]; then
  echo "---------------启动失败，请检查-----------------"
  exit 1
fi
# 打印成功提示信息
echo "----------------启动成功-------------"
