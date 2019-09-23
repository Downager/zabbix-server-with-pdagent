FROM zabbix/zabbix-server-mysql:alpine-4.2-latest
RUN apk update && \
    apk add bc curl openssl git python2 python && \
    umask 0022 && \
    cd / && \
    mkdir -p opt && \
    cd opt && \
    # Fork from PagerDuty/pdagent-integrations
    # 修改 Configuration > Action > Operations & Recovery operations & Update operations > Default message format 如下
    # name:{TRIGGER.NAME}, id:{TRIGGER.ID}, status:{TRIGGER.STATUS}, hostname:{HOSTNAME}, ip:{IPADDRESS}, value:{TRIGGER.VALUE}, event_id:{EVENT.ID}, severity:{TRIGGER.SEVERITY}
    git clone https://github.com/PagerDuty/pdagent.git && \
    git clone https://github.com/Downager/pdagent-integrations.git && \
    ln -s /opt/pdagent/pdagent /opt/pdagent-integrations/bin && \
    mkdir -p /opt/pdagent/tmp && \
    chmod 777 /opt/pdagent/tmp && \
    ln -s /opt/pdagent/tmp /var/lib/pdagent && \
    adduser -D -H pdagent pdagent && \
    cp /opt/pdagent/conf/pdagent.conf /etc/ && \
    chmod 644 /etc/pdagent.conf && \
    # run pdagentd
    su -s /bin/bash -c "/opt/pdagent/bin/pdagentd.py" pdagent && \
    # Make a symlink
    ln -s /opt/pdagent-integrations/bin/pd-zabbix /usr/lib/zabbix/alertscripts && \
    # 修改 /opt/pdagent/tmp/ 權限避免 pd-zabbix 執行問題
    chmod 777 /opt/pdagent/tmp/outqueue/err/ && \
    chmod 777 /opt/pdagent/tmp/outqueue/pdq/ && \
    chmod 777 /opt/pdagent/tmp/outqueue/suc/ && \
    chmod 777 /opt/pdagent/tmp/outqueue/tmp/ && \
    sed -i '/Starting Zabbix server/asu -s /bin/bash -cx "/opt/pdagent/bin/pdagentd.py" pdagent' /usr/bin/docker-entrypoint.sh && \
    grep pdagentd /usr/bin/docker-entrypoint.sh && \
    # 刪除 pdagentd.pid
    rm /opt/pdagent/tmp/pdagentd.pid
