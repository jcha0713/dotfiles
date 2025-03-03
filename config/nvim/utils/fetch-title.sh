#!/bin/bash

curl -Ls "$1" | rg -o '<title[^>]*>(.*?)</title>' -r '$1' | head -n 1 | sed '
    s/&nbsp;/ /g;
    s/&amp;/\&/g;
    s/&lt;/\</g;
    s/&gt;/\>/g;
    s/&quot;/\"/g;
    s/#&#39;/\'"'"'/g;
    s/&ldquo;/\"/g;
    s/&rdquo;/\"/g;
'
