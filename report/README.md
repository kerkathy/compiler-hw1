# hw1 report

|Field|Value|
|-:|:-|
|Name|柯婷文|
|ID|0710025|

## How much time did you spend on this project
around 16 hours

## Project overview

Describe the project structure and how you implemented it.

I used several states to complete this project. STRMODE, STRQUOTE, and STREND are for string constant, while LONGCOMMENT and SHORTCOMMENT are for C-style and C++-style comments.
I assign all the other patterns to be match only at INITIAL state so that once the scanner gets in the above 5 states, it can only match the specific patterns I assigned with those state. (If we didn't specify the <INITIAL> tag at the front of normal patterns, the patterns can be matched at any state, including STRMODE, etc, by default.)

In the Delimeter, Arithmetic, Relational, and Ligical Operators, and Reserved words part, we simply declare the pattern to be matched.

In the integer constants, I first declare octal integer to be composed of digits between 0-7 AND start with a zero. Then, decimal integer can be a zero or any number that starts with a nonzero digit.

As for the Floating-point constants, I use exactly the declaration of decimal integer to be the first part. 


## What is the hardest you think in this project

For me it's the floating-point constant and scientific constant. I repeatedly misunderstood the definition and revised my code many times to fit the requirements.
Also the string constant part took me a long while to figure out the approriate way to deal with the double quote. (TKS to TA's help by the way!) To my surprise, I directly pass the test in this part without modifying anything! 

## Feedback to T.A.s

Overall, the explanation is super clear and the hints are indeed helpful. TA's answer about my question also helped A LOT. Thank you so much from the bottom of my heart!!
However, in my humble opinion, the explanation in the scientific section is a little bit unclear. It'll be perfect if it's modified as :

where the coefficient a is a nonzero real number (a nonzero ***DECIMAL*** integer or a nonzero floating-point decimal number)

I'm giving this suggestion only because the other part in this part are clearly required to be decimal, so when I read this part I misunderstood the definition of nonzero real number where __***both***__ nonzero decimal __***AND OCTAL***__ interger is accpted.

But anyway this is only my perspective. My roomate wasn't bothered at this part and she thought that I had been thinking too much :P
