import xml.etree.ElementTree as ET
import time
import string # To iterate from A to Z

# Function to extract key-value pairs from the labels xml
def extract_key_value_pairs(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()
    key_value_dict = {}
    for element in root.iter('label'):
        key = element.get('key')
        value = element.get('value')
        key_value_dict[key] = value
    return key_value_dict

# Function to replace key strings with their values in the xml
def replace_key(xml_file, key_value_dict):
    # Load the quests XML file
    tree = ET.parse(xml_file)
    root = tree.getroot()

    for element in root.iter():
        for key, value in element.attrib.items():
            if value in key_value_dict:
                element.attrib[key] = key_value_dict[value]
    return tree


# Function to convert XML element to a dictionary
def xml_to_dictionary(element):
    dictionary = {}
    for child in element:
        if child.tag in dictionary:
            # If the item is already in the dictionary, it must be a list
            if type(dictionary[child.tag]) is list:
                # Append the new item to the list
                dictionary[child.tag].append(xml_to_dictionary(child))
            else:
                # Create the list if it doesn't exist
                dictionary[child.tag] = [dictionary[child.tag], xml_to_dictionary(child)]
        else:
            dictionary[child.tag] = xml_to_dictionary(child)

    if len(element.attrib) > 0:
        # Add attributes to the dictionary
        for attribute in element.attrib:
            dictionary[attribute] = element.attrib[attribute]

    if element.text and element.text.strip() != "":
        dictionary["text"] = element.text.strip()

    return dictionary

# Function to format Lua table as string
def format_lua_table(table, indent=0, beautiful = False):
    formatted = "{\n" if beautiful else "{"
    for key, value in table.items():
        # if beautiful:
        #     formatted += "\t" * (indent + 1)
        if isinstance(value, dict):
            formatted += f"{key} = {format_lua_table(value, indent + 1, beautiful)}"
        elif isinstance(value, list):
            formatted += f"{key} = {format_lua_table_list(value, indent + 1, beautiful)}"
        else:
            formatted += f"{key} = {repr(value)}"
        formatted += ",\n" if beautiful else ","
    # formatted += "\t" * indent + "}" # for better readability
    formatted += "}"

    return formatted

# Function to format Lua table lists as string
def format_lua_table_list(list, indent, beautiful):
    formatted = "{\n" if beautiful else "{"
    for item in list:
        # formatted += "\t" * (indent + 1) # Indentation for readability
        if isinstance(item, dict):
            formatted += format_lua_table(item, indent + 1)
        else:
            formatted += repr(item)
        formatted += ",\n" if beautiful else ","
    # formatted += "\t" * indent + "}" # Indentation for readability
    formatted += "}"

    return formatted


# Function to divide the XML into multiple XML trees based on the first letter of the quest name
# Returns a dictionary with dict[LETTER] -> XML tree
def divide_xml_by_quest_name(root):
    # Initialise the dictionary
    quests_by_first_letter = {}
    for letter in string.ascii_uppercase:
            quests_by_first_letter[letter] = []
    quests_by_first_letter["OTHER"] = []
    
    # Insert quests in the dictionary based on their first letter
    for quest in root.findall('quest'):
        name = quest.get('name')
        letter = name[0].upper()
        if letter < 'A' or letter > 'Z':
            # Regroup quests starting with numbers or non ASCII letters in a table
            letter = "OTHER"
        # if letter == 'A' or letter == 'B': # TODO : Remove this line, just for testing
        quests_by_first_letter[letter].append(quest)
    return dictionary_of_xml_trees(root, quests_by_first_letter)

# Create a dictionary of XML trees
def dictionary_of_xml_trees(root, quests_by_key):
    divided_xml_trees = {}
    for letter, quests in quests_by_key.items():
        divided_xml_trees[letter] = ET.ElementTree(ET.Element(root.tag))
        for quest in quests:
            divided_xml_trees[letter].getroot().append(quest)
    
    return divided_xml_trees

def divide_xml_by_quest_level(root):
    quests_by_level = {}
    for number in range(0, 15):
        quests_by_level[str(number)] = []
    quests_by_level["OTHER"] = []
    for quest in root.findall('quest'):
        level = quest.get('level')
        level = int(level) // 10
        if level < 0 or level > 14:
            level = "OTHER"
        quests_by_level[str(level)].append(quest)
    return dictionary_of_xml_trees(root, quests_by_level)


def main():
    start = time.time()

    # Load key-value from the labels XML file and convert it to a dictionary
    key_value_dict = extract_key_value_pairs('ImmersiveQuestReader/lotro-data/labels/en/quests.xml')
    print(f"✅ Extracted key-value pairs from the labels XML file in {(time.time() - start):.2f} seconds.")

    # Replace key strings with their values in the quests XML file
    xml_quests_labeled = replace_key('ImmersiveQuestReader/lotro-data/quests/quests.xml', key_value_dict)
    print(f"✅ Replaced keys with their values in the english quests XML file in {(time.time() - start):.2f} seconds.")

    # Divide the XML into multiple XML trees based on the first letter of the quest name
    # This is essential because LOTRO has a maximum size for Lua tables so we need do divide it into multiple smaller ones.
    # Bonus: it allows a faster search because we only search quests by name.
    divided_xml_trees = divide_xml_by_quest_name(xml_quests_labeled.getroot())
    print(f"✅ Divided the XML data into smaller XML trees in {(time.time() - start):.2f} seconds.")

    lua_tables = ""

    # Convert XML trees to Lua tables
    for key, xml_tree in divided_xml_trees.items():
        quests_dictionary = xml_to_dictionary(xml_tree.getroot())
        print(f"✅ Converted XML Quests {key} into a dictionary in {(time.time() - start):.2f} seconds.")

        # Format the Lua table as a string
        lua_table_quests_str = f"QUESTS_{key} = " + format_lua_table(quests_dictionary, beautiful=True)
        print(f"✅ Formatted the dictionary into a Lua table as a string for letter {key} in {(time.time() - start):.2f} seconds.")

        lua_tables += lua_table_quests_str

    # Write Lua tables to file
    with open(f'ImmersiveQuestReader/QuestDatabase.lua', 'w', encoding="utf-8") as file:
        lua_comment = "-- This file contains all the quests in the game, divided by the first letter of their name.\n-- It is necessary to divide the quests into multiple files because LOTRO has a maximum size for Lua tables.\n"
        file.write(lua_comment)

        file.write(lua_tables)

        # Create a table containing all the quest tables
        lua_database_list = f"QUEST_DATABASE = {{ {', '.join([f'QUESTS_{key}.quest' for key in divided_xml_trees.keys()])} }} \n\n"
        file.write(lua_database_list)
    print(f"✅ Wrote the Lua table to the 'QuestDatabase.lua' file in {(time.time() - start):.2f} seconds.")
        
    # lua_table = xml_to_dict(xml_tree.getroot())
    # print("Converted XML to Lua table.")
    # 
    # # Format the Lua table as a string
    # lua_table_quests_str = "QUESTS = " + format_lua_table(lua_table)
    # print("Formatted the Lua table as a string.")
    # 
    # # Output the Lua table
    # # print(lua_table_quests_str)
    # 
    # # Write Lua table to file
    # with open('ImmersiveQuestReader/QuestDatabase.lua', 'w', encoding="utf-8") as file:
    #     file.write(lua_table_quests_str)
    # print("Wrote the Lua table to the 'QuestDatabase.lua' file.")

if __name__ == "__main__":
    main()