
line = "3.28854889186141 0.148978077031863"

line = line.strip()
line = line.split()

    # x and y were split as a list of two elements.
    # need to convert to floats and designate which element is x and which is y.
print(line)
x = map(float,line)[0]
y = map(float,line)[1]
print(x,y)
    # create upper and lower bounds for each bin, separated by 0.1
x_lo = round(x,1)
x_hi = round(x,1)+0.1
y_lo = round(y,1)
y_hi = round(y,1)+0.1

    #print((x_lo,x_hi,y_lo,y_hi),1)
print '%s\t%s' % ((x_lo,x_hi,y_lo,y_hi),1)
    #file.write(x)

