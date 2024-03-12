#!/usr/bin/python3

import json
from jinja2 import Template
import glob
import os
import logging

def main():
  tf_vars = {}
  dirname = os.path.abspath(os.path.dirname(__file__))
  try:
    import hcl
    for tfname in glob.glob(dirname + "/*.tfvars"):
      logging.debug(f"loading HCL from {tfname}")
      with open(tfname, "r") as tfvars_in:
        tf_vars = { **tf_vars, **hcl.load(tfvars_in)}
  except ImportError:
      logging.warning('*.tfvars ignored. Install hcl module')
  for tfname in glob.glob(dirname + "/*.tfvars.json"):
    logging.debug(f"loading JSON from {tfname}")
    with open(tfname, "r") as json_in:
      tf_vars = { **tf_vars, **json.load(json_in)}
  if len(tf_vars) == 0:
    logging.warning(f'No terraform config found in {dirname}')
  
  for tmpl in glob.glob(dirname + "/*.j2"):
      with open(tmpl, "r") as f:
          fname = tmpl.replace(".j2","")
          Template(f.read()).stream(tf_vars).dump(fname)

if __name__ == '__main__':
  fmt = "%(asctime)s [%(threadName)s]: %(message)s"
  logging.basicConfig(format=fmt, level=logging.DEBUG,datefmt="%H:%M:%S")
  main()

