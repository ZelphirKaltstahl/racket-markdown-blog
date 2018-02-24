# README

## Implementation advice

* If a programming language's code inside a rendered blog post is not highlighted correctly, check known languages in the code highlighting code. There is a list of "known languages" inside the code in `blog/code-highlighting.rkt`.

## Adding new posts

* Posts consist of standard markdown files and a metadata files.
* The metadata file and the markdown file for a post have the same name but different file ending.
* These files go into the folder `blog/data/posts`.
* The metadata file is a YAML file.

### Example metadata file

A metadata file `document-your-stuff.meta` could look like the following example:

``` yaml
id: 2
title: "Document your stuff"
creation-date: "2017-11-19"
author: "anonymous"
tags: [
  "documentation",
  "software-development",
  "best-practices"
  ]
```

### Example markdown file

An example markdown file `document-your-stuff.md` could look like the following example:

``` markdown
# I have a title

I got some fancy text as well!
```

## Future improvements

* Currently a lot of stuff is configured in code using optional or keyword arguments. In the future I plan to enable users to change how their blog is rendered using a configuration file which is read by the blog application.
* Some kind of navigation would be cool. Maybe something fancy like a word cloud based on existing blog entries or maybe simply some list of links to tags somewhere or clickable dates which filter posts.

### To do

* Read the existing config file and use its values in the code for the optional keyword arguments.
* add known languages to the configuration file
