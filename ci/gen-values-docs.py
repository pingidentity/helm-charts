#!/usr/bin/env python3
import sys

# This script generates markdown documentation for the values that are supported in the Helm chart.
# TODO explain how it is generated (how to update values.yaml for document a given param)

def fail(message):
    exit("❌ Error: {}".format(message))

markdownHeader="## Supported values"

def generateTable(params):
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
    for param in params:
        nameCol = "`" + param['name'] + "`"
        defaultCol = ""
        if param["default"]:
            defaultCol = "`" + param['default'] + "`"
        markdown += "| {col1: <{col1Len}} | {col2: <{col2Len}} | {col3: <{col3Len}} |\n".format(
            col1=nameCol, col1Len=maxLenName, col2=param['description'], 
            col2Len=maxLenDesc, col3=defaultCol, col3Len=maxLenDefault)

    return markdown

def generateMarkdown(sections):
    markdown = markdownHeader + "\n"
    if len(sections) == 0:
        return markdown

    for sectionName in sections.keys():
        if sections[sectionName]:
            if sectionName != "undefined":
                markdown += "### " + sectionName + "\n"
            markdown += generateTable(sections[sectionName])
    
    return markdown

# Add some defaults for empty params
def addParam(sections, newParam):
    if "description" not in newParam:
        newParam["description"] = ""
    if "default" not in newParam:
        newParam["default"] = ""

    section = "undefined"
    if "section" in newParam:
        section = newParam["section"]
    
    if section not in sections:
        sections[section] = []
    sections[section].append(newParam)

if len(sys.argv) not in [2, 3]:
    fail("Expected one or two arguments. Name of file to generate docs for, and optional file to write result to. Got {} args.".format(len(sys.argv) - 1))

srcFilename = sys.argv[1]
destFilename = ""
if len(sys.argv) == 3:
    destFilename = sys.argv[2]
sections = {}
currentParam = None
currentSection = ""
try:
    with open(srcFilename) as input:
        print("Generating documentation for file {}".format(srcFilename))
        for line in input:
            split = line.strip().split()
            if len(split) >= 3:
                if split[1] == "@section":
                    currentSection = " ".join(split[2:])
                if split[1] == "@param":
                    isFirstParam = currentParam == None
                    if isFirstParam:
                        currentParam = {}
                        if currentSection:
                            currentParam["section"] = currentSection
                    if not isFirstParam and currentParam:
                        addParam(sections, currentParam)
                        currentParam = {}
                        if currentSection:
                            currentParam["section"] = currentSection
                    currentParam["name"] = split[2]
                    if len(split) >= 4:
                        currentParam["description"] = " ".join(split[3:])
                elif split[1] == "@default":
                    currentParam["default"] = " ".join(split[2:])
                elif split[1] == "@desc":
                    descLine = " ".join(split[2:])
                    if descLine:
                        if "description" in currentParam:
                            currentParam["description"] += " " + descLine
                        else:
                            currentParam["description"] = descLine
        if currentParam:
            addParam(sections, currentParam)

except FileNotFoundError:
    fail("Specified source file {} does not exist.".format(srcFilename))
except IsADirectoryError:
    fail("Specified source file {} is a directory. Please specify a valid values file.".format(srcFilename))

markdown = generateMarkdown(sections)
if destFilename:
    with open(destFilename, "w") as dest:
        print("Writing result to file {}".format(destFilename))
        dest.write(markdown)
else:
    print("Writing result to stdout:")
    print()
    print(generateMarkdown(params))