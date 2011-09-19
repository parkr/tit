# tit 2.1.5 2011-09-12

* 

# tit 2.1.0 2011-09-10

* got direct messaging working -- requires reauthorization
* notifies user of need to reauthorize the app for dm permissions
* can now handle missing tweet, whereas it was just throwing a Ruby error before

# tit 2.0.4 2011-09-09

* fixes issue with replacing t.co urls, where the ridiculous set of chars at the end remained

# tit 2.0.3 2011-08-31

* print error message regarding no DM permissions
* a couple patches

# tit 2.0.2 2011-08-31

* dm-ing still not working - twitter needs to give us permission
* fixed code for dm-ing when twitter approves it, it'll work

# tit 2.0.1 2011-08-23

* fixed bug with the count

# tit 2.0.0 2011-08-18

* added direct messaging
* fixed a whole slew of bugs

# tit 1.2.5 2011-08-18

* some freaky fixes that i don't remember

# tit 1.2.4 2011-08-18

* gave --count a short tag -c

# tit 1.2.3 2011-08-18

* replace t.co urls with expanded urls.
* fix for options parser

# tit 1.2.2 2011-08-18

* freaking &lt;3 all over the fucking twittersphere - decode that shit

# tit 1.2.1 2011-08-18

 * no longer using "-u" or "--update" for sending a tweet when other options exist - using "-t" or "--tweet"

# tit 1.2.0 2011-08-18

 * ability to get user's timeline
 * tweet without using -u: just `tit 'tweet tweet'`
 * user can now set number of tweets printed when requesting timelines

# tit 1.1.4 2011-08-17

 * moved debug from -d to -D
 * added -v --version switch

# tit 1.1.3 2011-08-15

 * fixed a bug - ftools sucks

# tit 1.1.2 2010-01-26

 * fixed a bug with update times and bad network connections

# tit 1.1.1 2010-01-23

 * fixed displaying yourself

# tit 1.1.0 2010-01-23

 * moved to oauth for chris

# tit 1.0.1 2010-01-22

 * made even more spiteful in a few rather non-clever ways

# tit 1.0.0 2010-01-22

 * can send and receive tits I mean tweets
 * can do polling
 * notifications
 * geotagging (read and write)
 * doesn't yet make twitter not stupid