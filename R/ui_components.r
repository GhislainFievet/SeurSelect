UITitlePanel <- function(){
    shiny::fluidRow(
        shiny::column(
            width=8,
            shiny::h1("SeurSelect", align = "center"),
            shiny::textInput("sel.panel.mode", "", value="main")
        ),
        shiny::column(
            width=4,
            shiny::actionButton("quit.button.1","Back to console", icon = shiny::icon("arrow-left", style="margin-right:1em"), align="right"),
            style="display:flex;justify-content:flex-end;margin-top:1em"
        ),
        style="background-color:rgb(240,240,240); style:'margin-top:0'"
    )
}

UIVisPanel = function(){
    list(
        shiny::fluidRow(
            # column(
            #     width = 3,
            #     selectInput("vis.assays","Assays",names(seurat.object@assays))
            # ),
            shiny::column(
                width = 4,
                shiny::selectInput("vis.red.algo","Dim Reduc Algo ",c_reducs)
            ),
            shiny::column(
                width = 4,
                shiny::selectInput("vis.meta.data","Metadata",c_meta_data)
            )
        ),
        shinycssloaders::withSpinner(shiny::plotOutput("vis.plot"))
    )
}

UISelPanel = function(){ 
    list(
        shiny::fluidRow(
            shiny::column(
                width = 6,
                shiny::h2("Selection")
            ),
        ),
        shiny::tabsetPanel(
            id="tp.sel.panel",
            shiny::tabPanel(
                "DimPlot",
                "",
                shiny::fluidRow(                    
                    shiny::column(
                        width = 2,
                        shiny::selectInput("dp.sel.red.algo","Dim Reduc Algo ", c_reducs)
                    ),
                    shiny::column(
                        width = 2,
                        shiny::selectInput("dp.sel.meta.data","Metadata", c_meta_data)
                    ),
                    shiny::column(
                        width = 1,
                        shiny::actionButton("dp.sel.support.valid","OK"),
                        style="display:flex;align-items:center"
                    ),
                    shiny::column(
                        width = 5,
                        shiny::downloadButton("dp.export.selection","export current selection"),
                        style="display:flex;align-items:center; flex-direction: row-reverse;"
                    ),
                    shiny::column(
                        width = 2,
                        shiny::actionButton("dp.save.selection","save selection", icon=shiny::icon("save"), style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                        style="display:flex;align-items:center"
                    ),
                    style="display:flex"
                )
            ),
            shiny::tabPanel(
                "FeatureScatter",
                "",
                shiny::fluidRow(
                    shiny::column(
                        width = 2,
                        shiny::selectInput("fs.sel.meta.data","Metadata", c_meta_data)
                    ),
                    shiny::column(
                        width = 2,
                        shiny::selectizeInput("fs.sel.genes1", "Gene1", choices = NULL, options = list(placeholder = 'Select gene 1')),
                        # selectInput("fs.sel.genes1","Gene 1", c_genes)
                    ),
                    shiny::column(
                        width = 2,
                        shiny::selectizeInput("fs.sel.genes2", "Gene2", choices = NULL, options = list(placeholder = 'Select gene 2')),
                        # selectInput("fs.sel.genes2","Gene 2", c_genes)
                    ),
                    shiny::column(
                        width = 1,
                        shiny::actionButton("fs.sel.support.valid","OK"),
                        style="display:flex;align-items:center"
                    ),
                    shiny::column(
                        width = 3,
                        shiny::downloadButton("fs.export.selection","export current selection"),
                        style="display:flex;align-items:center; flex-direction: row-reverse;"
                    ),
                    shiny::column(
                        width = 2,
                        shiny::actionButton("fs.save.selection","save selection", icon=shiny::icon("save"), style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                        style="display:flex;align-items:center"
                    ),
                    style="display:flex"
                )
            ),
            shiny::tabPanel(
                "VlnPlot",
                "",
                shiny::fluidRow(
                    shiny::column(
                        width = 2,
                        shiny::selectizeInput("vp.sel.genes", "Gene", choices = NULL, options = list(placeholder = 'Select a gene')),
                        # selectizeInput("vp.sel.genes", "Gene", choices = NULL)
                        # selectInput("vp.sel.genes","Gene", c_genes)
                    ),
                    shiny::column(
                        width = 1,
                        shiny::actionButton("vp.sel.support.valid","OK"),
                        style="display:flex;align-items:center"
                    ),
                    shiny::column(
                        width = 7,
                        shiny::downloadButton("vp.export.selection","export current selection"),
                        style="display:flex;align-items:center; flex-direction: row-reverse;"
                    ),
                    shiny::column(
                        width = 2,
                        shiny::actionButton("vp.save.selection","save selection", icon=shiny::icon("save"), style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                        style="display:flex;align-items:center"
                    ),
                    style="display:flex"
                )
            ),
            shiny::tabPanel(
                "FeaturePlot",
                "",
                shiny::fluidRow(
                    shiny::column(
                        width = 2,
                        shiny::selectInput("fp.sel.red.algo","Dim Reduc Algo ", c_reducs)
                    ),
                    shiny::column(
                        width = 2,
                        shiny::selectizeInput("fp.sel.genes", "Gene", choices = NULL, options = list(placeholder = 'Select a gene'))
                        # selectInput("fp.sel.genes","Gene", c_genes)
                    ),
                     shiny::column(4,
  
                      # Copy the line below to make a slider range 
                      shiny::sliderInput("fp.sel.cutoff.slider", label = "Cutoff", min = -1, 
                        max = 5, value = c(0, 4))
                    ),
                    shiny::column(
                        width = 1,
                        shiny::actionButton("fp.sel.support.valid","OK"),
                        style="display:flex;align-items:center"
                    ),
                    shiny::column(
                        width = 3,
                        shiny::downloadButton("fp.export.selection","export current selection"),
                        style="display:flex;align-items:center; flex-direction: row-reverse;"
                    ),
                    shiny::column(
                        width = 2,
                        shiny::actionButton("fp.save.selection","save selection", icon=shiny::icon("save"), style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                        style="display:flex;align-items:center"
                    ),
                    style="display:flex"
                )
            )
        ),
        shinycssloaders::withSpinner(plotly::plotlyOutput("sel.plot", width = "100%", height="100%"))
    )
}

UIVisSelection <- function(){ 
    list(
        shiny::h2("Cells"),
        shiny::verbatimTextOutput('vis.sel.table')
        # dataTableOutput('vis.sel.table')
        # verbatimTextOutput("click"),
    )
}

UIListSelection <- function(){ 
    list(
        shiny::h2("Selection list"),
        shiny::div(
        shiny::dataTableOutput('list.sel.table'),id="list.sel.table.parent", style="cursor:pointer")
    )
}

UIActionPanel <- function(){ 
    # list(
    #     h2("What do you want to do?"),
    #     actionButton('create.sel.button', "create a selection"),
    #     actionButton('quit.button.2', "close and go back to console")
    # )
    shiny::tags$div(        shiny::h1("What do you want to do?", style="margin:1em"),
        shiny::actionButton('create.sel.button', "Create a selection", style="margin:2em;padding:1em;color: #fff;font-size: x-large; background-color: #337ab7;"),
        shiny::actionButton('quit.button.2', "Close and go back to console", style="margin:2em;padding:1em;font-size: x-large;"),
            style="display:flex;flex-direction:column;height:500px")
}