import os
import networkx as nx
from App import graph_lib
from multiprocessing import Queue

def generate_graph(q: Queue, filename: str, rules: list, v1: str, v2: str):
            # delete file if it exists
        graph = nx.DiGraph()
        print("[+] Loading dictionary...")
        graph = graph_lib.read_dictionary(graph, filename)
        print("[+] Check selected rules...")
        graph = graph_lib.add_selected_words(graph, v1, v2)
        print("[+] Applying rules...")
        graph = graph_lib.generate_edges(graph, rules)
        q.put_nowait(graph)
        
def check_errors(filename: str, rules: list, v1: str, v2:str) -> int:
    if v1 == "" or v2 == "":
        return 1
    elif v1 == v2:
        return 2
    elif all(x == False for x in rules):
        return 3
    elif filename == None:
        return 4
    else:
        return 0