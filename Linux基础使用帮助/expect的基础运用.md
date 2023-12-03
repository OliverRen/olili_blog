---
title: expect的基础运用
---

``` shell?linenums
#!/bin/bash

apt -y install expect

for plot in plot-*.plot
do
    echo $plot
    sleep 5

    expect -c "
    spawn scp $plot oliver@10.1.49.90:/data/share/
    expect {
        \"*assword\"
                    {
                        set timeout 3000;
                        send \"password\r\";
                    }
        \"yes/no\"
                    {
                        send \"yes\r\"; exp_continue;}
                    }    
    expect eof"

    sleep 5

    rm $plot
    sleep 15
done
```