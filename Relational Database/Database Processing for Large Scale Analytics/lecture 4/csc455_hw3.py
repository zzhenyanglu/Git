import sqlite3
from sqlite3 import OperationalError

conn = sqlite3.connect('csc455_HW3.db')
c = conn.cursor()

fd = open('ZooDatabase.sql', 'r')
sqlFile = fd.read()
fd.close()

sqlCommands = sqlFile.split(';')


for command in sqlCommands:
    try:
        c.execute(command)
    except OperationalError, msg:
        print "Command skipped: ", msg



for table in ['ZooKeeper', 'Animal', 'Handles']:
    
    result = c.execute("SELECT * FROM %s;" % table);

    rows = result.fetchall();

    print "\n--- TABLE ", table, "\n"

    for desc in result.description:
        print desc[0].rjust(22, ' '),

    print ""
    for row in rows:
        for value in row:
            print str(value).rjust(22, ' '),
        print ""

fd = open('part_1.txt','r')
Commends=fd.read()
fd.close()

commends=Commends.split(';')

for command in commends:
    try:
        c.execute(command)
    except OperationalError, msg:
        print "Command skipped: ", msg

#.close()
#conn.close()


