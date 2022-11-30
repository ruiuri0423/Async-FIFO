import random as rd
import os

FileName = "din.dat"

if(os.path.isfile(FileName)):
    os.remove(FileName)

with open(FileName, "a") as F:

    for i in range(500):
        d = int(rd.random() * 255)
        d = hex(d)
        d = d.split("0x")
        F.write("{:s}\n".format(d[1]))
    
    F.close()