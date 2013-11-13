##!/usr/bin/env python
#
#import sys
#
##for line in sys.stdin:
#line = "-3.79367841439351	2.69119893616457"
## remove leading and trailing whitespace
##line = line.strip()
## split x and y values apart
#line = line.split()
#
## x and y were split as a list of two elements.
## need to convert to floats and designate which element is x and which is y.
#x = map(float,line)[0]
#y = map(float,line)[1]
#
## create upper and lower bounds for each bin, separated by 0.1
##x_lo = round(x,1)
##x_hi = round(round(x,1)+0.1)
##y_lo = round(y,1)
##y_hi = round(round(y,1)+0.1)
#
#if x-round(x,1) < 0.0:
#    x_hi = round(x,1)
#    x_lo = round(round(x,1) - 0.1,1)
#else:
#    x_lo = round(x,1)
#    x_hi = round(round(x,1) + 0.1,1)
#
#if y-round(y,1) < 0.0:
#    y_hi = round(y,1)
#    y_lo = round(round(y,1) - 0.1,1)
#else:
#    y_lo = round(y,1)
#    y_hi = round(round(y,1) + 0.1,1)
#
#
##print((x_lo,x_hi,y_lo,y_hi),1)
#print '%s,%s,%s,%s\t%s' % (x_lo,x_hi,y_lo,y_hi,1)


current_word = None
current_count = 0
word = None

#for line in sys.stdin:
for line in "-3.8;-3.7;2.6;2.7;1":
    #line = line.strip()

    line = line.rsplit(";",1)
    print(line)
    #word = line[0:4]
    #count = line[4]
    #try:
    #    count = int(count)
    #except ValueError:
    #    continue
    #if current_word == word:
    #    current_count += count
    #else:
    #    if current_word:
    #        # write result to STDOUT
    #        print '%s\t%s' % (current_word, current_count)
    #    current_count = count
    #    current_word = word
    #if current_word == word:
    #    print '%s\t%s' % (current_word, current_count)
    #
