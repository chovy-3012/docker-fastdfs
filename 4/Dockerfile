FROM 192.168.1.106:5000/centos:6.8
MAINTAINER chenhui
USER root

#install environment
##RUN yum -y groupinstall 'Development Tools'
#RUN yum install -y libevent-devel pcre-devel zlib-devel
RUN yum install -y gcc perl pcre-devel zlib-devel libevent-devel && yum clean all

#install FastDFS
ADD FastDFS_v4.08.tar.gz /
WORKDIR /FastDFS_v4.08
RUN ./make.sh && ./make.sh install

#set Soft connection
RUN ln -sv /usr/include/fastcommon /usr/local/include/fastcommon 
RUN ln -sv /usr/include/fastdfs /usr/local/include/fastdfs

#install nginx
ADD nginx-1.11.6.tar.gz /usr/local/
ADD fastdfs-nginx-module_v1.16.tar.gz /usr/local/
WORKDIR /usr/local/nginx-1.11.6
RUN ./configure --prefix=/usr/local/nginx --conf-path=/usr/local/nginx/nginx.conf --add-module=/usr/local/fastdfs-nginx-module/src
RUN make && make install 

RUN cp /usr/local/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs/
RUN mkdir /fdfs_conf
RUN cp /FastDFS_v4.08/conf/* /fdfs_conf/ 
ADD entrypoint.sh /
ADD nginx-conf.sh /
RUN chmod 777 /entrypoint.sh
RUN chmod 777 /nginx-conf.sh
ENTRYPOINT ["/entrypoint.sh"]