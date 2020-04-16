#this is a walkthrough demo

# only concerned about designing a pattern. The next module will 
# show how to use them
help about_Regular_Expressions

start http://rubular.com

<#
demo character classes
\w
\W
\d
\s
\S

#>
<#
demo qualifiers and values
.
.*
{n}
{n,m}
[a-z]
[abc]
#>

<#
demo options

()
|
#>

<# create a pattern to match on SRV-02
 ^\w{3}-\d{2}$
 or to match on alpha
 ^[a-zA-Z]{3}-\d{2}$
#>

<# create a pattern to match 2019-11-01_data.txt
 don't forget to test for non-matches
 \d{4}-\d{2}-\d{2}_\w+\.\w+$

 alternative with anchors: ^20\d{2}(-\d{2}){2}_\w+\.\w{,3}$

 alternative with text extension
 ^\d{4}-\d{2}-\d{2}_\w+\.[a-zA-Z]+$

 advanced - validate on invalid values  and at least a 3 character extension
 ^20\d{2}-((0[1-9])|(1[012]))-(([012][0-9])|(3[01]))_\w+\.\w+{3,}$
#>
