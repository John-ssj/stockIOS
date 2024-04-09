### 数据库mongoose

#### 数据结构

```shell
wallet:0
watchList:[{"stock":"","name":""}]
prtfolio:[{"stock":"","name":"","quantity":0,"totalCost":0}]
```

#### 在服务器（google）上创建

```shell
https://cloud.mongodb.com/v2/652497277ad4382c3f8bb723#/clusters

hayleyliu0311 E6gP438V0HudeuVg

stock iOS
```

##### 命令行链接

```shell
brew install mongosh
mongosh "mongodb+srv://stockiosdb.upwfkhg.mongodb.net/" --apiVersion 1 --username hayleyliu0311 --password E6gP438V0HudeuVg

# 查看所有数据库
show dbs
# 选择一个数据库
use myDatabase
# 查看数据库中的集合
show collections
# 查看某个集合中包含的数据
db.xxxdata.find()
```

#### 在express上链接

需要在npm上安装链接器（就是一堆用来管理链接的代码）方便用js语法链接mongoose数据库

```shell
npm install mongoose
```

```js
const mongoose = require('mongoose');

// MongoDB 连接
mongoose.connect('mongodb+srv://hayleyliu0311:E6gP438V0HudeuVg@stockiosdb.upwfkhg.mongodb.net/StockIOS?retryWrites=true&w=majority&appName=stockIOSDB');
```

## Server测试

```shell
curl http://127.0.0.1:8080/financial/init
curl http://127.0.0.1:8080/financial/addWatchList\?\symbol\=AAPL
curl http://127.0.0.1:8080/financial/getWatchList
curl http://127.0.0.1:8080/financial/addWatchList\?\symbol\=TSLA
curl http://127.0.0.1:8080/financial/addWatchList\?\symbol\=DELL
curl http://127.0.0.1:8080/financial/removeWatchList\?\symbol\=TSLA
curl http://127.0.0.1:8080/financial/addWatchList\?\symbol\=TSLA

curl -X POST http://127.0.0.1:8080/financial/sortWatchList \
-H "Content-Type: application/json" \
-d '{"sort": ["DELL", "AAPL", "TSLA"]}'

curl http://127.0.0.1:8080/financial/getWatchList


curl http://127.0.0.1:8080/financial/buy\?\symbol\=AAPL&quantity=1
curl http://127.0.0.1:8080/financial/buy\?\symbol\=TSLA&quantity=1
curl http://127.0.0.1:8080/financial/buy\?\symbol\=DELL&quantity=1

curl http://127.0.0.1:8080/financial/getPortfolio

curl -X POST http://127.0.0.1:8080/financial/sortPortfolio \
-H "Content-Type: application/json" \
-d '{"sort": ["DELL", "AAPL", "TSLA"]}'

curl http://127.0.0.1:8080/financial/getPortfolio


curl http://127.0.0.1:8080/financial/getAll
```

