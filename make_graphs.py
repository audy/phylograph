import sys
with open(sys.argv[1]) as handle:
    handle.next() # skip
    print "graph whatever {"
    for line in handle:
        print line.strip()