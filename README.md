# SeurSelect

![presentation view](https://raw.githubusercontent.com/GhislainFievet/SeurSelect/main/im/main_panel.png)

## Discover a demo on shinyapp.io
[Demo](https://gfievetinserm.shinyapps.io/seurselect/)

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

You need a **Seurat object**, let's say ```pbmc```. To run the app execute:
```R
my.selections = SeurSelect(pmbc)
```
On application exit, cell selections are stored in ```my.selections``` variable.

## Use example
In this example we show how to select and export points from the Seurat VlnPlot.
1. Click **create a selection**
To create a new selection click on the **create a selection** button.
![create a selection](https://raw.githubusercontent.com/GhislainFievet/SeurSelect/main/im/ss_1.png)
2. Select the **VlnPlot** tab
You can make a selection from 4 different Seurat plots: 
- DimPlot
- FeatureScatter
- VlnPlot
- Featureplot
![Select plot](https://raw.githubusercontent.com/GhislainFievet/SeurSelect/main/im/ss_2.png)
3. Select the **gene** and the **metadata** to display on the plot, and click **OK**
We want to select the CD4+ from the T cell group so we choose **gene = CD4** and **metadata = human_clusters**.
![choose gene and metadata](https://raw.githubusercontent.com/GhislainFievet/SeurSelect/main/im/ss_3.png)
4. Select from the interactive plot
With the **select tool** you can select the cells you want, here the CD4+ from the T cells type. You can see the selected cells on the right plot.
![make the selection](https://raw.githubusercontent.com/GhislainFievet/SeurSelect/main/im/ss_4.png)
5. Click **save selection** to store the list on the table.
Provide a name, a description (optional) and click **OK** to add the selection on the list.
![save selection](https://raw.githubusercontent.com/GhislainFievet/SeurSelect/main/im/ss_5.png)
6. The selection is added to the selection table.
![selection table](https://raw.githubusercontent.com/GhislainFievet/SeurSelect/main/im/ss_6.png)
7. Click on **Back to console** button to exit the application.
On application exit, cells selections are stored in the variable ```my.selections```
![close application](https://raw.githubusercontent.com/GhislainFievet/SeurSelect/main/im/ss_7.png)
