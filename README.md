# README

## Running the blog

### Using plain Racket

For this to work you will need to install Racket and a few Racket packages which are required by the blog application.

* You can get the latest stable distribution of Racket from the [Racket download page](https://download.racket-lang.org/).
* Once Racket and its tooling are installed, you need to install the required packages:
  * `raco pkg install markdown` (for parsing blog posts)
  * `raco pkg install yaml` (for reading metadata from .meta files and reading the blog configuration file)
  * `raco pkg install pollen` (for pygments binding)  `(require pollen/unstable/pygments)`
  * `raco pkg install gregor` (Gregorian calendar)
  * `raco pkg install sha` (for SHA checksum functions which are used for memoization of rendering of blog posts)
* You will also need `pygments` which is used by the blog application to highlight source code in blog posts.
  * install `pygments` for python
    * using Miniconda: `conda install pygments` and using the Miniconda Python environment as the default Python environment or activating it before running the blog
    * using pip: `pip install pygments`

* Once you got all these dependencies set up, you are ready to run the blog application by running `racket server.rkt` inside the `blog` directory.
* Visit your blog at `localhost:8000`.

### Using Docker

You will need to install Docker for this to work. I used the Docker community edition for running the blog application as a Docker container. A guide for installing Docker can be found on [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04).

* Once you have Docker installed, you can build the Docker image for the blog by running `docker build -t blog .` in the `Dockerfile` directory.
* You might want to adapt the `Dockerfile` to your purposes. The `Dockerfile` in this repository is only an example file which shows how to get a Racket application, in this case the blog application, to run inside a Docker container.
* Once you successfully built the Docker image, you can run it for example with `docker run -d --publish 8000:8000 blog`, where `blog` is the name of the Docker image specified when building the image.
* Visit your blog at `localhost:8000`.

The Dockerfile provided in this repository uses Racket 6.11, but can be changed to use another version by changing version string and SHA256 checksum of the Racket installer appropriately. Of course, should the installer change significantly, it is possible that the subsequent steps inside the Dockerfile need to be adapted to a new installation process as well.

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
