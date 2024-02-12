import sys
#Short Python script, deletes the first 6 lines of whatever file path is given to it

path = sys.argv[1]

with open(path, 'r') as ghisar:
    lines = ghisar.readlines()
    ptr = 1

    with open(path, 'w') as ghisaw:
        for line in lines:
            if ptr > 6:
                ghisaw.write(line)
            ptr += 1
        ghisaw.close()
    ghisar.close()
