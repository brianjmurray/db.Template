# run `pip install -r requirements.txt`
# This only needs to be run once if you don't have the libraries installed
# run it inside the documentation/Diagram folder

import os
import re
import networkx as nx
import matplotlib.pyplot as plt
import community as cmt
from pyvis.network import Network
import random

# Ignore specific schemas
ignored_folders = ['dbo', 'documentation',
                   'etl', 'History', 'lib', 'xsec']
schema_colors = {}  # Global dictionary to store colors for each schema

# Check if the script is running in the Azure Pipelines environment
azure_build = 'BUILD_SOURCESDIRECTORY' in os.environ

if azure_build:
    base_path = os.environ['BUILD_SOURCESDIRECTORY']
else:
    # This assumes the script is located in the documentation/Diagram directory
    base_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

documentation_folder = os.path.join(base_path, 'documentation')

def interactive_plot(graph, table_definition, schema_colors=None, schema_name=None):
    """
    Generates an interactive plot of a graph using the NetworkX and vis.js libraries.
    The plot displays nodes as boxes colored by schema, with hover information for each node.
    Nodes are positioned using the spring_layout algorithm.

    Args:
        graph (nx.Graph): The graph to plot.
        table_definition (dict): A dictionary mapping node names to lists of table information.

    Returns:
        None
    """
    nt = Network(notebook=True, height="1080px", width="100%")
    nt.from_nx(graph)

    # If no schema colors provided, generate them
    if schema_colors is None:
        schema_colors = {}

    # 1. Assign colors based on schema
    # schema_colors = {}
    for node in graph.nodes():
        schema = node.split('.')[0]  # Extract schema from node name
        if schema not in schema_colors:
            # Generate a random color for each new schema encountered
            # Limited to higher numbers as this produces lighter colors that are easier to read with dark text
            schema_colors[schema] = "#" + \
                ''.join([random.choice('6789ABCDEF') for j in range(6)])

        # Find the index of the node with label 'node'
        node_idx = next(index for index, nt_node in enumerate(
            nt.nodes) if nt_node['id'] == node)
        nt.nodes[node_idx]['color'] = schema_colors[schema]

        nt.nodes[node_idx]['shape'] = 'box'

        # # Set hover information (in this example, the node's name)
        # for node in graph.nodes():
        #     node_idx = next(index for index, nt_node in enumerate(nt.nodes) if nt_node['id'] == node)
        #     table_info = table_definition.get(node, [])
        #     nt.nodes[node_idx]['title'] = table_info
        from IPython.display import HTML

        for node in graph.nodes():
            node_idx = next(index for index, nt_node in enumerate(
                nt.nodes) if nt_node['id'] == node)
            table_info = table_definition.get(
                node, "")
            nt.nodes[node_idx]['title'] = table_info

    # 2. Adjust node positions to keep tables of the same schema closer
    # Use spring_layout or another layout of your choice
    pos = nx.spring_layout(graph)
    for node, (x, y) in pos.items():
        node_idx = next(index for index, nt_node in enumerate(
            nt.nodes) if nt_node['id'] == node)
        # Multiplying by a value to scale and spread nodes. Adjust if necessary.
        nt.nodes[node_idx]['x'] = x * 4500
        # Multiplying by a value to scale and spread nodes. Adjust if necessary.
        nt.nodes[node_idx]['y'] = y * 3000

    if schema_name is not None:
        # Save the graph to a separate HTML file
        filename = f"{documentation_folder}/EmbraceDiagram_{schema_name}.html"
    else:
        filename = f"{documentation_folder}/EmbraceDiagram.html"

    nt.show(filename)

    #print that file was created
    print(f"Created {filename}")


def extract_tables_and_relations(file_path):
    """
    Extracts table names, foreign key relations, and table definition from a SQL file.

    Args:
        file_path (str): The path to the SQL file.

    Returns:
        tuple: A tuple containing:
            - list: A list of table names in the format "schema.table".
            - list: A list of foreign key relations in the format "schema.table".
            - str: The full table definition as a string.
    """
    with open(file_path, 'r') as f:
        content = f.read()

        # Extract table names, considering schema prefixes
        table_matches = re.findall(
            r'CREATE TABLE \[?([a-zA-Z0-9_]+)\]?.\[?([a-zA-Z0-9_]+)\]?', content)
        tables = [f"{match[0]}.{match[1]}" for match in table_matches]

        # Extract foreign key relations considering the provided SQL format
        relations = re.findall(
            r'FOREIGN KEY \(\[?[a-zA-Z0-9_]+\]?\) REFERENCES \[?([a-zA-Z0-9_]+)\]?.\[?([a-zA-Z0-9_]+)\]?', content)
        relations = [
            f"{match[0]}.{match[1]}" for match in relations if match[0] not in ignored_folders]

        # # Extract primary key]
        primary_key_pattern = r'(?:CONSTRAINT\s*\[\w+\]\s*)?PRIMARY KEY CLUSTERED\s*\(\[?(\w+)\]?\s*ASC\)'
        primary_keys = re.findall(primary_key_pattern, content)
        primary_key_str = f"Primary Key: {primary_keys[0]}\n" if primary_keys else ""

        # Extract foreign keys
        foreign_keys = re.findall(
            r'FOREIGN KEY \(\[?([a-zA-Z0-9_]+)\]?\) REFERENCES \[?([a-zA-Z0-9_]+)\]?.\[?([a-zA-Z0-9_]+)\]?', content)
        foreign_keys_str = "\n".join(
            [f"join to {fk[1]}.{fk[2]} on {fk[0]}" for fk in foreign_keys])

        table_definition = primary_key_str + \
            (foreign_keys_str if primary_key_str else foreign_keys_str.lstrip("\n"))

        # If there are no primary foreign keys, table_definition is an empty string
        if not table_definition:
            table_definition = "No primary or foreign keys"

        # Prepend the table definition with table name
        table_definition = tables + ["\n" + table_definition]

    return tables, relations, table_definition


