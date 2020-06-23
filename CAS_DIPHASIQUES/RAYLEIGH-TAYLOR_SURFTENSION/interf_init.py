import numpy as np

ndp = 81
a = np.linspace(-0.5,0.5,ndp)[::-1]
b = -0.05*np.cos(2*np.pi*a)

for i in xrange(1,ndp-1):
    print "            {0:2d} : {{ {1: 21.14e} , {2: 21.14e} }}".format(i+8,a[i],b[i])


for i in xrange(2,ndp-1,2):
    print "                             {0:2d} , {1:2d} ,".format(i+8,i+9)
