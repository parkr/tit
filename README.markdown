tit
===

a rather spiteful stupid fucking twitter client for you and your stupid fucking
friends

install
-------

    $ (sudo) gem install tit

usage
-----

### authz ###

first, you need to authenticate yourself with the stupid fucking twitter oauth
stuff

to do this, just run tit by itself

    $ tit

it'll prompt you with the auth url, so plug that in your fucking browser, click
"ok", and twitter will give you a stupid fucking pin number

    $ tit --pin 8675309

now you're done and your goddamn access token should be stored for a real
fucking long time

### looking at tits ###

get the shit you'd see by visiting twitter's fucking homepage:

    $ tit

annoyingly poll twitter and add some stupid fucking notifications too:

    $ tit -P -n

there's some more fucking options for you if you look at `tit -h`

### showing other people your tits ###

    $ tit "look at my stupid fucking tweet" -G 88.918:-34.879

dependencies
------------

[oauth][] and [nokogiri][]

[oauth]: http://oauth.rubyforge.org/
[nokogiri]: http://nokogiri.org/

caveats
-------

geotags are of the form `LAT:LONG`, where `LAT` and `LONG` are floating point
numbers, indicating, respectively, the number of degrees north or east of the
fucking center of the earth; make them negative if you live on one or both of
the dark hemispheres

bugs
----

yeah probably; some of the code is super fucking confusing so you might have
trouble fixing them but it doesn't do much so I don't think there are many
issues
