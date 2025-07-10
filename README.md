## 构建容器

```
docker build -t docker-hillstone-scvpn-client:latest .
```





# 运行容器

```
docker run -d \
  --name scvpn \
  --privileged \
  --restart always \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  -p 1080:1080 \
  -e VPN_SERVER="URL/IP" \
  -e VPN_PORT="PROT" \
  -e VPN_USER="username" \
  -e VPN_PASS='Password' \
  docker-hillstone-scvpn:latest-client:latest
```



# 不构建运行容器

```
docker run -d \
  --name scvpn \
  --privileged \
  --restart always \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  -p 1080:1080 \
  -e VPN_SERVER="URL/IP" \
  -e VPN_PORT="PROT" \
  -e VPN_USER="username" \
  -e VPN_PASS='Password' \
  caobei2013/docker-hillstone-scvpn-client:latest
```
