anagrams = {} # Anagrams list, used later
wordset = set() # Set of the words eg: {'a', 'b', 'c'}
sorted_vertices =  {} # Hashlist<key,set> eg: {'a': {'a', 'b', 'c'}, 'b': {'a', 'b', 'c'}, 'c': {'a', 'b', 'c'}}
rules_applied = {
        1 : 'R1',
        2 : 'R2',
        3 : 'R3',
        4 : 'R4',
        5 : 'R5'
        }

selected_vertices = set()