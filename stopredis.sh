if [ "`ps -ef|grep './redis'|grep -v grep|awk '{print $2}'`" != "" ]; then
        ps -ef|grep './redis'|grep -v grep|awk '{print $2}'|xargs kill
fi

