#!/usr/bin/python
#This is for running inside a Harbor instance deployed via .ova, so it's python 2 only.
import os
import re
import sys
import StringIO
import ConfigParser

def usage():
    print "Usage: %s <old harbor cfg file> <new harbor cfg file template>" % sys.argv[0]
    sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        usage()
    old_cfg = sys.argv[1]
    new_cfg = sys.argv[2]
    if not os.path.isfile(old_cfg):
        print "old harbor config file does not exit!"
        usage()
    if not os.path.isfile(new_cfg):
        print "new harbor config file template does not exit!"
        usage()

    print "Upgrading harbor configuration file: %s to new format according to %s" % (old_cfg, new_cfg)
    conf = StringIO.StringIO()
    conf.write("[configuration]\n")
    with open(old_cfg, 'r') as f:
        conf.write(f.read())
    conf.seek(0, os.SEEK_SET)
    rcp = ConfigParser.RawConfigParser()
    rcp.readfp(conf)

    items = rcp.items("configuration")

    with open(new_cfg, 'r') as f:
        new_cfg_str = f.read()
    for it in items:
        new_cfg_str = re.sub(r'#?%s\s*=.*' % it[0], '%s = %s' % it, new_cfg_str) 
    with open(new_cfg, 'w') as f:
        f.write(new_cfg_str)
    print "%s upgraded" % old_cfg 


