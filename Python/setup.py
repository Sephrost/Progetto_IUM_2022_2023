from Gui.graphic_interface import App
import sys
import signal

def signal_handler(sig, frame):
    sys.exit(0)

if __name__ == "__main__":
    # check python version
    if sys.version_info[0] < 3 or sys.version_info[1] < 10:
        raise Exception("Python 3.10 or a more recent version is required.")
    signal.signal(signal.SIGINT, signal_handler)
    app = App()
    app.mainloop()
    
    
    
