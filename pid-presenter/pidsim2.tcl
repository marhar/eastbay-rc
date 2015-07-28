#-----------------------------------------------------------------------
# display variables
#-----------------------------------------------------------------------

set screenht 800
set screenwd [expr $screenht*(3.0/4.0)]

set groundht 0.08
set targht   0.39
set targetalt 100
set groundalt 0
set coptercenter  0.58

#-----------------------------------------------------------------------
# sim variables
#-----------------------------------------------------------------------

set gravity [expr 9.8]		;# gravity (m/sec^2)
set velocity [expr  15.0]	;# meters/sec
set altitude [expr  0.0]	;# meters
set clock ""
set oldclock 0
set fps 0
set fpscounter 0

set delay 1			;# sim step delay (ms)
set tickdiff 0
set movement 0

#-----------------------------------------------------------------------
# display procedures
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
    # busted? reversed?
    global groundht targht groundalt targetalt pixelsperft screenht
    set rr [scale [X $groundht] [Y $targht] 0 100 [expr $screenht-$y]]
    return $rr
}

#-----------------------------------------------------------------------
# gui code
#-----------------------------------------------------------------------

proc dovals {a} {
    puts a=$a
    foreach i $a {
        label .vals.${i}_l -text ${i}:
        label .vals.${i} -textvariable ${i} 
        grid .vals.${i}_l .vals.${i} -sticky w
    }
}

frame .vals
frame .ctls
canvas .c -width $screenwd -height $screenht -background lightblue

grid .vals .ctls .c
dovals {clock altitude velocity gravity delay tickdiff}
grid [label .vals.spacer1 -text --] [label .vals.spacer2 -text ----------------------]
dovals {movement fps}

foreach f [glob img/*.gif] {
    image create photo [file rootname [file tail $f]] -file $f
}

.c create image [X $coptercenter] [Y $groundht] -tags copter -anchor s -image copter

bind . <q> {exit}


proc domove {ypos} {
    global coptercenter
    .c coords copter [X $coptercenter] $ypos
    .c coords copteralt [X [expr .04+$coptercenter]] [expr $ypos-0]
    set alt [expr int([scr2alt $ypos])]
    set err [expr 100-$alt]
    ##.c itemconfigure copteralt -text alt=$alt\nerr=$err
    puts alt=$alt
}

domove [X $groundht]

#-----------------------------------------------------------------------
# sim code
#-----------------------------------------------------------------------

proc simstep {} {
    global delay
    global lasttick
    global tickdiff
    global clock
    global oldclock
    global fps
    global fpscounter
    set tick [clock milliseconds]
    set tickdiff [expr $tick - $lasttick]
    set lasttick $tick

    global altitude
    global velocity
    global gravity

    global movement
    set movement [expr $velocity * ($tickdiff/1000.0)]
    set altitude [expr $altitude + $movement]
    set clock [clock seconds]
    if {$oldclock != $clock} {
        set fps $fpscounter
        set fpscounter 0
        set oldclock $clock
    } else {
        incr fpscounter
    }


    domove $altitude
    after $delay simstep
}
set lasttick [clock milliseconds]
after 0 simstep
