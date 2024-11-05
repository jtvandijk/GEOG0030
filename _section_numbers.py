# libraries
# conda env: simple
import pandas as pd
import os
import glob

# placeholder
html_files = []

# get html files
files = glob.glob('docs/*')
for f in files:
    if os.path.basename(f).endswith('.html'):
        html_files.append(f)

# only keep chapters
html_files.remove('docs/index.html')
html_files.sort()

# set counter
cnt = 0

# loop html files: fix headers, fix individual TOC entries
for htmlf in html_files:

    # initialise template
    with open(htmlf) as file:
      html_content = file.read()

    # update headers
    html_content = html_content.replace('<span class="header-section-number">1', \
                                        '<span class="header-section-number">' + str(0 + cnt))

    # update counter
    cnt += 1
    
    # update TOC chapter 1
    html_content = html_content.replace('<span class="menu-text">R for Spatial Analysis</span>', \
                                        '<span class="menu-text">1 R for Spatial Analysis</span>')
                                        
    # update TOC chapter 2
    html_content = html_content.replace('<span class="menu-text">Spatial Queries and Geometric Operations</span>', \
                                        '<span class="menu-text">3 Spatial Queries and Geometric Operations</span>')   

    # update TOC chapter 3
    html_content = html_content.replace('<span class="menu-text">Analysing Point Data</span>', \
                                        '<span class="menu-text">2 Analysing Point Data</span>')   
                                      
    # update TOC chapter 4
    html_content = html_content.replace('<span class="menu-text">Spatial Autocorrelation</span>', \
                                        '<span class="menu-text">4 Spatial Autocorrelation</span>')   
                                       
    # update TOC chapter 5
    html_content = html_content.replace('<span class="menu-text">Spatial Models</span>', \
                                        '<span class="menu-text">5 Spatial Models</span>')   
  
    # update TOC chapter 6
    html_content = html_content.replace('<span class="menu-text">Raster Data Analysis</span>', \
                                        '<span class="menu-text">6 Raster Data Analysis</span>')   

    # update TOC chapter 7
    html_content = html_content.replace('<span class="menu-text">Geodemographic Classification</span>', \
                                        '<span class="menu-text">7 Geodemographic Classification</span>')   

    # update TOC chapter 8
    html_content = html_content.replace('<span class="menu-text">Accessibility Analysis</span>', \
                                        '<span class="menu-text">8 Accessibility Analysis</span>')   

    # update TOC chapter 9
    html_content = html_content.replace('<span class="menu-text">Complex Visualisations</span>', \
                                        '<span class="menu-text">9 Complex Visualisations</span>')   

    # update TOC chapter 10
    html_content = html_content.replace('<span class="menu-text">Beyond the Choropleth</span>', \
                                        '<span class="menu-text">10 Beyond the Choropleth</span>')   
    
    # update TOC chapter 11
    html_content = html_content.replace('<span class="menu-text">Data Sources</span>', \
                                        '<span class="menu-text">11 Data Sources</span>')   

    # write
    with open(htmlf, 'w') as file:
        file.write(html_content)

# fix standard index page redirect
htmlredir = 'docs/index.html'
with open(htmlredir) as file:
    html_content = file.read()

    # update redirect
    html_content = html_content.replace('08-network.html', \
                                        '00-index.html')

    # write
    with open (htmlredir, 'w') as file:
      file.write(html_content)
