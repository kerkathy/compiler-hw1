# hw1 report

|Field|Value|
|-:|:-|
|Name|柯婷文|
|ID|0710025|

## How much time did you spend on this project
around 16 hours

## Project overview

I used several states to complete this project. STRMODE, STRQUOTE, and STREND are for string constant, while LONGCOMMENT and SHORTCOMMENT are for C-style and C++-style comments.
I assign all the other patterns to be match only at INITIAL state so that once the scanner gets in the above 5 states, it can only match the specific patterns I assigned with those state. (If we didn't specify the <INITIAL> tag at the front of normal patterns, the patterns can be matched at any state, including STRMODE, etc, by default.)

In the Delimeter, Arithmetic, Relational, and Ligical Operators, and Reserved words part, we simply declare the pattern to be matched.

In the integer constants, I first declare octal integer to be composed of digits between 0-7 AND start with a zero. Then, decimal integer can be a zero or any number that starts with a nonzero digit.

As for the Floating-point constants, I use exactly the declaration of decimal integer to be the integral part. Then, the fractional part consist of zero or any digit that ends without 0.

Then for the scientific notations, we define the base to be a non zero integer or a floating point number. They are followed by a dot. The exponent is simply the decimal integer we defined before.

When it comes to string constant, it's broke down into three states:
Initially, we detect a qoute mark, and look ahead to check if it's followed by another quote mark in the same line. If so, transition the state into STRMODE in order to store the string. 
In STRMODE, we deal with normal string. Look ahead to check if there exists a double quote. If so, enter STRQUOTE state to deal with this condition. Else, if there exists another quote mark, it must be the end of the string, so we go into STREND state. In both cases, currently read string is stored into string buffer for later use.
In STRQUOTE, simply read in the double quote and save only one into string buffer. Then, go into STRMODE to check for normal string again.
In STREND, we're ending the string. We send the stored string in the buffer as output. Then empty the buffer by setting the first character to be '\0.' Afterwards, everything goes back to normal so we change the state to INITIAL.
Note that except for STREND, we have to LIST the current input so that it can be printed.

When we encounter white spaces including tabs, simply don't do anything other than LIST them so that they can be printed.

For the pseudo comments, apart from recognizing its pattern, it also needs to viewed as C++-styled comments. Thus, the state is transitioned into SHORTCOMMENT afterwards. LIST is also called because we didn't call TOKEN/ TOKEN_STRING/TOKEN_CHAR functions here.

In SHORTCOMMENT state, we only leave after a newline character (\n or \r\n) is detected. Anything before the newline character is ignored.

To deal with C-style comments, we detect it using `/*` , and leave the state upon `*/` is detected. Anything in between is detected by `.` and also neglected. 

Lastly, we catch all words that start with a letter and is followed by letters or digis to be identifiers. We put it in the very last part so that reserved words won't be classified as identifiers. (first match)

## What is the hardest you think in this project

For me it's the floating-point constant and scientific constant. I repeatedly misunderstood the definition and revised my code many times to fit the requirements.
Also the string constant part took me a long while to figure out the approriate way to deal with the double quote. (TKS to TA's help by the way!) To my surprise, I directly pass the test in this part without modifying anything! 

## Feedback to T.A.s

Overall, the explanation is super clear and the hints are indeed helpful. TA's answer about my question also helped A LOT. Thank you so much from the bottom of my heart!!
However, in my humble opinion, the explanation in the scientific section is a little bit unclear. It'll be perfect if it's modified as :

...where the coefficient a is a nonzero real number (a nonzero ***DECIMAL*** integer or a nonzero floating-point decimal number) ... 

I'm giving this suggestion only because the other part in this part are clearly required to be decimal, so when I read this part I misunderstood the definition of nonzero real number where __***both***__ nonzero decimal __***AND OCTAL***__ interger is accpted.

But anyway this is only my perspective. My roomate wasn't bothered at this part and she thought that I had been thinking too much :P
