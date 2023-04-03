#AsmPro Cheat Sheet

|Key Combo|Action|
| ------------- | ------------- | ------------- |
| Left command key + arrow keys | will move the text cursor in AsmPro
| Right command key + t | go to top of source in the editor
| Right command key + T | go to the bottom of source in the editor
| Right command key + shift + s | search |
| Right command key + s | search again for same term|

##AsmPro Cheat Sheet

| Command  | Action | Notes |
| ------------- | ------------- | ------------- |
| !!  | quick quit  | hard quit AsmPro without saving |
| a  | assemble  | assemble your code |
| j  | jump  | basic command to run your code |
| d | debug | can combine with assemble ```ad``` can take a label ```d LABEL```  can take a memory location ```d $00000914```
| d [label] | debug | start debug from a label |
| m[.size][address] | edit memory |
| h [.size][address] | hex dump|
| ? | query | can take a label to show label address in memory ```? LABEL```
| =s | show symbol offsets | 
| =r | registers | show information about registers |
| =r[address] | registers | show information about register for address ```=r100``` |

