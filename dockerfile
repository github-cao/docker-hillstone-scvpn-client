FROM centos:7

# 替换 YUM 源（阿里云）
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo && \
    yum clean all && yum makecache

# 安装依赖和构建工具
RUN yum install -y curl gcc make iproute net-tools expect socat && \
    yum clean all

# 编译安装 microsocks
RUN curl -L -o /tmp/microsocks.tar.gz https://gh-proxy.com/https://github.com/rofl0r/microsocks/archive/refs/tags/v1.0.2.tar.gz && \
    tar -xzf /tmp/microsocks.tar.gz -C /tmp && \
    make -C /tmp/microsocks-1.0.2 && \
    mv /tmp/microsocks-1.0.2/microsocks /usr/local/bin/ && \
    strip /usr/local/bin/microsocks && \
    rm -rf /tmp/microsocks*

# 拷贝 VPN 安装包和脚本
COPY scvpn-1.2.0-1.ter.x86_64.rpm /tmp/
COPY entrypoint.sh /entrypoint.sh
RUN rpm -ivh /tmp/scvpn-1.2.0-1.ter.x86_64.rpm && \
    rm -f /tmp/*.rpm && \
    chmod +x /entrypoint.sh

# 暴露端口
EXPOSE 1080

# 添加健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s \
    CMD scvpn status | grep -q "SCVPN is connecting" || exit 1

# 入口脚本
ENTRYPOINT ["/entrypoint.sh"]
