with open('GHISACONUS_2008_001_speclib.csv', 'r') as ghisar:
    lines = ghisar.readlines()
    ptr = 1

    with open('GHISACONUS_2008_speclib.csv', 'w') as ghisaw:
        for line in lines:
            if ptr > 6:
                ghisaw.write(line)
            ptr += 1
