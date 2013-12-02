#Ref: http://wiki.tcl.tk/14061

package require Tk

### Arrange for a clean exit.

wm protocol . WM_DELETE_WINDOW exit

### Set the window title.

wm title . Calculator

### Constants and variables.

set ::n 0                       ;# current button-widget name
set ::c 4                       ;# number of columns

set ::upToDateForeground black  ;# for result that has just been computed
                                 #  when expression is shown, and for
                                 #  expression that can be edited
set ::staleForeground gray      ;# for result that remains from last
                                 #  calculation but expression isn't shown,
                                 #  or for expression that can't be edited
set ::errorForeground red       ;# for result after a Tcl error
set ::staleErrorForeground darkred
                                 # for stale erroneous result

## As well as representing colors, these change the behavior of procedures.
set ::estate notDone            ;# notDone (can be edited,
                                 #  upToDateForeground) or done (can't be
                                 #  edited, staleForeground)
set ::rstate upToDate           ;# upToDate or stale or error or staleError
                                 #  as explained next to colors

array set ::superscripts {
    0   \u2070
    1   \u00B9
    2   \u00B2
    3   \u00B3
    4   \u2074
    5   \u2075
    6   \u2076
    7   \u2077
    8   \u2078
    9   \u2079
    +   \u207A
    -   \u207B
}
#                   1           2             3        4
set superscriptRE {^([-+]?[0-9]+(?:\.[0-9]+)?)(?:[DdEe]([-+]?[0-9]+))?$}
# 1 is sign, integer, fraction if any; integer. with no fraction is not
#  allowed
# 2 is fraction if any, an operand to the ? afterward, not returned
#  by regex because of the ?: modifier
# 3 is exponent character, exponent sign, exponent, not returned by regex
#  because of the ?: modifier
# 4 is the part of 3 that I want to translate to Unicode

# ASCII "+" is fine for math plus
set ::mathMinus      "\u2212"
set ::mathTimes      "\u00D7"
set ::mathDivide     "\u00F7"
set ::timesTenToThe  "\u00D710"
set ::timesTenToTheN "\u00D710\u207F"

## Widgets created later: .e is the expression (an entry widget)
## and .r is the result (a second entry widget).  .0 through .17
## are the buttons.

### Create buttons but don't do anything with them yet.

## keypad     button widget names
## layout     and "grid" command args
##
## c = / *    .0  .1  .2  .3
## 7 8 9 -    .4  .5  .6  .7
## 4 5 6 +    .8  .9  .10 .11
## 1 2 3 e    .12 .13 .14 .15
##  0  .      .16  -  .17  ^
##
## c represents "clear"
## e represents "enter"
##
## button purposes like keypad except enter position is = purpose
##  and = position is exponent purpose

foreach key {
    C e / *
    7 8 9 -
    4 5 6 +
    1 2 3 =
    0   .
} {
    ## Set each key's button's text.
    ## "default" applies to C 7 8 9 4 5 6 + 1 2 3 = 0 . keys
    switch -- $key {
        e       {set keytext $::timesTenToTheN}
        /       {set keytext $::mathDivide}
        *       {set keytext $::mathTimes}
        -       {set keytext $::mathMinus}
        default {set keytext $key}
    }
    ## Set each key's button's command.  See "procedures" below.
    ## "default" applies to e / * 7 8 9 - 4 5 6 + 1 2 3 0 . keys
    switch -- $key {
        C       {set cmd clearboth}
        =       {set cmd =}
        default {set cmd "hit $key"}
    }
    ## Create a button with the text and command as just set.
    ## The grid manager changes a button's width automatically,
    ## but not its height, so do that now.
    if [expr $::n == 15] {
        button .$::n -text $keytext -command $cmd -width 4 -height 2
    } else {
        button .$::n -text $keytext -command $cmd -width 4
    }
    incr ::n
}

### Lay out the entry widgets and buttons in a grid.

## Macintosh system dependency -- This is the only font I've found
## with superscripts that are all the same size.
grid [entry .e -textvar e -font {{Hoefler Text} 24} -just left] \
    -sticky we -columnspan $::c -pady 5
grid [entry .r  -font {{Hoefler Text} 24} -just right] \
    -sticky we -columnspan $::c -pady 5

grid .0  .1  .2  .3
grid .4  .5  .6  .7
grid .8  .9  .10 .11
grid .12 .13 .14 .15
grid .16  -  .17  ^
grid configure .0  -sticky we
grid configure .1  -sticky we
grid configure .2  -sticky we
grid configure .3  -sticky we
grid configure .4  -sticky we
grid configure .5  -sticky we
grid configure .6  -sticky we
grid configure .7  -sticky we
grid configure .8  -sticky we
grid configure .9  -sticky we
grid configure .10 -sticky we
grid configure .11 -sticky we
grid configure .12 -sticky we
grid configure .13 -sticky we
grid configure .14 -sticky we
grid configure .15 -sticky nsew
grid configure .16 -sticky we
grid configure .17 -sticky we

