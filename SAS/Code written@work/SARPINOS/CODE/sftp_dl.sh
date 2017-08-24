#!/usr/bin/expect

set username [lindex $argv 0]
set servername [lindex $argv 1]
set password [lindex $argv 2]
set action [lindex $argv 3]
set absolute_path_file [lindex $argv 4]
set target_file [lindex $argv 5]
set return_file [lindex $argv 6]

set timeout 60

spawn sftp -v $username@$servername
expect {
"sarpinos@192.168.100.2's password:" {send "$password\r"}
"sftp>" {break}
"Are you sure you want to continue connecting (yes/no)?" {send "yes\r"}
"Sending subsystem: sftp"
}
sleep 6
send "$action $absolute_path_file $target_file\r"
sleep 6
send "get $target_file $return_file\r"
sleep 6
expect "sftp>"
send "exit"
return 0
