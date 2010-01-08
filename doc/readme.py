#!/usr/bin/env python
from mako.template import Template
import sys

def main(v_ginacVersion = '1.5.5', v_clnVersion = '1.3.1', v_gmpVersion = '4.3.1'):
    mytemplate = Template(filename = 'readme.html.x')
    content = None
    try:
        content = mytemplate.render(ginacVersion = v_ginacVersion, \
                                    clnVersion = v_clnVersion, \
                                    gmpVersion = v_gmpVersion)
    except:
        print 'readme.py: failed to render the template, bailing out'
        return 1
    else:
        print content
        return 0

if __name__ == '__main__':
    if len(sys.argv) != 4:
	print 'Usage: readme.py ginacVersion clnVersion gmpVersion'
	sys.exit(1)
    ret = main(sys.argv[1], sys.argv[2], sys.argv[3])
    sys.exit(ret)

# vim: ai ts=4 sts=4 et sw=4

