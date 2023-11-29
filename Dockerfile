# Télécharge et utilise l'image source ubuntu en vesrion 20.04
FROM ubuntu:20.04

# Indique des information l'image, sa vesrion, son usage et qui la maintien 
LABEL maintainer="Arnaud"
LABEL version="0.1"
LABEL description="Image avec php7.4-fpm et nginx"


# Désactive les terminiaux interactifs
ARG DEBIAN_FRONTEND=noninteractive

# Mise à jour tous la liste et tous les packets
RUN apt update && apt upgrade -y


# Install nginx, php, php-fpm et  supervisord 
RUN apt install -y nginx php7.4-fpm supervisor 

# Netoi les ficheir apt 
RUN rm -rf /var/lib/apt/lists/* && apt clean


## Définition des varaible des fichier de configuration

# Config des site accesible et de leur répertoire 
ENV nginx_vhost /etc/nginx/sites-available/default
# Conf de php7.4
ENV php_conf /etc/php/7.4/fpm/php.ini

#Conf de ngnix
ENV nginx_conf /etc/nginx/nginx.conf

# conf de supervisor
ENV supervisor_conf /etc/supervisor/supervisord.conf

# Place la conf des site nginx
COPY default ${nginx_vhost}

# Decomente est change la valeur de cgi.fix_pathinfo dans le fichier conf de php7 
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf}

# Desactive le daemon nginx 
RUN echo "\ndaemon off;" >> ${nginx_conf}

# Insatll la conf de supervisor
COPY supervisord.conf ${supervisor_conf}

# Creer le repertoir /run/php
RUN mkdir -p /run/php

# Change le propriétaire et le group de tous les fichier et dossier de /var/www/html et /run/php
RUN chown -R www-data:www-data /var/www/html && chown -R www-data:www-data /run/php

# Rend disponible des fichier de l'image
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Ajoute le fichir start.sh à /
COPY start.sh /start.sh
CMD ["./start.sh"]
EXPOSE 80 443
