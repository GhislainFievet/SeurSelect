# SeurSelect

## Discover a demo on shinyapp.io
link_to_app

## Installation
```R
library(devtools)
install_github("GhislainFievet/SeurSelect")
```
and load the library
```R
library(seurselect)
```

## Basic usage

You need a Seurat object, let's say ```pbmc```. To run the app execute:
```R
SeurSelect(pmbc)
```

## Use a defined cell selection
```R
SeurSelect(pmbc, l_selections=l_cells)
```