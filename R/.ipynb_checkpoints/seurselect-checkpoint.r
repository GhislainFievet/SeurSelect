# library(shiny)
# library(ggplot2)
# library(Cairo)
# library(Seurat)
# library(shinycssloaders)
# library(plotly)
# library(shinyjs)
# library(DT)
# library(tidyverse)


# Init javascript function to hide sel.panel.mode variable
runInitJS <- function() {
    shinyjs::runjs('document.getElementById("sel.panel.mode").parentElement.style.display="none"')
}

ui <- function(seurat.object) {
    shiny::fluidPage(
        shinyjs::useShinyjs(),
        # shiny::includeScript(file.path("js", "script.js")),
        shiny::includeScript(system.file(file.path("js", "script.js"), package = "seurselect")),

        # titlePanel(UITitlePanel()),
        UITitlePanel(),
        shiny::fluidRow(
            shiny::column(
                width = 8,
                shiny::uiOutput("sel.panel"),
            ),
            shiny::column(
                width = 4,
                UIVisPanel(),
                UIListSelection(),
                style = "background-color:rgb(240,240,240)"
            ),
        ),
        UIVisSelection(),
        shiny::conditionalPanel(
            "false", # always hide the download button
            shiny::downloadButton("downloadData")
        )
    )
}

server <- function(input, output, session) {
    runInitJS()

    # updateSelectizeInput(session, "vp.sel.genes", choices = c_genes, server = TRUE)
    # updateSelectizeInput(session, "dp.sel.genes", choices = c_genes, server = TRUE)


    reactSelList <- shiny::reactiveValues(
        df_lists = l_init_selection$df_lists,
        c_cell_selections = l_init_selection$c_cell_selections
    )

    shiny::observeEvent(input$quit.button.1, {
        stopApp(returnValue = list(
            "names" = reactSelList$df_lists[, c("selection", "description", "cell_number")],
            "cells" = reactSelList$c_cell_selections
        ))
    })
    shiny::observeEvent(input$quit.button.2, {
        stopApp(returnValue = list(
            "names" = reactSelList$df_lists[, c("selection", "description", "cell_number")],
            "cells" = reactSelList$c_cell_selections
        ))
    })


    shiny::observeEvent(input$create.sel.button, {
        updateTextInput(session, "sel.panel.mode", value = "creation")
    })

    output$sel.panel <- shiny::renderUI({
        if (input$sel.panel.mode == "main") {
            UIActionPanel()
        } else {
            UISelPanel()
        }
    })

    output$vis.plot <- shiny::renderPlot({
        message("start output$vis.plot")
        shiny::req(input$sel.panel.mode)
        shiny::req(input$vis.red.algo)
        df_2plot <- as.data.frame(seurat.object@reductions[[input$vis.red.algo]]@cell.embeddings)

        c_cell_list <- c()

        if (input$sel.panel.mode == "main") {
            c_cell_list <- reactCellList()

            shinyjs::disable("dp.export.selection")
            shinyjs::disable("dp.save.selection")
            shinyjs::disable("fs.export.selection")
            shinyjs::disable("fs.save.selection")
            shinyjs::disable("vp.export.selection")
            shinyjs::disable("vp.save.selection")
            shinyjs::disable("fp.export.selection")
            shinyjs::disable("fp.save.selection")
        } else {
            click_data <- plotly::event_data("plotly_selected")
            # click_data = NULL
            if (is.null(click_data)) {
                shinyjs::disable("dp.export.selection")
                shinyjs::disable("dp.save.selection")
                shinyjs::disable("fs.export.selection")
                shinyjs::disable("fs.save.selection")
                shinyjs::disable("vp.export.selection")
                shinyjs::disable("vp.save.selection")
                shinyjs::disable("fp.export.selection")
                shinyjs::disable("fp.save.selection")

                message("output$vis.plot: is.null(click_data)")
                c_cell_list <- c()
            } else {
                shinyjs::enable("dp.export.selection")
                shinyjs::enable("dp.save.selection")
                shinyjs::enable("fs.export.selection")
                shinyjs::enable("fs.save.selection")
                shinyjs::enable("vp.export.selection")
                shinyjs::enable("vp.save.selection")
                shinyjs::enable("fp.export.selection")
                shinyjs::enable("fp.save.selection")

                message("output$vis.plot: !is.null(click_data)")
                # curveNumber
                # pointNumber
                # x
                # y
                c_cell_list <- click_data$key
                if (!c_cell_list[1] %in% colnames(seurat.object)) {
                    # if ( can.be.numeric(c_cell_list[1])){
                    c_cell_list <- colnames(seurat.object)[as.numeric(c_cell_list)]
                }
            }
        }

        names(df_2plot)[1] <- "x.seurselect"
        names(df_2plot)[2] <- "y.seurselect"
        c_new_order <- sample(1:nrow(df_2plot))
        df_2plot <- df_2plot[c_new_order, ]
        c_colors <- seurat.object@meta.data[[input$vis.meta.data]][c_new_order]
        alpha_val <- 0.007 * 17000 / nrow(df_2plot)
        c_alpha <- unlist(lapply(rownames(df_2plot), function(x) {
            if (x %in% c_cell_list) {
                1
            } else {
                alpha_val
            }
        }))
        message("end output$vis.plot")

        ggplot2::ggplot(df_2plot, ggplot2::aes(x = x.seurselect, y = y.seurselect, color = c_colors)) +
            ggplot2::geom_point(alpha = c_alpha) +
            ggplot2::theme_bw()
    })

    selDimPlot <- shiny::eventReactive(
        input$dp.sel.support.valid,
        {
            Seurat::DimPlot(seurat.object, group.by = input$dp.sel.meta.data, reduction = input$dp.sel.red.algo) +
                ggplot2::aes(key = colnames(seurat.object))
        }
    )
    selFeatureScatter <- shiny::eventReactive(
        input$fs.sel.support.valid,
        {
            Seurat::FeatureScatter(seurat.object, feature1 = input$fs.sel.genes1, feature2 = input$fs.sel.genes2, group.by = input$fs.sel.meta.data) +
                # aes(key=colnames(seurat.object))
                ggplot2::aes(key = 1:length(colnames(seurat.object)))
        }
    )
    selVlnPlot <- shiny::eventReactive(
        input$vp.sel.support.valid,
        {
            Seurat::VlnPlot(seurat.object, features = input$vp.sel.genes, group.by = input$vp.sel.meta.data) + ggplot2::aes(key = 1:length(colnames(seurat.object)))
        }
    )
    selFeaturePlot <- shiny::eventReactive(
        input$fp.sel.support.valid,
        {
            Seurat::FeaturePlot(seurat.object, features = input$fp.sel.genes, min.cutoff = input$fp.sel.cutoff.slider[1], max.cutoff = input$fp.sel.cutoff.slider[2], reduction = input$fp.sel.red.algo) + ggplot2::aes(key = colnames(seurat.object))
        }
    )


    output$sel.plot <- plotly::renderPlotly({
        myplot <- switch(input$tp.sel.panel,
            "DimPlot" = selDimPlot(),
            "FeatureScatter" = selFeatureScatter(),
            "VlnPlot" = selVlnPlot(),
            "FeaturePlot" = selFeaturePlot()
        )
        # plotly::ggplotly(myplot) %>%
        #   layout(dragmode = "select")

        p <- plotly::layout(plotly::ggplotly(myplot), dragmode = "select")
        plotly::event_register(p, "plotly_selected")
        p

        # plotly::layout(plotly::ggplotly(myplot, source="sel_source"), dragmode = "select")
    })

    ## Handle server side large gene set
    shiny::observeEvent(input$tp.sel.panel, {
        switch(input$tp.sel.panel,
            "DimPlot" = {},
            "FeatureScatter" = {
                shiny::updateSelectizeInput(session, "fs.sel.genes1", choices = c_genes, server = TRUE)
                shiny::updateSelectizeInput(session, "fs.sel.genes2", choices = c_genes, server = TRUE)
            },
            "VlnPlot" = {
                shiny::updateSelectizeInput(session, "vp.sel.genes", choices = c_genes, server = TRUE)
            },
            "FeaturePlot" = shiny::updateSelectizeInput(session, "fp.sel.genes", choices = c_genes, server = TRUE)
        )
    })

    ## returns the data related to data points selected by the user
    output$vis.sel.table <- shiny::renderPrint({
        c_cell_list <- c()

        if (input$sel.panel.mode == "main") {
            c_cell_list <- reactCellList()
        } else {
            click_data <- plotly::event_data("plotly_selected")
            click_data <- NULL
            if (is.null(click_data)) {
                c_cell_list <- c()
            } else {
                c_cell_list <- click_data$key
                if (!c_cell_list[1] %in% colnames(seurat.object)) {
                    c_cell_list <- colnames(seurat.object)[as.numeric(c_cell_list)]
                }
            }
        }
        c_cell_list
    })

    # observeEvent(input$sel.support,{
    #     message("observeEvent(input$sel.support")
    #     updateTabsetPanel(session, "tp.sel.panel", selected=input$sel.support)
    # })

    output$list.sel.table <- DT::renderDT(
        {
            reactSelList$df_lists
        },
        escape = FALSE,
        selection = list(mode = "single", target = "row")
    )

    reactCellList <- shiny::eventReactive(
        input$list.sel.table_rows_selected,
        {
            if (is.null(input$list.sel.table_rows_selected)) {
                message("reactCellList is.null(input$list.sel.table_rows_selected)")
                c()
            } else {
                message("reactCellList !is.null(input$list.sel.table_rows_selected)")
                selection_id <- shiny::isolate(reactSelList$df_lists$selection[input$list.sel.table_rows_selected])
                shiny::isolate(reactSelList$c_cell_selections[[selection_id]])
            }
        },
        ignoreNULL = FALSE
    )

    shiny::observeEvent(input$save.cancel, {
        shiny::updateTextInput(session, "sel.panel.mode", value = "main")
    })

    # Observe save selection
    shiny::observeEvent(input$dp.save.selection, {
        shiny::req(input$dp.save.selection)
        shiny::showModal(dataModal())
    })
    shiny::observeEvent(input$fs.save.selection, {
        shiny::req(input$fs.save.selection)
        shiny::showModal(dataModal())
    })
    shiny::observeEvent(input$vp.save.selection, {
        shiny::req(input$vp.save.selection)
        shiny::showModal(dataModal())
    })
    shiny::observeEvent(input$fp.save.selection, {
        shiny::req(input$fp.save.selection)
        shiny::showModal(dataModal())
    })


    shiny::observeEvent(input$list.sel.table_rows_selected, {
        shiny::req(input$list.sel.table_rows_selected)
        shiny::updateTextInput(session, "sel.panel.mode", value = "main")
        # showModal(modalDialog(
        #   title = "message",
        #   paste("This is a somewhat important message:",
        #         df_lists$selection[input$list.sel.table_rows_selected]),
        #   easyClose = TRUE,
        #   footer = NULL))
    })

    shiny::observeEvent(input$current_id, {
        c_str_split <- unlist(strsplit(input$current_id, "_"))
        action_type <- c_str_split[1]
        action_id <- c_str_split[2]

        shiny::showModal(shiny::modalDialog(
            title = "message",
            str(session),
            easyClose = TRUE,
            footer = NULL
        ))
    })

    shiny::observeEvent(input$in_edit_selection, {
        shiny::showModal(editModal())
        str_title <- reactSelList$df_lists[as.numeric(input$in_edit_selection), "selection"][1]
        str_description <- reactSelList$df_lists[as.numeric(input$in_edit_selection), "description"][1]
        shiny::updateTextInput(session, "edit.name", value = str_title)
        shiny::updateTextInput(session, "edit.description", value = str_description)
    })

    shiny::observeEvent(input$edit.cancel, {
        shiny::removeModal()
    })

    shiny::observeEvent(input$edit.form.submit, {
        reactSelList$df_lists[as.numeric(input$in_edit_selection), "selection"] <- input$edit.name
        reactSelList$df_lists[as.numeric(input$in_edit_selection), "description"] <- input$edit.description
        shiny::removeModal()
    })

    shiny::observeEvent(
        input$save.selection.form.submit,
        {
            if (is.null(input$save.selection.form.submit)) {
                reactSelList$df_lists <- shiny::isolate(reactSelList$df_lists)
                reactSelList$c_cell_selections <- shiny::isolate(reactSelList$c_cell_selections)
            } else {
                c_temp <- plotly::event_data("plotly_selected")$key
                if (!c_temp[1] %in% colnames(seurat.object)) {
                    # if ( can.be.numeric(c_cell_list[1])){
                    c_temp <- colnames(seurat.object)[as.numeric(c_temp)]
                }
                #   showModal(modalDialog(
                # title = "message",
                # paste("This is a somewhat important message:",
                #       c_temp[1]),
                # easyClose = TRUE,
                # footer = NULL))
                i_new_id <- nrow(reactSelList$df_lists) + 1
                reactSelList$c_cell_selections[[input$selection.name]] <- c(c_temp)
                reactSelList$df_lists[i_new_id, ] <- c(
                    input$selection.name,
                    input$selection.description,
                    length(c_temp),
                    # onclick=$('#downloadData')[0].click()
                    paste0(
                        "<button id='iddl_", i_new_id, "' onclick=doDLFile(this.id)><i class='fa fa-download'></i></button> ",
                        "<button id='idedit_", i_new_id, "' onclick=editSelection(this.id)><i class='fa fa-edit'></i></button> ",
                        "<button id='iddel_", i_new_id, "' onclick=removeSelection(this.id)><i class='fa fa-trash'></i></button> "
                    )
                )
                # reactSelList$df_lists <- isolate(reactSelList$df_lists)
                # c_res$c_cell_selections <- isolate(c_cell_selections)
            }
            shiny::removeModal()
        }
    )

    shiny::observeEvent(input$selection_to_remove, {
        str_selection_id <- reactSelList$df_lists$selection[as.numeric(input$selection_to_remove)]

        c_mask <- 1:nrow(reactSelList$df_lists)
        c_mask <- c_mask[c_mask != as.numeric(input$selection_to_remove)]
        reactSelList$df_lists <- reactSelList$df_lists[c_mask, ]


        c_cellselect_mask <- names(reactSelList$c_cell_selections)
        c_cellselect_mask <- c_cellselect_mask[c_cellselect_mask != str_selection_id]

        reactSelList$c_cell_selections <- reactSelList$c_cell_selections[c_cellselect_mask]
    })

    # observeEvent(input$save.selection.form.submit,{
    #     c_sel_ids <- event_data("plotly_selected")$key +
    #     showModal(modalDialog(
    #     title = "message",
    #     paste(input$selection.name, input$selection.description,c_sel_ids[1],c_sel_ids[2],c_sel_ids[3]),
    #     easyClose = TRUE,
    #     footer = NULL))
    # })


    # Download handlers
    output$dp.export.selection <- shiny::downloadHandler(
        filename = function() {
            "selection.txt"
        },
        content = function(file) {
            c_cell_list <- c()
            if (input$sel.panel.mode == "main") {
                c_cell_list <- reactCellList()
            } else {
                click_data <- plotly::event_data("plotly_selected")
                if (is.null(click_data)) {
                    message("dp.export.selection: is.null(click_data)")
                    c_cell_list <- c()
                } else {
                    message("dp.export.selection: !is.null(click_data)")
                    c_cell_list <- click_data$key
                    if (!c_cell_list[1] %in% colnames(seurat.object)) {
                        c_cell_list <- colnames(seurat.object)[as.numeric(c_cell_list)]
                    }
                }
            }
            write.table(c_cell_list, file, sep = "\t", quote = F, row.names = F, col.names = F)
        }
    )
    output$fs.export.selection <- shiny::downloadHandler(
        filename = function() {
            "selection.txt"
        },
        content = function(file) {
            c_cell_list <- c()
            if (input$sel.panel.mode == "main") {
                c_cell_list <- reactCellList()
            } else {
                click_data <- plotly::event_data("plotly_selected")
                if (is.null(click_data)) {
                    c_cell_list <- c()
                } else {
                    c_cell_list <- click_data$key
                    if (!c_cell_list[1] %in% colnames(seurat.object)) {
                        c_cell_list <- colnames(seurat.object)[as.numeric(c_cell_list)]
                    }
                }
            }
            write.table(c_cell_list, file, sep = "\t", quote = F, row.names = F, col.names = F)
        }
    )
    output$vp.export.selection <- shiny::downloadHandler(
        filename = function() {
            "selection.txt"
        },
        content = function(file) {
            c_cell_list <- c()
            if (input$sel.panel.mode == "main") {
                c_cell_list <- reactCellList()
            } else {
                click_data <- plotly::event_data("plotly_selected")
                if (is.null(click_data)) {
                    c_cell_list <- c()
                } else {
                    c_cell_list <- click_data$key
                    if (!c_cell_list[1] %in% colnames(seurat.object)) {
                        c_cell_list <- colnames(seurat.object)[as.numeric(c_cell_list)]
                    }
                }
            }
            write.table(c_cell_list, file, sep = "\t", quote = F, row.names = F, col.names = F)
        }
    )
    output$fp.export.selection <- shiny::downloadHandler(
        filename = function() {
            "selection.txt"
        },
        content = function(file) {
            c_cell_list <- c()
            if (input$sel.panel.mode == "main") {
                c_cell_list <- reactCellList()
            } else {
                click_data <- plotly::event_data("plotly_selected")
                if (is.null(click_data)) {
                    c_cell_list <- c()
                } else {
                    c_cell_list <- click_data$key
                    if (!c_cell_list[1] %in% colnames(seurat.object)) {
                        c_cell_list <- colnames(seurat.object)[as.numeric(c_cell_list)]
                    }
                }
            }
            write.table(c_cell_list, file, sep = "\t", quote = F, row.names = F, col.names = F)
        }
    )

    output$downloadData <- shiny::downloadHandler(
        filename = function() {
            base_name <- reactSelList$df_lists$selection[as.numeric(input$file_to_dl)]
            paste0(base_name, ".tsv")
        },
        content = function(file) {
            base_name <- reactSelList$df_lists$selection[as.numeric(input$file_to_dl)]
            df <- reactSelList$c_cell_selections[[base_name]]
            write.csv(df, file, sep = "\t", quote = F, row.names = F, col.names = F)
        }
    )
}


