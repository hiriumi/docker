FROM centos:latest
RUN yum -y update; yum clean all
RUN yum -y install http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm; yum -y makecache
RUN yum -y install nginx-1.14.2

RUN mkdir /etc/nginx/conf.d/ssl
RUN mkdir /etc/nginx/conf.d/ssl/private
RUN mkdir /etc/nginx/conf.d/ssl/certs

EXPOSE 80
EXPOSE 8080
EXPOSE 443
EXPOSE 8443

CMD ["nginx", "-g", "daemon off;"]