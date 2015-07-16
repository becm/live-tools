#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""list and display available documentation.

read available documentations form configuration files

"""

import os

def paths(env="DOC_LOAD"):
  """ get paths containing config files """
  try:
    return os.environ[env].split(':')
  except:
    return ["/opt/doc/conf.d/*.conf"]

def add(conf, match=paths()):
  """ add matching entries to configuration """
  import glob
  for fn in glob.glob(match):
    conf.read(fn)

def config():
  """ create doc configuration """
  import sys
  if sys.version_info < (3,0):
    from ConfigParser import ConfigParser
  else:
    from configparser import ConfigParser
  conf = ConfigParser()
  for pn in paths():
    add(conf, pn)
  return conf

def display(conf):
  """ show available documentation """
  import locale
  lc = locale.getlocale()[0]
  if not lc: lc = locale.getdefaultlocale()[0]
  for alias in sorted(conf.sections()):
    if lc:
      try: print(alias + ":\t" + conf.get(alias, 'info[' + lc[0:2] + ']')); continue
      except: pass
    try: print(alias + ":\t" + conf.get(alias, 'info')); continue
    except: pass

if __name__ == "__main__":
  """ run documentation display code """
  import sys
  conf = config()
  if len(sys.argv) < 2:
    display(conf)
  else:
    for arg in sys.argv[1:]:
      try:
        fn = conf.get(str.lower(arg), "file")
        import subprocess
        subprocess.Popen(["xdg-open", os.path.expandvars(fn)])
      except:
        sys.stderr.write(sys.argv[0] + ": documentation for '" + arg + "' not found\n")
        sys.exit(1)
