#!/bin/bash

make clean
make html
make pdf
cp pdf.output/csbu.pdf ./html.output
rsync -avz --delete ./html.output/ basie.netux.com.au:/var/www/bottomupcs

