# fastdfs的dockerfile
## 构建

将安装包及文件拷贝到统一目录下，运行命令
```bash
docker build -t fastdfs:4 --rm=true ./
```
## 运行
### tracker
#### 环境变量参数
- TRACKER_SERVER ： tracker服务端ip
- TR_NGX_PORT    ： tracker服务端上运行的nginx端口
- ST_NGX_PORT    ： storage服务端上运行的nginx端口


```bash
docker run -ti -d --name t1 -v ~/tracker_data:/fastdfs/tracker/data --net=host -e TRACKER_SERVER=192.168.1.81:22122 -e TR_NGX_PORT=7090 -e ST_NGX_PORT=7050 fastdfs:4 tracker
```


### storage
#### 环境变量参数

- GROUP_NAME ：创建的storage属于哪个group，不填写则为1      例： GROUP_NAME=group2
- 其他参数同上

```bash
    docker run -ti -d --name s1 -v ~/storage_data:/fastdfs/storage/data -v ~/store_path:/fastdfs/store_path --net=host -e TRACKER_SERVER=192.168.1.81:22122 -e TR_NGX_PORT=7090 -e ST_NGX_PORT=7050 fastdfs:4 storage
```

### 重新配置tracker-nginx （初次构建集群或集群发生扩容等变化时，需要重新配置tracker服务端的nginx.conf）
#### 参数

- /nginx-conf.sh : 配置nginx.conf的程序，功能是修改配置文件内容并启动或重启nginx（自动判断） 

```bash
    docker exec -it XXX /nginx-conf.sh
```

# tip
## 查看集群状态

    fdfs_monitor /etc/fdfs/client.conf

## 测试上传文件
 
    /usr/local/bin/fdfs_test /etc/fdfs/client.conf upload anti-steal.jpg 

## nginx.conf 目录

    /usr/local/nginx/nginx.conf 

