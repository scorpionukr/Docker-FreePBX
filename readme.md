## Docker FreePBX 17  
This is a clear docker image of Freepbx 17 for quick deployment of PBX  
Official Site: [Freepbx](https://www.freepbx.org/)  
Container repository: [Docker](https://hub.docker.com/r/blacksunsolutions/freepbx)  
### Setup Guide  
Create `docker-compose.yml` file:   
```
services:
  freepbx:
    image: blacksunsolutions/freepbx:latest
    container_name: freepbx
    ports:
      - 80:80
      - 443:443
      - 4569:4569/udp
      - 5060:5060
      - 10000-20000:10000-20000/udp
    environment:
      - TZ=Europe/Kiev
      - DB_USER=asterisk
      - DB_PASS=asteriskpass
      - DBENGINE=mysql
      - DBNAME=asterisk 
      - DBHOST=192.168.200.2
      - DBPORT=3306 
      - CDRDBNAME=asteriskcdrdb 
      - DBUSER=asterisk 
      - DBPASS=asterisk 
      - USER=asterisk 
      - GROUP=asterisk 
      - WEBROOT=/var/www/html 
      - ASTETCDIR=/etc/asterisk 
      - ASTMODDIR=/usr/lib64/asterisk/modules 
      - ASTVARLIBDIR=/var/lib/asterisk 
      - ASTAGIDIR=/var/lib/asterisk/agi-bin 
      - ASTSPOOLDIR=/var/spool/asterisk 
      - ASTRUNDIR=/var/run/asterisk 
      - AMPBIN=/var/lib/asterisk/bin 
      - AMPSBIN=/usr/sbin 
      - AMPCGIBIN=/var/www/cgi-bin 
      - AMPPLAYBACK=/var/lib/asterisk/playback 
    volumes:
      - varasterisk:/var/lib/asterisk
      - etcasterisk:/etc/asterisk
      - usrasterisk:/usr/lib64/asterisk
      - logs:/var/log/asterisk
      - wwwdata:/var/www/html
      - ./records:/var/spool/asterisk/monitor
    restart: always
    networks:
      voip_net:
        ipv4_address: 192.168.200.3
  db:
    image: mariadb:latest
    container_name: db
    restart: always
    volumes:
      - ./db_data:/var/lib/mysql
      - ./sql_scripts:/docker-entrypoint-initdb.d
    environment:
      - TZ=Europe/Kiev
      - MYSQL_ROOT_PASSWORD=asterisk
    networks:
      voip_net:
        ipv4_address: 192.168.200.2

volumes:
  varasterisk:
  etcasterisk:
  usrasterisk:
  wwwdata:
  logs:

networks:
 voip_net:
    driver: bridge
    driver_opts:
      com.docker.network.enable_ipv6: "false"
    ipam:
      driver: default
      config:
      - subnet: 192.168.200.0/24
        gateway: 192.168.200.1
```
Start image with Docker Compose  
```
docker compose -d up
```
  
**If you find this project useful or inspiring, please support it with a donation.**  
[<img src="https://felen.io/static/img/felen_whole_logo.png" width="20%" />](https://felen.io/fraglist/pay/)