couchrest-wiki: because who needs cool names when you use CouchDB?
========================================================

couchrest-wiki is a fork of git-wiki that uses CouchDB to store data
instead of Git. Please see the git-wiki documentation for details.

I (Aslak Hellesøy) ported git-wiki to CouchDB because I wanted to add meta tags 
and a tag cloud to the wiki. This seemed easier to do in a real database
than in Git, which doesn't provide any simple query or view capabilities
needed for this functionality.

## Install

The fellowing [gems][] are required to run git-wiki:

- sinatra
- couchrest
- haml
- git
- BlueCloth
- rubypants

To run tests you need:
- cucumber
- webrat (Built from aslakhellesoy's GitHub clone)
- sinatra (Built from aslakhellesoy's GitHub clone)

Run `ruby couchrest-wiki.rb` and point your browser at <http://0.0.0.0:4567/>. Enjoy!

## Licence
               DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                       Version 2, December 2004

    Copyright (C) 2008 Simon Rozet <simon@rozet.name>
    Everyone is permitted to copy and distribute verbatim or modified
    copies of this license document, and changing it is allowed as long
    as the name is changed.

               DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
      TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

     0. You just DO WHAT THE FUCK YOU WANT TO.