SeurSelect <- function(arg.seurat.object, l_selections = NULL, assay = NULL) {
    # source("server_components.r", chdir=T)
    # source("ui_components.r", chdir=T)

    if (!is.null(assay)) {
        Seurat::DefaultAssay(object = arg.seurat.object) <- assay
    }
    seurat.object <<- arg.seurat.object

    c_meta_data <<- c()
    for (str_md in names(seurat.object@meta.data)) {
        if (length(unique(seurat.object@meta.data[[str_md]])) < 100) {
            c_meta_data <<- c(c_meta_data, str_md)
        }
    }

    c_reducs <<- rev(names(seurat.object@reductions))
    c_genes <<- unlist(rownames(seurat.object))

    if (is.null(l_selections)) {
        message("SeurSelect: is.null(l_selections))")
        l_init_selection <<- list(
            df_lists = data.frame(
                selection = c("rand10"),
                description = c("Random selection of 10 cells"),
                cell_number = c(10),
                buts = paste0(
                    "<button id='iddl_", c(1), "' onclick=doDLFile(this.id)><i class='fa fa-download'></i></button>",
                    "<button id='idedit_", c(1), "' onclick=editSelection(this.id)><i class='fa fa-edit'></i></button> ",
                    "<button id='iddel_", c(1), "' onclick=removeSelection(this.id)><i class='fa fa-trash'></i></button> "
                )
            ),
            c_cell_selections = list(rand10 = sample(colnames(seurat.object), 10))
        )
    } else {
        message("SeurSelect: !is.null(l_selections))")
        l_init_selection <<- l_selections
        l_init_selection <<- list(
            df_lists = data.frame(
                selection = l_selections$names$selection,
                description = l_selections$names$description,
                cell_number = l_selections$names$cell_number,
                buts = paste0(
                    "<button id='iddl_", 1:nrow(l_selections$names), "' onclick=doDLFile(this.id)><i class='fa fa-download'></i></button>",
                    "<button id='idedit_", 1:nrow(l_selections$names), "' onclick=editSelection(this.id)><i class='fa fa-edit'></i></button> ",
                    "<button id='iddel_", 1:nrow(l_selections$names), "' onclick=removeSelection(this.id)><i class='fa fa-trash'></i></button> "
                )
            ),
            c_cell_selections = l_selections$cells
        )
    }

    return(shiny::runGadget(ui(seurat.object), server))
}