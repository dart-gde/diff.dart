# diff

Port of the [diff.js](http://hg.opensource.lshift.net/synchrotron/file/default/) 
library. 

### Example using bin/diff.dart

```
–(~/dart/diff)–($ dart bin/diff.dart /tmp/a.txt /tmp/o.txt /tmp/b.txt 
diff3_dig: /tmp/a.txt, /tmp/o.txt, /tmp/b.txt
AA
a
<<<<<<<<<
b
=========
d
>>>>>>>>>
c
ZZ
<<<<<<<<<
new
00
a
a
=========
11
>>>>>>>>>
M
z
z
99
```

Where the following input files are 

```
–(~/dart/diff)–($ cat /tmp/a.txt 
AA
a
b
c
ZZ
new
00
a
a
M
99
```

```
–(~/dart/diff)–($ cat /tmp/o.txt 
AA
ZZ
00
M
99
```

```
–(~/dart/diff)–($ cat /tmp/b.txt 
AA
a
d
c
ZZ
11
M
z
z
99
```