### Probably Macintosh system dependency -- Bind keyboard keys.
### Focus will be set later, and we assume it is never reset.

bind .e <Key-Num_Lock>    {clearboth; break}
bind .e <Key-c>           {clearboth; break}
bind .e <Key-KP_Equal>    {hit e; break}
bind .e <Key-e>           {hit e; break}
bind .e <Key-KP_Divide>   {hit /; break}
bind .e <Key-slash>       {hit /; break}
bind .e <Key-KP_Multiply> {hit *; break}
bind .e <Key-asterisk>    {hit *; break}
bind .e <Key-KP_7>        {hit 7; break}
bind .e <Key-7>           {hit 7; break}
bind .e <Key-KP_8>        {hit 8; break}
bind .e <Key-8>           {hit 8; break}
bind .e <Key-KP_9>        {hit 9; break}
bind .e <Key-9>           {hit 9; break}
bind .e <Key-KP_Subtract> {hit -; break}
bind .e <Key-minus>       {hit -; break}
bind .e <Key-KP_4>        {hit 4; break}
bind .e <Key-4>           {hit 4; break}
bind .e <Key-KP_5>        {hit 5; break}
bind .e <Key-5>           {hit 5; break}
bind .e <Key-KP_6>        {hit 6; break}
bind .e <Key-6>           {hit 6; break}
bind .e <Key-KP_Add>      {hit +; break}
bind .e <Key-plus>        {hit +; break}
bind .e <Key-KP_1>        {hit 1; break}
bind .e <Key-1>           {hit 1; break}
bind .e <Key-KP_2>        {hit 2; break}
bind .e <Key-2>           {hit 2; break}
bind .e <Key-KP_3>        {hit 3; break}
bind .e <Key-3>           {hit 3; break}
bind .e <Key-KP_Enter>    {=; break}
bind .e <Key-Return>      {=; break}
bind .e <Key-equal>       {=; break}
bind .e <Key-KP_0>        {hit 0; break}
bind .e <Key-0>           {hit 0; break}
bind .e <Key-KP_Decimal>  {hit .; break}
bind .e <Key-period>      {hit .; break}

### Procedures that widgets call.

proc clearboth {} {
    focus .e
    set ::e ""
    .e config -foreground $::upToDateForeground
    set ::estate notDone

    set ::r ""
    setr
    .r config -foreground $::upToDateForeground
    set ::rstate upToDate
}

proc = {} {
    focus .e
    .e config -foreground $::staleForeground
    set ::estate done

    if {![catch [set ::r [expr [string map {* *1.0* / *1.0/} $::e]]]]} {
        # what value should r show? its previous one? expr's best nuemrical
        #  approximation? text of the error?
        .r config -foreground $::errorForeground
        # is this really a good idea?
        setr
        set ::rstate error
    } else {
        .r config -foreground $::upToDateForeground
        setr
        set ::rstate upToDate
    }
}

proc hit {key} {
    focus .e
    switch -- $::estate {
        notDone {
            .e insert end $key
            .e icursor end
        }
        done    {
            if [regexp {[-+*/]} $key] {
                set ::e $::r
            } else {
                set ::e ""
            }
            .e insert end $key
            .e icursor end
            set ::estate notDone
            .e config -foreground $::upToDateForeground
        }
        default {
            # ignore for now
        }
    }

    switch -- $::rstate {
        upToDate   {
            .r config -foreground $::staleForeground
            set ::rstate stale
        }
        stale      {
            # remains stale
        }
        error      {
            .r config -foreground $::staleErrorForeground
            set ::rstate staleError
        }
        staleError {
            # remains staleError
        }
        default    {
            # ignore for now
        }
    }
}

### Subroutines.

proc setr {} {
    # Hopefully end will be rounded, as described in manual
    .r delete 0 end
    set ignored ""
    set mantissa ""
    set exponent ""
    set rdisplay ""
    if {[regexp $::superscriptRE $::r ignored mantissa exponent]} {
        if {[string length $exponent] > 0} {
            set unicodeExponent [regsub ^\\+0* $exponent ""]
            set unicodeExponent [regsub ^-0* $unicodeExponent "-"]
            set unicodeExponent [string map [array get ::superscripts] $unicodeExponent]
            set rdisplay "$mantissa$::timesTenToThe$unicodeExponent"
        } else {
            set rdisplay $mantissa
        }
    }
    .r insert end $rdisplay
}

### Main loop.

encoding system utf-8
focus .e
wm resizable . 0 0

