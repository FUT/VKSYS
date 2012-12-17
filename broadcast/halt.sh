kill -9 `ps aux | grep shoes | awk '{print($2)}'`
killall ruby
