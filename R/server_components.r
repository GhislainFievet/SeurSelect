visPlot <- function(seurat.object, reduction, metadata) {
    
    df_2plot <- as.data.frame(seurat.object@reductions[[reduction]]@cell.embeddings)

    c_cell_list <- tail(rownames(df_2plot), 1000)

    names(df_2plot)[1] <- 'x.seurselect'
    names(df_2plot)[2] <- 'y.seurselect'
    c_new_order <- sample(1:nrow(df_2plot))
    df_2plot <- df_2plot[c_new_order, ]
    c_colors <- seurat.object@meta.data[[metadata]][c_new_order]

    c_alpha <- unlist(lapply(rownames(df_2plot), function(x) if (x %in% c_cell_list){1} else {0.01}))

    ggplot2::ggplot(df_2plot, ggplot2::aes(x = x.seurselect, y = y.seurselect, color=c_colors)) + ggplot2::geom_point(alpha=c_alpha) + theme_bw()
}
                             
dataModal <- function() {
      shiny::modalDialog(
        shiny::textInput("selection.name", "Choose a name for your selection"),
        shiny::textInput("selection.description", "Short description of the selection"),

        footer = tagList(
          shiny::modalButton("Cancel"),
          shiny::actionButton("save.selection.form.submit", "OK")
        )
      )
}
                             
editModal <- function() {
      shiny::modalDialog(
        shiny::textInput("edit.name", "Choose a name for your selection"),
        shiny::textInput("edit.description", "Short description of the selection"),

        footer = tagList(
          shiny::modalButton("edit.cancel"),
          shiny::actionButton("edit.form.submit", "save modifications")
        )
      )
}