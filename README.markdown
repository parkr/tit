tit
===

a stupid fucking twitter client for you and your stupid fucking friends

usage
-----

    $ tit

or

    $ tit -u "look at my stupid fucking tweet" -G 88.918:-34.879

or

    $ tit -P -n

dependencies
------------

[rest-client][] and [nokogiri][]

caveats
-------

geotags are of the form `LAT:LONG`, where `LAT` and `LONG` are floating point
numbers, indicating, respectively, the number of degrees north or east of the
center of the earth; make them negative if you live on one or both of the dark
hemispheres

bugs
----

yeah probably; some of the code is super fucking confusing so you might have
trouble fixing them but it doesn't do much so I don't think there are many
issues
