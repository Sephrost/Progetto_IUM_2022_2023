import networkx as nx
from .structures import anagrams, wordset, rules_applied, selected_vertices
import matplotlib.pyplot as plt


def read_dictionary(G: nx.Graph, filename: str) -> nx.Graph:
    '''
    Read the dictionary of words to populate the graph
    and the supporting data structures

    G: The graph to add the words to
    filename: The name of the file to read
    '''
    # read the dictionary file
    with open(filename, 'r') as f:
        for line in f:
            word = line.strip().lower()
            if len(word) < 1 or word == '':
                continue
            G.add_node(word)
            # add word to the anagram dictionary
            anagrams.setdefault(''.join(sorted(word)), []).append(word)
            # add word to the words dictionary
            wordset.add(word)
    return G

def generate_edges(G: nx.Graph, flags: list[bool]) -> nx.Graph:
    '''
    Generate the edges between the nodes of the graph

    G: The graph to generate the edges for
    flags: The flags to determine which rules to apply
    '''
    
    if flags[0]:
        for keys in anagrams.keys():
            for i in range(len(anagrams[keys])):
                for j in range(i + 1, len(anagrams[keys])):
                    G.add_edge(anagrams[keys][i], anagrams[keys][j], weight=1)
                    G.add_edge(anagrams[keys][j], anagrams[keys][i], weight=1)

    for word in wordset:
        wl = filter(edits(word, flags), word)
        for w, val in wl:
            G.add_edge(word, w, weight=val)
    
    return G
    
def filter(words: set, word: str):
    '''
    Filter the words to only include words that are in the dictionary and are not the selectes word

    words: The list of words to filter
    word: The word to filter out
    '''
    return set((w, val) for w, val in words if w in wordset and w != word)


def edits(word: str, flags: list[bool]) -> set:
    '''
    Returns a list of all possible edits of a word

    word: The word to edit
    flags: The flags to determine which rules to apply
    '''
    insert_begin = None
    inserts_inbetween = None
    insert_end = None
    replaces = None
    letters = 'abcdefghijklmnopqrstuvwxyz'

    splits = [(word[:i], word[i:]) for i in range(len(word) + 1)]
    if flags[1]:
        insert_begin = [(c + splits[0][1], 3) for c in letters]
    if flags[2]:
        inserts_inbetween = [(L + c + R, 4) for L, R in splits[1:len(splits)-1] for c in letters]
    if flags[3]:
        insert_end = [(splits[len(splits)-1][0] + c, 5) for c in letters]
    if flags[4]:
        replaces = [(L + c + R[1:], 2) for L, R in splits if R for c in letters]
    return set((replaces if flags[4] else []) + (insert_begin if flags[1] else []) + (inserts_inbetween if flags[2] else []) + (insert_end if flags[3] else []))


def draw_graph(graph: nx.Graph, v1: str, v2: str) -> bool:
    '''
    Draw the graph to svg file

    graph: The graph to draw
    '''
    v1 = v1.strip().lower()
    v2 = v2.strip().lower()

    # Generate the edges of the graph
    if not nx.has_path(graph, v1, v2):
        print(f"No path found between {v1} and {v2}")
        return False

    vertices = nx.shortest_path(graph, v1, v2)
    # get weight list for the minpath
    weight_list = ''
    for i in range(len(vertices) - 1):
        weight_list += rules_applied[graph[vertices[i]]
                                     [vertices[i + 1]]['weight']] + ' '
    print(f'[+] Path generated from weights {weight_list}')

    adjacents = []
    for v in vertices:
        for i in list(graph.neighbors(v))[:10]:
            if i not in vertices and i not in adjacents:
                adjacents.append(i)

    draw_nodes = vertices + adjacents

    # generate subgraph
    subgraph = graph.subgraph(draw_nodes)
    print(
        f'[+] Done generating subgraph with {subgraph.number_of_nodes()} nodes and {subgraph.number_of_edges()} edges')

    pos = nx.spring_layout(subgraph, k=20, iterations=50)
    nx.draw_networkx_nodes(subgraph, pos, nodelist=vertices,
                           node_size=500, node_color='#3182bd')
    nx.draw_networkx_nodes(subgraph, pos, nodelist=adjacents,
                           node_size=500, node_color='r')
    nx.draw_networkx_edges(
        subgraph, pos, edgelist=subgraph.edges(), width=1, edge_color='k')
    nx.draw_networkx_labels(subgraph, pos, font_size=9,
                            font_family='sans-serif')
    plt.axis('off')
    plt.savefig('./graph.png', format='png', dpi=200)
    # clear pos
    plt.clf()
    return True


def add_selected_words(G: nx.Graph, v1: str, v2: str) -> nx.Graph:
    '''
    Add the selected words from input field into the graph and the supporting data structures

    G: The graph to add the words to
    v1: The first word
    v2: The second word
    '''
    v1 = v1.strip().lower()
    v2 = v2.strip().lower()

    if v1 not in G.nodes():
        G.add_node(v1)
        wordset.add(v1)
        anagrams.setdefault(''.join(sorted(v1)), []).append(v1)

    if v2 not in G.nodes():
        G.add_node(v2)
        wordset.add(v2)
        anagrams.setdefault(''.join(sorted(v2)), []).append(v2)

    selected_vertices.add(v1)
    selected_vertices.add(v2)

    return G
