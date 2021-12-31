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

It just.... is.

---