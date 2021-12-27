#!/usr/bin/env python3
import sys

def fail(message):
    exit("❌ Error: {}".format(message))

def generateMarkdown(params):
    if len(params) == 0:
        return ""

    # Default max lengths to length of column names
    maxLenName = len("Name")
    maxLenDesc = len("Description")
    maxLenDefault = len("Default")
    for param in params:
        if len(param['name']) > maxLenName:
            maxLenName = len(param['name'])
        if len(param['description']) > maxLenDesc:
            maxLenDesc = len(param['description'])
        if len(param['default']) > maxLenDefault:
            maxLenDefault = len(param['default'])

    # Add space for backticks
    maxLenName += 2
    maxLenDefault += 2
    
    markdown = "| {col1: <{col1Len}} | {col2: <{col2Len}} | {col3: <{col3Len}} |\n".format(
        col1="Name", col1Len=maxLenName, col2="Description", col2Len=maxLenDesc, col3="Default", col3Len=maxLenDefault)
    markdown += "| " + ("-" * maxLenName) + " | " + ("-" * maxLenDesc) + " | " + ("-" * maxLenDefault) + " |\n"
    #TODO handle empty values like empty string in the table?
    for param in params:
        nameCol = "`" + param['name'] + "`"
        defaultCol = ""
        if param["default"]:
            defaultCol = "`" + param['default'] + "`"
        markdown += "| {col1: <{col1Len}} | {col2: <{col2Len}} | {col3: <{col3Len}} |\n".format(
            col1=nameCol, col1Len=maxLenName, col2=param['description'], 
            col2Len=maxLenDesc, col3=defaultCol, col3Len=maxLenDefault)

    return markdown

# Add some defaults for empty params
def addParam(list, newParam):
    if "description" not in newParam:
        newParam["description"] = ""
    if "default" not in newParam:
        newParam["default"] = ""
    list.append(newParam)

if len(sys.argv) not in [2, 3]:
    fail("Expected one or two arguments. Name of file to generate docs for, and optional file to write result to. Got {} args.".format(len(sys.argv) - 1))

srcFilename = sys.argv[1]
destFilename = ""
if len(sys.argv) == 3:
    destFilename = sys.argv[2]
params = []
currentParam = {}
try:
    with open(srcFilename) as input:
        print("Generating documentation for file {}".format(srcFilename))
        for line in input:
            split = line.strip().split()
            if len(split) >= 3:
                if split[1] == "@param":
                    if currentParam:
                        addParam(params, currentParam)
                        currentParam = {}
                    currentParam["name"] = split[2]
                    if len(split) >= 4:
                        currentParam["description"] = " ".join(split[3:])
                elif split[1] == "@default":
                    currentParam["default"] = " ".join(split[2:])
        if currentParam:
            addParam(params, currentParam)

except FileNotFoundError:
    fail("Specified source file {} does not exist.".format(srcFilename))
except IsADirectoryError:
    fail("Specified source file {} is a directory. Please specify a valid values file.".format(srcFilename))

markdown = generateMarkdown(params)
if destFilename:
    with open(destFilename, "w") as dest:
        print("Writing result to file {}".format(destFilename))
        dest.write(markdown)
else:
    print("Writing result to stdout:")
    print()
    print(generateMarkdown(params))