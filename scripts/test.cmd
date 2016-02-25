@echo off
net use M: \\<AD DC ip>\<network share name here>
m:/fetchandrun
net use m: /d /y