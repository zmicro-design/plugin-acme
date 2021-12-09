FROM whatwewant/zmicro:v1.6.8

RUN apt install -yqq cron

RUN zmicro install acme

CMD sleep infinity