def scan_sql_files(directory):
    relational_graph = nx.DiGraph()

    # Filter top-level directories based on your criteria
    top_level_dirs = [d for d in os.listdir(directory)
                      if os.path.isdir(os.path.join(directory, d))
                      and d[0].isupper()
                      and d not in ignored_folders]

    table_columns = {}  # To store columns for each table

    for top_dir in top_level_dirs:
        for subdir, dirs, files in os.walk(os.path.join(directory, top_dir)):
            for file in files:
                if file.endswith('.sql'):
                    file_path = os.path.join(subdir, file)
                    tables, relations, columns = extract_tables_and_relations(
                        file_path)

                    for table in tables:
                        relational_graph.add_node(table)
                        table_columns[table] = columns  # Store columns info

                    for relation in relations:
                        # Check if the edge does not exist before adding it
                        if not relational_graph.has_edge(tables[0], relation):
                            relational_graph.add_edge(tables[0], relation)

    return relational_graph, table_columns


def custom_schema_layout(graph):
    # Extract unique schemas from node names
    schemas = list(set(node.split('.')[0] for node in graph.nodes()))
    schemas.sort()  # Sort for consistency

    # Initial positions
    positions = {}

    # Determine spacing based on the number of schemas
    y_gap = 1.0 / (len(schemas) + 1)

    for index, schema in enumerate(schemas):
        y_pos = (index + 1) * y_gap
        # Get all tables for this schema
        tables = [node for node in graph.nodes(
        ) if node.startswith(schema + '.')]

        x_gap = 1.0 / (len(tables) + 1)
        for idx, table in enumerate(tables):
            x_pos = (idx + 1) * x_gap
            positions[table] = (x_pos, y_pos)

    # Return positions refined using spring layout
    return nx.spring_layout(graph, pos=positions, k=0.5, iterations=50)


def get_subgraph_for_schema(full_graph, schema_name):
    nodes_for_schema = [node for node in full_graph.nodes(
    ) if node.startswith(schema_name + '.')]
    return full_graph.subgraph(nodes_for_schema).copy()


def generate_index_html(schemas):
    """
    Generate an index.html file linking to all the diagram pages.
    Args:
        schemas (list): A list of schema names for which diagrams exist.
    Returns:
        None
    """
    with open(f"{documentation_folder}/index.html", "w") as index_file:
        # Start of the HTML content
        content = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Schema Diagrams</title>
</head>
<body>
    <h1>Overall Diagrams</h1>
    <ul><li><a href="EmbraceDiagram.html">Overall Schema Diagram</a></li></ul>
    <h1>Schema Diagrams</h1>
    <ul>
"""

        # Sort schemas alphabetically
        schemas.sort()

        # Generate a list item for each schema diagram
        for schema in schemas:
            content += f'        <li><a href="EmbraceDiagram_{schema}.html">{schema} Schema Diagram</a></li>\n'

        # End of the HTML content
        content += """
    </ul>
</body>
</html>
"""
        index_file.write(content)
        # print the path to the file that was created
        print(f"Created {documentation_folder}/index.html")


if __name__ == '__main__':
    # directory_path = input(
    #     "Enter the root directory of your database project (or press Enter to use the current directory): ")

    # if not directory_path.strip():  # Check if the input is empty
    directory_path = os.getcwd()
    print(f"Using current directory: {directory_path}")

    relational_graph = scan_sql_files(directory_path)

    os.chdir(documentation_folder)

    interactive_plot(relational_graph[0], relational_graph[1])

    # Generate schema-wise diagrams
    schemas = list(set(node.split('.')[0]
                   for node in relational_graph[0].nodes()))
    for schema in schemas:
        schema_graph = get_subgraph_for_schema(relational_graph[0], schema)
        interactive_plot(schema_graph, relational_graph[1],
                         schema_colors, schema)

    # Generate an index.html file linking to all the diagram pages
    generate_index_html(schemas)
