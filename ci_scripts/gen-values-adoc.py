#!/usr/bin/env python3
import sys

# This script generates AsciiDoc documentation for the values supported in the Helm chart.
# It parses @param, @desc, @default, and @section comments in values.yaml.

asciidoc_header = '''= List of Supported Values

These are the values supported in the ping-devops chart. In general, values specified in the global section can be overridden for individual products. The product sections have many global fields overridden by default (workloads, services, etc.).
'''

def generate_table(params, section_title):
    if not params:
        return ""
    # Map section titles to Title Case as in supported-values.adoc
    section_map = {
        "global values": "Global Values",
        "workload values - deployment and statefulset": "Workload Values – Deployment and StatefulSet",
        "other global defaults": "Other Global Defaults",
        "shared utilities": "Shared Utilities",
        "image/product values": "Image/Product Values"
    }
    section_key = section_title.strip().lower()
    title = section_map.get(section_key, section_title.title())
    # Section header, table header, and table rows
    table = f"\n== {title}\n\n[cols=\"2,3,1\", options=\"header\"]\n|==="
    if title == "Image/Product Values":
        table += "\n|Name\n|Description\n|Default\n"
    else:
        table += "\n|Name |Description |Default\n"
    table += "\n"
    for idx, param in enumerate(params):
        name = f"`{param['name']}`"
        desc = param.get('description', '')
        default = f"`{param['default']}`" if param.get('default') else ''
        table += f"|{name}\n|{desc}\n|{default}"
        # Only add a blank line between rows, not after the last row
        if idx < len(params) - 1:
            table += "\n\n"
    table += "\n|==="
    return table

def generate_asciidoc(sections):
    doc = asciidoc_header
    # Use explicit section order to match supported-values.adoc
    preferred_order = [
        "global values",
        "workload values - deployment and statefulset",
        "other global defaults",
        "shared utilities",
        "image/product values"
    ]
    # Lowercase keys for matching
    section_keys = {k.strip().lower(): k for k in sections}
    first = True
    for key in preferred_order:
        if key in section_keys:
            if not first:
                doc += "\n"
            doc += generate_table(sections[section_keys[key]], key)
            first = False
    # Add any other sections not in preferred_order
    for k, orig in section_keys.items():
        if k not in preferred_order:
            doc += "\n" if not first else ""
            doc += generate_table(sections[orig], orig)
            first = False
    return doc

def add_param(sections, param):
    if "description" not in param:
        param["description"] = ""
    if "default" not in param:
        param["default"] = ""
    section = param.get("section", "undefined")
    if section not in sections:
        sections[section] = []
    sections[section].append(param)

if len(sys.argv) not in [2, 3]:
    print("Usage: {} <values.yaml> [output.adoc]".format(sys.argv[0]))
    sys.exit(1)

src_filename = sys.argv[1]
dest_filename = sys.argv[2] if len(sys.argv) == 3 else None

sections = {}
current_param = None
current_section = ""
try:
    with open(src_filename) as input:
        for line in input:
            split = line.strip().split()
            if len(split) >= 3:
                if split[1] == "@section":
                    current_section = " ".join(split[2:])
                if split[1] == "@param":
                    if current_param:
                        add_param(sections, current_param)
                    current_param = {"name": split[2]}
                    if current_section:
                        current_param["section"] = current_section
                    if len(split) >= 4:
                        current_param["description"] = " ".join(split[3:])
                elif split[1] == "@default":
                    if current_param:
                        current_param["default"] = " ".join(split[2:])
                elif split[1] == "@desc":
                    desc_line = " ".join(split[2:])
                    if desc_line and current_param:
                        if "description" in current_param:
                            current_param["description"] += " " + desc_line
                        else:
                            current_param["description"] = desc_line
        if current_param:
            add_param(sections, current_param)
except FileNotFoundError:
    print(f"❌ Error: Specified source file {src_filename} does not exist.")
    sys.exit(1)
except IsADirectoryError:
    print(f"❌ Error: Specified source file {src_filename} is a directory.")
    sys.exit(1)

asciidoc = generate_asciidoc(sections)
if dest_filename:
    with open(dest_filename, "w") as dest:
        dest.write(asciidoc)
else:
    print(asciidoc)