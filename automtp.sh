#!/bin/bash

function docker_install()
{
	echo "检查Docker......"
	docker -v
    if [ $? -eq  0 ]; then
        echo "检查到Docker已安装!"
    else
    	echo "安装docker环境..."
        curl -sSL https://get.daocloud.io/docker | sh
        echo "安装docker环境...安装完成!"
    fi
}

function check_mtp_install()
{
    echo "检测docker mtproxy 安装情况..."
    docker ps -a | grep nginx-mtproxy
    if [ $? -eq 0 ]; then
        echo "检测到docker mtproxy已安装!"
        docker stop nginx-mtproxy
        docker rm nginx-mtproxy
        docker ps -a | grep nginx-mtproxy
        echo "旧版docker mtproxy已经删除!"
    else
        echo "检测到docker mtproxy未安装!"
    fi
}

function get_config()
{
    echo "生成随机配置文件..."
    secret=$(head -c 16 /dev/urandom | xxd -ps)
    tag="12345678901234567890121231231231"
    domains=("bilibili.com" "www.acfun.cn" "www.ixigua.com/?wid_try=1" "www.iqiyi.com")
    domain=${domains[$RANDOM % ${#domains[@]}]}
    echo "选取的域名为:$domain"
    port=$RANDOM
    echo "选取的端口为:$port"

}
function install_mtp()
{
    echo "开始安装docker nginx-mtproxy..."
    docker pull ellermister/nginx-mtproxy:latest
    docker run --name nginx-mtproxy -d -e tag="$tag" -e secret="$secret" -e domain="$domain" -p 80:80 -p $port:443 ellermister/nginx-mtproxy:latest
    if [ $? -eq 0 ] ; then
        echo "docker nginx-mtproxy 安装完成!"
    else
        echo "docker nginx-mtproxy 安装失败!"
    fi
    
}



function main()
{
    
    echo "欢迎来到automtp--------by:viiber"
    echo "-----------------------------------------------------"
    echo "本脚本会为您自动重新安装mtproxy并随机更改端口"

    docker_install
    check_mtp_install
    get_config
    install_mtp

    echo "安装结束！"
    docker logs nginx-mtproxy

}

main