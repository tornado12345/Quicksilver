#!/bin/python
# Quick directory index creator for cheap maven repositories by Darien Hager
# Inspired by the bash script from http://chkal.blogspot.com/2010/09/maven-repositories-on-github.html

from string import Template
from time import strftime
import os, sys

# The magic token is used to guard against accidents. This script will not overwrite files that do not contain it.
# The token must not be split over two lines.
INDEX_FNAME = "index.html"
MAGIC_TOKEN = "718CD4AFDDF4F6E6E1A9986267B5FEC62DD27FE8A263E236D3351E3E846CBDE2"

SELF_PATH = os.path.abspath(sys.argv[0])

# Taken from http://stackoverflow.com/questions/1094841/reusable-library-to-get-human-readable-version-of-file-size
def formatSize(bytes):
    for x in ['b','k','m','g','t']:
        if bytes < 1024.0:
            if x != 'b':
                return "%3.1f%s" % (bytes, x)
            else:
                return "%3.0f%s" % (bytes, x)
        bytes /= 1024.0

def buildListing(dirs,files,label):

    pageTemplate = Template("""
    <!DOCTYPE html>
    <html>

      <head>
        <meta charset='utf-8' />
        <meta http-equiv="X-UA-Compatible" content="chrome=1" />
        <meta name="description" content="Quicksilver : Quicksilver Mac OS X Project Source" />

        <link rel="stylesheet" type="text/css" media="screen" href="stylesheets/stylesheet.css">

        <title>Quicksilver</title>
        <!-- Anti-overwrite token $tok -->
      </head>

      <body>

        <!-- HEADER -->
        <div id="header_wrap" class="outer">
            <header class="inner">
              <a id="forkme_banner" href="https://github.com/quicksilver/Quicksilver">View on GitHub</a>

              <h1 id="project_title">Quicksilver</h1>
              <h2 id="project_tagline">Quicksilver Mac OS X Project Source</h2>

                <section id="downloads">
                  <a class="zip_download_link" href="https://github.com/quicksilver/Quicksilver/zipball/master">Download this project as a .zip file</a>
                  <a class="tar_download_link" href="https://github.com/quicksilver/Quicksilver/tarball/master">Download this project as a tar.gz file</a>
                </section>
            </header>
        </div>

        <!-- MAIN CONTENT -->
        <div id="main_content_wrap" class="outer">
          <section id="main_content" class="inner">
            <h3>Quicksilver Downloads</h3>
    <table style="width:100%">
        <tr>
            <th>Name</th>
            <th>Size</th>
        </tr>
        $rowdata
    </table>
    <!-- FOOTER  -->
    <div id="footer_wrap" class="outer">
      <footer class="inner">
        <p class="copyright">Quicksilver maintained by <a href="https://github.com/quicksilver">quicksilver</a></p>
        <p>Published with <a href="http://pages.github.com">GitHub Pages</a></p>
      </footer>
    </div>

    

  </body>
</html>
    """)

    rowTemplate = Template("""
                <tr>
                    <td><a href="$link">$name</a></td>
                    <td>$size</td>
                </tr>
    """)

    rowFragment = ""
    for d in dirs:
        bname = os.path.basename(d)
        rowFragment += rowTemplate.substitute(
            icon="[DIR]",
            name=bname + "/",
            link="./"+bname+"/index.html",
            size=""
        )
    for f in files:
        bname = os.path.basename(f)
        rowFragment += rowTemplate.substitute(
            icon="[FILE]",
            name=bname,
            link="./"+bname,
            size=formatSize(os.path.getsize(f))
        )        
    html = pageTemplate.substitute(
        tok=MAGIC_TOKEN,
        label=label,
        time=strftime("%Y-%m-%d %H:%M:%S"),
        rowdata=rowFragment
        )
    
    return html


def listdir(d):    
    items = os.listdir(d)
    dirs = []
    files = []
    items.sort()
    for i in items:
        if i.startswith("."): continue # Ignore current/parent/hidden dirs
        if i == "index.html" : continue # Ignore indexes        
        path = os.path.join(d,i)
        if os.path.abspath(path) == SELF_PATH: continue # Don't index self
        if os.path.isdir(path):
            dirs.append(path)
        elif os.path.isfile(path):
            files.append(path)

    return (dirs,files)


if __name__ == "__main__":
    
    rootPath = os.getcwd()
            
    toVisit = [rootPath]
    dryRun = True;

    downloadsDir = 'downloads'
    label = os.path.relpath(downloadsDir,rootPath)
    target = os.path.join(rootPath,"index.html")
    (directories,files) = listdir(downloadsDir)
    html = buildListing(directories,files,label)

    doWrite = True;
    if os.path.isfile(target):
        # Check anti-accident protection
        doWrite = False;
        fh = open(target,"r")
        for line in fh:
            if line.find(MAGIC_TOKEN) >=0 :
                doWrite = True;
                break;
        fh.close()
                
    if(doWrite):
        print target
        fh = open(target,"w")
        fh.write(html)
        fh.close()
    else:
        print "Cautiously refusing to overwrite "+target