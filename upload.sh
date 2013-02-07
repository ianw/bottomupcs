#!/bin/bash

make pdf
cp csbu.pdf ./html
rsync -avz --delete ./html/ basie.netux.com.au:/var/www/bottomupcs

