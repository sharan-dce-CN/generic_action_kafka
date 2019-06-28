import sys
import json
import os

def parse(string_sep):
    result = ""
    string_sep = string_sep.replace(" ", "")
    string_sep = string_sep.split(",")
    for element in string_sep:
        result += '"' + element + '",'
    return "[" + result[: -1] + "]"

def get_imports_functiondef(file_path):
    import_string = ""
    function_definition = ""
    with open(file_path, "r") as f:
        for line in f:
            if("import" in line):
                import_string += line
            else:
                function_definition += line
    return (import_string, function_definition)

json_path = sys.argv[1]
action_dict = None
with open(json_path) as json_file:
    action_dict = json.load(json_file)

ballerina_file = open("ballerinaExecute.bal", "w+")

ballerina_file.write("import ballerina/io;import wso2/kafka;import ballerina/encoding;import ballerina/log;")

import_string, function_definition = get_imports_functiondef(action_dict["action_definition"])
ballerina_file.write(import_string)

config_details = "string[] SUBSCRIPTIONLIST = " + parse(action_dict["subscriptionList"]) + ";string[] TRIGGERLIST = " + parse(action_dict["triggerList"]) + ";string GROUPID = \"" + action_dict["groupId"] + "\";string SERVERS = \"" + action_dict["servers"] + "\";"

ballerina_file.write(config_details)
ballerina_file.write(function_definition)

with open("boilerplate") as file:
    boilerplate = file.read()

ballerina_file.write(boilerplate)
ballerina_file.close()
os.system('ballerina run ./ballerinaExecute.bal')
