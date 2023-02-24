# DocBook xslTNG

Build status: [![Build Status](https://circleci.com/gh/docbook/xslTNG.svg?style=shield)](https://circleci.com/gh/docbook/xslTNG.svg?style=shield)

This is *The Next Generation* of DocBook stylesheets in XSLT. It is a
complete reimplementation of the stylesheets for transforming
[DocBook](https://docbook.org/) into modern, clean, semantically rich
HTML. The presentation is supported by CSS and (if you wish, a small amount of) JavaScript.
The expectation for paginated output is to use HTML+CSS.

The project home page is [https://xsltng.docbook.org/](https://xsltng.docbook.org/).
Documentation can be found in the [DocBook xslTNG Reference](https://xsltng.docbook.org/guide/).
The [latest release](https://github.com/docbook/xslTNG/releases) is probably the place to start.

Building the project, if you clone the repository, is described in
[Chapter 5](https://xsltng.docbook.org/guide/ch05.html). In brief, you’ll want to build the XSLT
with `gradle makeXslt` and the jar file (for the extension functions) with `gradle jar`. You can build
the whole distribution with `gradle zipStage` which will put all of the build artifacts in
`build/stage/zip`.
