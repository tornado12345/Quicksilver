#!/usr/bin/env python
# -*- encoding: utf-8 -*-
# Quick directory index creator for cheap maven repositories by Darien Hager
# Inspired by the bash script from http://chkal.blogspot.com/2010/09/maven-repositories-on-github.html

from string import Template
from time import strftime,localtime
import os, sys
import re
from commands import getoutput

# The magic token is used to guard against accidents. This script will not overwrite files that do not contain it.
# The token must not be split over two lines.
INDEX_FNAME = "index.html"
MAGIC_TOKEN = "718CD4AFDDF4F6E6E1A9986267B5FEC62DD27FE8A263E236D3351E3E846CBDE2"

SELF_PATH = os.path.abspath(sys.argv[0])

# Taken from http://stackoverflow.com/questions/1094841/reusable-library-to-get-human-readable-version-of-file-size
def formatSize(bytes):
    for x in ['bytes','KB','MB','GB','TB']:
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
                    <td><a href="$link">$name</a> <span style="font-size:80%">(Uploaded: $upload)</span></td>
                    <td>$size</td>
                </tr>
    """)

    rowFragment = ""
    
    filenameRegex = re.compile(r'Quicksilver[_\s]{1}[Bb]?([0-9]{2})\.([a-zA-Z]{3})')
    files.sort(key=lambda x: re.search(filenameRegex,x).group(1),reverse=True)
    for f in files:
        bname = os.path.basename(f).decode('utf-8')
        parts = re.search(filenameRegex,bname)
        # We could perhaps mount the DMG to get the architecture?
        # arch_details = getoutput('file "%s"' % f)
        rowFragment += rowTemplate.substitute(
            name=u''.join([u'Quicksilver ß',parts.group(1),u' (',parts.group(2),u')']).encode('utf-8'),
            link="./"+f.replace(u' ',u'%20').encode('utf-8'),
            upload = strftime("%d %b %Y",localtime(os.path.getmtime(f))),
            # architcture details
            # arch = (u'64/32bit' if 'Mach-0 64-bit bundle x86_64' in arch_details else u'32 bit').encode('utf-8'),
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
        print "wrote to " + target
        fh = open(target,"w")
        fh.write(html)
        fh.close()
    else:
        print "Cautiously refusing to overwrite "+target