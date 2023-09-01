import xml.etree.ElementTree as ET
import time

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
def format_lua_table(table, indent=0):
    formatted = "{\n"
    for key, value in table.items():
        formatted += "\t" * (indent + 1)
        if isinstance(value, dict):
            formatted += f"{key} = {format_lua_table(value, indent + 1)}"
        elif isinstance(value, list):
            formatted += f"{key} = {format_lua_table_list(value, indent + 1)}"
        else:
            formatted += f"{key} = {repr(value)}"
        formatted += ",\n"
    formatted += "\t" * indent + "}"

    return formatted

# Function to format Lua table lists as string
def format_lua_table_list(list, indent):
    formatted = "{\n"
    for item in list:
        formatted += "\t" * (indent + 1)
        if isinstance(item, dict):
            formatted += format_lua_table(item, indent + 1)
        else:
            formatted += repr(item)
        formatted += ",\n"
    formatted += "\t" * indent + "}"

    return formatted


# Function to divide the XML into multiple XML trees based on the first letter of the quest name
# Returns a dictionary with dict[LETTER] -> XML tree
def divide_xml_by_quest_name_first_letter(root):
    quests_by_first_letter = {}
    for quest in root.findall('quest'):
        name = quest.get('name')
        letter = name[0].upper()
        if letter < 'A' or letter > 'Z':
            # Regroup quests starting with numbers or non ASCII letters in a table
            letter = "OTHER"
        if letter in quests_by_first_letter:
            # Insert the new quest in the dictionary
            quests_by_first_letter[letter].append(quest)
        else:
            # Create the dictionary if it doesn't exist
            quests_by_first_letter[letter] = [quest]

    divided_xml_trees = {}
    for letter, quests in quests_by_first_letter.items():
        divided_xml_trees[letter] = ET.ElementTree(ET.Element(root.tag))
        for quest in quests:
            divided_xml_trees[letter].getroot().append(quest)
    
    return divided_xml_trees

        



def main():

    start = time.time()

    # Load key-value from the labels XML file and convert it to a dictionary
    key_value_dict = extract_key_value_pairs('ImmersiveQuestReader/lotro-data/labels/en/quests.xml')
    print(f"✅ Extracted key-value pairs from the labels XML file in {(time.time() - start):.2f} seconds.")

    # Replace key strings with their values in the quests XML file
    xml_quests_labeled = replace_key('ImmersiveQuestReader/lotro-data/quests/quests.xml', key_value_dict)
    print(f"✅ Replaced keys with their values in the english quests XML file in {(time.time() - start):.2f} seconds.")


    # ----- Write and read intermediate XML files -----
    # Write the labeled quests XML file
    # xml_tree.write('ImmersiveQuestReader/quests.xml', encoding="utf-8", xml_declaration=True)
    # print("Wrote the labeled english quests XML file.")
    # Repeat for every language

    # # Load the labeled XML file
    # tree = ET.parse('ImmersiveQuestReader/quests.xml')
    # root = tree.getroot()
    # -----


    # Divide the XML into multiple XML trees based on the first letter of the quest name
    # This is essential because LOTRO has a maximum size for Lua tables so we need do divide it into multiple smaller ones.
    # Bonus: it allows a fatser search because we only search quests by name.
    divided_xml_trees = divide_xml_by_quest_name_first_letter(xml_quests_labeled.getroot())

    lua_tables = ""

    # Convert XML trees to Lua tables
    for letter, xml_tree in divided_xml_trees.items():
        quests_dictionary = xml_to_dictionary(xml_tree.getroot())
        print(f"✅ Converted XML Quests {letter} into a dictionary in {(time.time() - start):.2f} seconds.")

        # Format the Lua table as a string
        lua_table_quests_str = f"QUESTS{letter} = " + format_lua_table(quests_dictionary)
        print(f"✅ Formatted the dictionary into a Lua table as a string for letter {letter} in {(time.time() - start):.2f} seconds.")

        lua_tables += lua_table_quests_str

    # Write Lua tables to file
    with open(f'ImmersiveQuestReader/QuestDatabase.lua', 'w', encoding="utf-8") as file:
        file.write(lua_tables)
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