# AsmPro Cheat Sheet

## Commands



| Command  | Action | Notes |
| ------------- | ------------- | ------------- |
| a  | assemble  |
| d | debug  | can combine with assemble ```ad``` can take a label ```d LABEL```  can take a memory location ```d $00000914```
| m[.size][address] | edit memory |
| h [.size][address] | hex dump|
| ? | query | can take a label to show label address in memory ```? LABEL```
| =s | show symbol offsets | 
| =r | registers |
