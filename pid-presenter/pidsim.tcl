#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

#-----------------------------------------------------------------------
# screen setup
#-----------------------------------------------------------------------

set screenwd 1024
set screenwd 800
set screenht [expr $screenwd*(3.0/4.0)]

#-----------------------------------------------------------------------
# 
#-----------------------------------------------------------------------

set gravity 9.8

set thrustpower 20

set velocity 0
set altitude 0
set windvelocity 0

#-----------------------------------------------------------------------
# 
#-----------------------------------------------------------------------

set pVal 0
set iVal 0
set dVal 0

set lasterr 0
set cumerr 0
set slope 0


#-----------------------------------------------------------------------
# 
#-----------------------------------------------------------------------

proc X {x} {
    global screenwd
    set n [expr round(double($x)*$screenwd)]
    return $n
}

proc Y {y} {
    global screenwd screenht
    set n [expr round($screenht-double($y)*$screenwd)]
    return $n
}

set _togglegrid 0
proc togglegrid {} {
    global _togglegrid
    if ${_togglegrid} {
        set _togglegrid 0
        .c delete grid
    } else {
        set _togglegrid 1
        for {set q 0.0} {$q < 1.0} {set q [expr $q+.1]} {
            .c create line [X $q] [Y 0] [X $q] [Y 1] -tags grid
            .c create line [X 0] [Y $q] [X 1] [Y $q] -tags grid
            set tt [format %.1f $q]
            .c create text [X $q] [Y 0] -anchor s  -text $tt -tags grid
            .c create text [X 0] [Y $q] -anchor sw -text $tt -tags grid
        }
    }
}

proc togglewind {} {
    set cc [.c coords downdraft]
    set x [expr -[lindex $cc 0]]
    set y [expr -[lindex $cc 1]]
    .c coords downdraft $x $y
}

#-----------------------------------------------------------------------
# 
#-----------------------------------------------------------------------

foreach f [glob img/*.gif] {
    image create photo [file rootname [file tail $f]] -file $f
}

frame .t
pack .t
foreach tt {pval ival dval gravity wind mass velocity} {
    frame .t.$tt
    label .t.$tt.l -text $tt
    entry .t.$tt.e -textvariable $tt
    pack .t.$tt
    pack .t.$tt.l
    pack .t.$tt.e
}

canvas .c -width $screenwd -height $screenht
pack .c
focus .c

bind .c <g> {togglegrid}
bind .c <w> {togglewind}
bind .c <m> {togglemotion}
bind .c <q> {exit}
bind .c <KeyPress-Left> {showtext -1}
bind .c <KeyPress-Right> {showtext 1}

togglegrid

#-----------------------------------------------------------------------
# text stuff
#-----------------------------------------------------------------------

set texts [split [read [open pidp.txt]] >]
set textix 0
font create myfont -family Helvetica -size 30
.c create text [X .07] [Y .68] -tags text0 -anchor nw -font myfont

proc showtext {n} {
    global texts textix
    set textix [expr ($textix+$n)%[llength $texts]]
    set ss [string trim [lindex $texts $textix] "\n"]
    .c delete txtpic
    if {[string match "img*" $ss]} {
        set pp [lindex $ss 1]
        .c itemconfigure text0 -text ""
        .c create image 100 300 -anchor w -tags txtpic -image $pp
    } else {
        .c itemconfigure text0 -text [string trim [lindex $texts $textix] "\n"]
    }
}
showtext 0


#-----------------------------------------------------------------------
# images
#-----------------------------------------------------------------------

set groundht 0.08
set targht   0.39
set targetalt 100
set groundalt 0
set ddht     0.6
set txtoff   0.01
#set pixelsperft [expr (double($targetalt)-$groundalt)/ \
#                       ([X $targht]-[X $groundht])]

set simleft 0.5
set coptercenter  0.88

.c create image [X $simleft] [Y $targht] -anchor w -image target-line
.c create image [X $simleft] [Y $groundht] -anchor w -image ground-line
.c create image [X $coptercenter] [Y $ddht] -tags downdraft -image downdraft

.c create text [X $simleft] [Y [expr $targht+$txtoff]] \
         -text "target altitude=100" -anchor sw
.c create text [X $simleft] [Y [expr $groundht+$txtoff]] \
         -text "ground, altitude=0" -anchor sw

.c create image [X $coptercenter] [Y $groundht] -tags copter -anchor s -image copter
.c create text [X [expr $coptercenter]] [Y $groundht] -tags copteralt -anchor sw -text 99

#.c create text [X $coptercenter] [Y $groundht] -text (groundht) -anchor s
#.c create text [X $coptercenter] [Y $targht] -text (targht) -anchor n

proc scale {a0 a1 b0 b1 ax} {
    set da1 [expr double($a1)-$a0]
    set dax [expr double($ax)-$a0]
    set db [expr double($b1)-$b0]
    set pct [expr double($dax) / $da1]

    set scaled0 [expr double($pct)*$db]
    set scaled1 [expr double($b0)+$scaled0]

    return $scaled1
}

proc scr2alt {y} {
    global groundht targht groundalt targetalt pixelsperft screenht
    set rr [scale [X $groundht] [Y $targht] 0 100 [expr $screenht-$y]]
    return $rr
}

proc domove {ypos} {
    global coptercenter
    .c coords copter [X $coptercenter] $ypos
    .c coords copteralt [X [expr .04+$coptercenter]] [expr $ypos-0]
    set alt [expr int([scr2alt $ypos])]
    set err [expr 100-$alt]
    .c itemconfigure copteralt -text alt=$alt\nerr=$err
}

domove [X $groundht]

set mtog 0
proc togglemotion {} {
    if {$::mtog} {
        set ::mtog 0
        bind .c <Motion> {}
    } else {
        set ::mtog 1
        bind .c <Motion> {domove %y}
    }
}

#.c create text [X .05] [Y .05] -text asdf -tags dbgpos
#bind .c <Motion> {.c itemconfigure dbgpos -text [format %%d,%%d  %x %y]}
