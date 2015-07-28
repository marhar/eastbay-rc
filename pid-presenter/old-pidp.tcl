#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

proc X {x} {
}

proc Y {y} {
}

#  50 - 200
# 300 - 100
# 550 - 0

set screenht 600
set screenwd 800

set ymin 50    ;# top of sky
set ymax [expr $screenht-$ymin]    ;# ground
set ymid [expr ($ymin+$ymax)/2]

proc screen2alt {ypos} {
    set r [expr 220-double($ypos)/(550-50)*200]
    set r [expr int($r)]
    return $r
}

proc domove {ypos} {
    .c coords copter 700 $ypos
    .c coords copteralt 750 [expr $ypos-0]
    set alt [screen2alt $ypos]
    set err [expr 100-$alt]
    .c itemconfigure copteralt -text alt=$alt\nerr=$err
}

proc togglewind {} {
    set cc [.c coords downdraft]
    set x [expr -[lindex $cc 0]]
    set y [expr -[lindex $cc 1]]
    .c coords downdraft $x $y
}

foreach f [glob img/*.gif] {
    image create photo [file rootname [file tail $f]] -file $f
}

canvas .c -width $screenwd -height $screenht

#.c create line [expr $screenwd/2] $ymid $screenwd $ymid -width 1
#.c create line [expr $screenwd/2] $ymax $screenwd $ymax -width 4

.c create image [expr $screenwd/2] [expr $ymid-10] -anchor w -image target-line
.c create image [expr $screenwd/2] $ymax -anchor w -image ground-line
.c create image 700 100 -tags downdraft -image downdraft

.c create text [expr $screenwd/2] [expr $ymid-15] -text "target altitude=100" -anchor sw
.c create text [expr $screenwd/2] [expr $ymax-10] -text "ground, altitude=0" -anchor sw
#.c create text 100 [expr $screenht-30] -text "Mark Harrison\nhttp://eastbay-rc.com" -anchor sw

.c create image 0 0 -tags copter -anchor s -image copter
.c create text 0 0 -tags copteralt -anchor s -text 99
domove $ymax

#--------------

set texts [split [read [open pidp.txt]] >]

set textix 0
font create myfont -family Helvetica -size 30
.c create text 50 50 -tags text0 -anchor nw -font myfont

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

pack .c
bind .c <w> {togglewind}
bind .c <m> {togglemotion}
bind .c <q> {exit}
bind .c <KeyPress-Left> {showtext -1}
bind .c <KeyPress-Right> {showtext 1}
focus .c
