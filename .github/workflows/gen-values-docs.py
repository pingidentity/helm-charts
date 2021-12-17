#!/usr/bin/env python3
import sys

def fail(message):
    exit("❌ Error: {}".format(message))

def generateMarkdown(params):
    

if len(sys.argv) != 2:
    fail("Expected one argument, name of file to generate docs for. Got {} args.".format(len(sys.argv) - 1))

srcFilename = sys.argv[1]
try:
    with open(srcFilename) as f:
        print("Generating documentation for file {}".format(srcFilename))
        params = []




except FileNotFoundError:
    fail("Specified file {} does not exist.".format(srcFilename))
except IsADirectoryError:
    fail("Specified file {} is a directory. Please specify a valid values file.".format(srcFilename))

