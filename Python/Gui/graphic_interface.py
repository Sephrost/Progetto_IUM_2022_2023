from tkinter import filedialog as fd
import customtkinter

from .img_manager import CanvasImage as CI
from .functions import *

from multiprocessing import Process

import networkx as nx

customtkinter.set_appearance_mode("System")  # Modes: system (default), light, dark
customtkinter.set_default_color_theme("blue")  # Themes: blue (default), dark-blue, green

class App(customtkinter.CTk):

    WIDTH = 1100
    HEIGHT = 700

    def __init__(self):
        super().__init__()

        self.title("Distance Word Calculator")
        self.geometry(f"{App.WIDTH}x{App.HEIGHT}")
        self.protocol("WM_DELETE_WINDOW", self.on_closing)  # call .on_closing() when app gets closed

        self.filename = None
        # ============ create two frames ============

        # configure grid layout (2x1)
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

        self.frame_left = customtkinter.CTkFrame(master=self, width=300)
        self.frame_right = customtkinter.CTkFrame(master=self)
        
        self.frame_left.grid(row=0, column=0, sticky="nswe")
        self.frame_right.grid(row=0, column=1, sticky="nswe", padx=20, pady=20)
        
        # ============ frame_left ============

        # configure grid layout (2x11)
        self.frame_left.grid_columnconfigure(1, weight=1)
        self.frame_left.grid_rowconfigure(0, minsize=10)   # empty row with minsize as spacing
        self.frame_left.grid_rowconfigure((4,9), weight=1)  # empty row as spacing
        self.frame_left.grid_rowconfigure(13, minsize=10)  # empty row with minsize as spacing
        
        self.label_1 = customtkinter.CTkLabel(master=self.frame_left,
                                              text="Graph visualizer",
                                              font=("Roboto Medium", -18))
        
        # ============ dictionary_frame ============
        
        self.dictionary_frame = customtkinter.CTkFrame(master=self.frame_left)
        self.dictionary_frame.grid(row=2, column=0, columnspan=2, rowspan=2, pady=20, padx=20, sticky="nsew")

        self.dictionay_label = customtkinter.CTkLabel(master=self.dictionary_frame,
                                                        text="Dictionary info: ",
                                                        font=("Roboto Medium", -15))

        self.dictionay_bottom = customtkinter.CTkButton(master=self.dictionary_frame,
                                                    text="Select dictionary",
                                                    command=self.dictionay_picker)
        
        self.word_label = customtkinter.CTkLabel(master=self.dictionary_frame,
                                                 text="Loaded words: 0")
        
        # ============ rules_frame ============
        
        self.rules_frame = customtkinter.CTkFrame(master=self.frame_left)
        self.rules_frame.grid(row=5, column=0, columnspan=2, rowspan=4, pady=20, padx=20, sticky="nsew")    
        
        self.rule_label = customtkinter.CTkLabel(master=self.rules_frame,
                                                    text="Select Rules: ",
                                                    font=("Roboto Medium", -15))
        
        self.rule_1 = customtkinter.CTkCheckBox(master=self.rules_frame,
                                                    text="Anagram")
        
        self.rule_2 = customtkinter.CTkCheckBox(master=self.rules_frame,
                                                    text="Extra char at the beginning")
        
        self.rule_3 = customtkinter.CTkCheckBox(master=self.rules_frame,
                                                    text="Extra char in between")
        
        self.rule_4 = customtkinter.CTkCheckBox(master=self.rules_frame,
                                                    text="Extra char at the end")
        
        self.rule_5 = customtkinter.CTkCheckBox(master=self.rules_frame,
                                                    text="One char diff")
        # ============ words_frame ============    
            
        self.words_frame = customtkinter.CTkFrame(master=self.frame_left)
        self.words_frame.grid(row=10, column=0, columnspan=2, rowspan=3, pady=20, padx=20, sticky="nsew")       
            
        self.label_words = customtkinter.CTkLabel(master=self.words_frame,
                                                text="Words to connect",
                                                font=("Roboto Medium", -15))

        self.entry_1 = customtkinter.CTkEntry(master=self.words_frame,
                                                width=130,
                                                placeholder_text="Enter word 1",)
        
        self.entry_2 = customtkinter.CTkEntry(master=self.words_frame,
                                                width=130,
                                                placeholder_text="Enter word 2",)

        self.confirm_button = customtkinter.CTkButton(master=self.words_frame,
                                                    text="Confirm",
                                                    command=self.on_confirmed)

                # Attach widgets to grid
        
        self.label_1.grid(row=1, column=0, pady=10, padx=10, sticky="n")        
        self.dictionay_label.grid(row=0, column=0, columnspan=2, pady=10, padx=20) 
        self.dictionay_bottom.grid(row=1, column=0, columnspan=1, pady=10, padx=20, sticky="w")        
        self.word_label.grid(row=1, column=1, columnspan=1, pady=10, padx=20, sticky="w") 
        # Row 4 vuota
        self.rule_label.grid(row=0, column=0, columnspan=2, pady=10, padx=5)
        self.rule_1.grid(row=1, column=0, columnspan=1, pady=10, padx=5, sticky="w")
        self.rule_2.grid(row=1, column=1, columnspan=1, pady=10, padx=5, sticky="w")
        self.rule_3.grid(row=2, column=0, columnspan=1, pady=10, padx=5, sticky="w")
        self.rule_4.grid(row=2, column=1, columnspan=1, pady=10, padx=5, sticky="w")        
        self.rule_5.grid(row=3, column=0, columnspan=1, pady=10, padx=5, sticky="w")        
        # Row 9 vuota
        self.label_words.grid(row=0, column=0, columnspan=2, pady=10, padx=10)
        self.entry_1.grid(row=1, column=0, pady=10, padx=20)  
        self.entry_2.grid(row=1, column=1, pady=10, padx=20)
        self.confirm_button.grid(row=2, column=0, columnspan=2, pady=10, padx=20)

        # ============ frame_right ============

        # configure grid layout (2x2)
        self.frame_right.rowconfigure((0, 1, 2, 3, 4, 5), weight=1)
        self.frame_right.rowconfigure(9, weight=10)
        self.frame_right.columnconfigure((0, 1), weight=1)

        # ============ frame_img ============

        self.img = CI(placeholder=self.frame_right, path='./default.jpeg')
        
        self.progressbar = customtkinter.CTkProgressBar(master=self.frame_right, mode="indeterminate")
        self.progress_text = customtkinter.CTkLabel(master=self.frame_right, text="")
        
        self.img.grid(column=0, row=1, columnspan=3, rowspan=9, sticky="nwe", padx=10, pady=10)
        self.progressbar.grid(row=0, column=0, columnspan=2, sticky="ew", padx=2, pady=15)        
        self.progress_text.grid(row=0, column=2, sticky="w", padx=2, pady=15)

        # ============ functions ============

    def update_img(self, path: str):
        self.img = CI(placeholder=self.frame_right, path='graph.png')
        self.img.grid(column=0, row=1, columnspan=3,rowspan=9, sticky="nwe", padx=10, pady=10)

    def on_confirmed(self):
        self.progressbar.start()
        rules = []
        for i in range(1,6):
            if eval(f"self.rule_{i}.get()"):
                rules.append(True)
            else:
                rules.append(False)
        err = check_errors(self.filename, rules, self.entry_1.get(), self.entry_2.get())
        match err:  
            case 1:
                self.progress_text.configure(text="Error: One or more words are empty")
            case 2:
                self.progress_text.configure(text="Error: Words are identical")
            case 3:
                self.progress_text.configure(text="Error: No rules selected")
            case 4:
                self.progress_text.configure(text="Error: No dictionary selected")
            case 0:
                # run function on a thread and get the result
                queue = Queue()
                self.p = Process(target=generate_graph, args=(queue, self.filename, rules, self.entry_1.get(), self.entry_2.get()))
                self.p.start()
                self.progress_text.configure(text="Generating graph...")
                while queue.empty():
                    self.update()
                self.progressbar.stop()
                graph = queue.get()
                self.img.destroy()
                if graph_lib.draw_graph(graph, self.entry_1.get(), self.entry_2.get()):
                    print("Graph drawn")
                    self.update_img('graph.png')
                    self.progress_text.configure(text="Path found!")
                else:
                    # self.img.destroy()
                    self.update_img('default.jpeg')
                    self.progress_text.configure(text="No path found")
                if self.p.is_alive():
                    self.p.terminate()
        self.progressbar.stop()

                
    def dictionay_picker(self):
        # file picker
        self.filename = fd.askopenfilename(title="Select dictionary", filetypes=[("Text files", "*.txt")])
        # open file
        words = []
        try:
            with open(self.filename, "r") as f:
                for line in f:
                    word = line.strip().lower()
                    if len(word) < 1 or word == '':
                        continue
                    words.append(word)
            self.word_label.configure(text=f"Loaded words: {len(words)}")
        except:
            self.word_label.configure(text="No dictionary selected, retry")
        
    def on_closing(self, event=0):
            try:
                if self.p.is_alive():
                    self.p.terminate()
            except:
                pass
            self.quit()
