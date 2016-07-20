FROM python:2.7.12-slim

MAINTAINER Francis Arigo <francis.arigo@gmail.com>

# Standard set up Nginx
ENV NGINX_VERSION 1.9.11-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y ca-certificates nginx=${NGINX_VERSION} gettext-base \
	&& rm -rf /var/lib/apt/lists/*
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log \
        && echo "daemon off;" >> /etc/nginx/nginx.conf \
        && rm /etc/nginx/conf.d/default.conf
# Copy the modified Nginx conf
COPY nginx.conf /etc/nginx/conf.d/

# Install Supervisord and uwsgi
RUN apt-get update && apt-get install -y supervisor gcc\
        && rm -rf /var/lib/apt/lists/* \
        && pip install uwsgi \
        && apt-get remove -y --auto-remove gcc

# Custom Supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY ./app /app
WORKDIR /app

EXPOSE 80 443

CMD ["/usr/bin/supervisord"]
