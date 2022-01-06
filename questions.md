# Questions

## Stuff I've had to ask about or intend to ask about

### Compiler stuff:

---

*Q* How do these 2 examples have the same effect as putting red in the background colour?

Why is 

```
dc.w	$180,$600	
```

the same as:

```
dc.w	$180
dc.w	$600
```

The first example sets red into the system register for background colour (DC.W DESTINATION:SOURCE). The second example is equivalent - how? Does the compiler 'know' that $180 within a copperlist is a special register and just accepts the next DC.w it comes across as the value? 

If you put the following in the copper list at the end, no complaints, code still runs. Is it putting $600 into location $700? What is the difference here?
```
dc.w	$700
dc.w	$600
```

The notes mention the equivalence [here](https://github.com/matthewdeaves/ramjamexamples/blob/f665095b002e28c2c511a8b7fb6a9d244eb8f473/SORGENTI/LEZIONE3c_colours.s#L235)

*Answer*

First, [watch this video](https://www.youtube.com/watch?v=ZPJW3wIfL4I)

An assembled program is loaded into memory staring from one starting address. Each memory address can contain up to one LONG WORD. See this example using ```h.w```

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q1a4.png)

It's useful to use the h (hex dump) command to study this. The whole program is represented by each memory location laid out one after the other with its execution starting at the base address. If you start your program with a label such as

```
Init:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)		; Disable multitasking
	lea	GfxName(PC),a1	; Address of the name of the lib to open in a1
	jsr	-$198(a6)	; OpenLibrary, EXEC routine that opens
```

You can use ```h.w Init``` to show the contents of memory from the address of the ```Init``` label:

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q1a3.png)

```dc``` writes directly to the memory sequentially. This is why the above examples are the same. To prove it start with the code:

```
BAR:
	dc.w	$180,$600
```

Then use ```h.w BAR``` to show

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q1a1.png)


Then change the code to

```
BAR:
	dc.w	$180
	dw.w	600
```

Then use ```h.w BAR``` to show

![h.w BAR output ](https://github.com/matthewdeaves/ramjamexamples/blob/main/myimages/q1a2.png)

Notice it is the same data in the memory location of BAR whichever method we choose.

---