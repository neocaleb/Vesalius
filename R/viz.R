################################################################################
############################   ST package        ###############################
################################################################################

#' imagePlot - Vesalius image plotting
#' @param image a Vesalius data frame containing at least
#' barcodes, x, y, cc, value
#' @param as.cimg logical - If TRUE, will plot directly using cimg plotting.
#' If FALSE, will produce a ggplot object.
#' @param cex numeric - font and point size resizing factor.
#' @details Vesalius provides basic plotting functions. This function
#' only shows Vesalius images (i.e. using true embedded colours or segmented
#' colours).
#'
#' Currently, we advise to use as.cimg as false for custom plots.
#'
#' As Vesalius nearly always returns data frames, custom plots are left to
#' the discretion of the user.
#' @return cimg plot or ggplot object
#' @examples
#' \dontrun{
#' data(Vesalius)
#' }

imagePlot <- function(image,
                      as.cimg = TRUE,
                      cex=1){
    if(as.cimg){
        plot(as.cimg(image[,c("x","y","cc","value")]))
    } else {
        fgcol <- select(image, c("cc","value"))
        fgcol <- data.frame(fgcol$value[fgcol$cc ==1],
                            fgcol$value[fgcol$cc ==2],
                            fgcol$value[fgcol$cc ==3])
        fgcol <- rgb(fgcol[,1],fgcol[,2],fgcol[,3])
        image <- image %>% filter(cc==1)
        image <- ggplot(image,aes(x,y))+
                     geom_raster(aes(fill=fgcol))+
                     scale_fill_identity()+
                     theme_classic()+
                     theme(axis.text = element_text(size = cex *1.2),
                           axis.title = element_text(size = cex *1.2),
                           plot.tag = element_text(size=cex * 2),
                           plot.title = element_text(size=cex * 1.5)) +
                    labs(title = "Vesalius - Image",
                           x = "X coordinates", y = "Y coordinates")

         return(image)
    }
}




#' territoryPlot plotting Vesalius territories
#' @param territories a Vesalius data frame conatining territory information
#' (i.e. containing the terriotry column)
#' @param split logical - If TRUE, territories will be plotted in
#' separate panels
#' @param randomise logical - If TRUE, colour palette will be randomised.
#' @param cex numeric describing font size multiplier.
#' @param cex.pt numeric describing point size multiplier.
#' @details Territory plots show all territories in false colour after they
#' have been isolated from a Vesalius image.
#' @return a ggplot object
#' @examples
#' \dontrun{
#' data(Vesalius)
#' }

territoryPlot <- function(territories,
                          split = FALSE,
                          randomise = TRUE,
                          cex=1,
                          cex.pt=0.25){
    #--------------------------------------------------------------------------#
    # Dirty ggplot - this is just a quick and dirty plot to show what it look
    # like
    # At the moment - I thinking the user should make their own
    # Not a prority for custom plotting functions
    #--------------------------------------------------------------------------#
    ter <- territories %>% filter(tile==1) %>%
           distinct(barcodes, .keep_all =TRUE)
    #--------------------------------------------------------------------------#
    # Changing label order because factor can suck ass sometimes
    #--------------------------------------------------------------------------#

    sorted_labels <- order(levels(as.factor(ter$territory)))
    sorted_labels[length(sorted_labels)] <- "isolated"
    ter$territory <- factor(ter$territory, levels = sorted_labels)


    #--------------------------------------------------------------------------#
    # My pure hatred for the standard ggplot rainbow colours has forced me
    # to use this palette instead - Sorry Hadely
    #--------------------------------------------------------------------------#
    ter_col <- length(levels(ter$territory))
    ter_pal <- colorRampPalette(brewer.pal(8, "Accent"))

    if(randomise){
        ter_col <- sample(ter_pal(ter_col),ter_col)
    } else {
        ter_col <- ter_pal(ter_col)
    }
    if(split){
        terPlot <- ggplot(ter, aes(x,y,col = territory)) +
               geom_point(size= cex.pt, alpha = 0.65)+
               facet_wrap(~territory)+
               theme_classic() +
               scale_color_manual(values = ter_col)+
               theme(legend.text = element_text(size = cex *1.2),
                     axis.text = element_text(size = cex *1.2),
                     axis.title = element_text(size = cex *1.2),
                     plot.tag = element_text(size=cex * 2),
                     plot.title = element_text(size=cex * 1.5),
                     legend.title = element_text(size=cex * 1.2)) +
               guides(colour = guide_legend(override.aes = list(size=cex * 0.3)))+
               labs(colour = "Territory nr.", title = "Vesalius - Territories",
                     x = "X coordinates", y = "Y coordinates")
    } else {
      terPlot <- ggplot(ter, aes(x,y,col = territory)) +
                 geom_point(size= cex.pt, alpha = 0.65)+
                 theme_classic() +
                 scale_color_manual(values = ter_col)+
                 theme(legend.text = element_text(size = cex *1.2),
                       axis.text = element_text(size = cex *1.2),
                       axis.title = element_text(size = cex *1.2),
                       plot.tag = element_text(size=cex * 2),
                       plot.title = element_text(size=cex * 1.5),
                       legend.title = element_text(size=cex * 1.2)) +
                 guides(colour = guide_legend(override.aes = list(size=cex * 0.3)))+
                 labs(colour = "Territory nr.", title = "Vesalius - Territories",
                                        x = "X coordinates", y = "Y coordinates")
    }

    return(terPlot)
}



# Not in use at the moment
# Might add in futur iterations of the packages
#.cellProportion <- function(image){
#    prop <- FetchData(image,"seurat_clusters") %>% table %>% as.data.frame
#    colnames(prop) <- c("Cell","Cell Proportion")

#    ter_col <- nrow(prop)
#    ter_pal <- colorRampPalette(brewer.pal(8, "Accent"))
#    ter_col <- ter_pal(ter_col)

#    treemap(prop,
#            index="Cell",
#            vSize="Cell Proportion",
#            type="index",
#            palette = ter_col
#            )
#}




#' viewGeneExpression - plot gene expression.
#' @param image a Vesalius data frame containing barcodes, x, y, cc, value,
#' cluster, and territory.
#' @param counts count matrix - either matrix, sparse matrix or seurat object
#' This matrix should contain genes as rownames and cells/barcodes as colnames
#' @param ter integer - Territory ID in which gene expression will be viewed. If
#' NULL, all territories will be selected.
#' @param genes character - gene of interest (only on gene at a time)
#' @param normalise logical - If TRUE, gene expression values will be min/max
#' normalised.
#' @param cex numeric - font size modulator
#' @details Visualization of gene expression in all or in selected territories.
#' Gene expression is shown "as is". This means that if no transformation
#' is applied to the data then normalized raw count will be shown.
#'
#' If normalization and scaling have been applied, normalized counts will be
#' shown.
#'
#' This also applies to any data transformation applied on the count matrix
#' or the Seurat object.
#'
#' We recommend using Seurat Objects.
#'
#' NOTE : You might be promoted to use geom_tiles instead of geom_raster.
#' However - this will increase file size to unreasonable heights.
#' @return a ggplot object (geom_raster)
#' @examples
#' \dontrun{
#' data(Vesalius)
#' }


viewGeneExpression <- function(image,
                               counts,
                               ter = NULL,
                               genes = NULL,
                               normalise = TRUE,
                               cex =10){
    #--------------------------------------------------------------------------#
    # We will assume that you parse the image with all pixel for now
    # if no territory is specified gene expression on all
    # First let's get the territory
    #--------------------------------------------------------------------------#
    if(!is.null(ter)){
      image <- filter(image, territory %in% as.character(ter)) %>%
               select(c("barcodes","x","y"))

    }
    #--------------------------------------------------------------------------#
    # Next lets get the unique barcodes associated to the selected territories
    # Not great but it gets the job done I guess
    #--------------------------------------------------------------------------#
    barcodes <- image %>% distinct(barcodes, .keep_all = FALSE)
    barcodes <- barcodes$barcodes



    #--------------------------------------------------------------------------#
    # Extract counts from the seurat object
    # This will need to be cleaned up later
    #--------------------------------------------------------------------------#

    if(is(counts) == "Seurat"){
        counts <- subset(counts,cells = barcodes)
        counts <- GetAssayData(counts, slot = "data")
    } else {
        counts <- counts[,barcodes]
    }
    type <- "Expression"

    #--------------------------------------------------------------------------#
    # Getting genes - For now it will stay as null
    # I could add multiple gene viz and what not
    # And yes I know it would be better to be consitent between tidyr and base
    #--------------------------------------------------------------------------#
    if(is.null(genes)){
        stop("Please specifiy which gene you would like to visualize")
    } else {
        #----------------------------------------------------------------------#
        # will need some regex here probs
        #----------------------------------------------------------------------#
        inCount <- rownames(counts) == genes
        #----------------------------------------------------------------------#
        # Just in case the gene is not present
        # this should probably be cleaned up
        #----------------------------------------------------------------------#
        if(sum(inCount) == 0){
            warning(paste(genes," is not present in count matrix.
                          Returning NULL"),immediate.=T)
            return(NULL)
        }

        counts <- counts[inCount,]

        counts <- data.frame(names(counts),counts)
        colnames(counts) <-c("barcodes","counts")
        if(normalise){
            counts$counts <- (counts$counts - min(counts$counts)) /
                             (max(counts$counts) - min(counts$counts))
            type <- "Norm. Expression"
        }

    }
    #--------------------------------------------------------------------------#
    # Adding count values to iamge
    #--------------------------------------------------------------------------#
    image <- right_join(image,counts,by = "barcodes")

    ge <- ggplot(image,aes(x,y))+
          geom_raster(aes(fill = counts))+
          scale_fill_gradientn(colors = rev(brewer.pal(11,"Spectral")))+
          theme_classic()+
          theme(axis.text = element_text(size = cex ),
                axis.title = element_text(size = cex),
                legend.title = element_text(size = cex),
                legend.text = element_text(size = cex),
                plot.title = element_text(size=cex)) +
          labs(title = genes,fill = type,
               x = "X coordinates", y = "Y coordinates")
    return(ge)
}


#' viewGeneExpression - plot gene expression in layered Vesalius territories
#' @param image a Vesalius data frame containing barcodes, x, y, cc, value,
#' cluster, and territory.
#' @param counts count matrix - either matrix, sparse matrix or seurat object
#' This matrix should contain genes as rownames and cells/barcodes as colnames
#' @param genes character - gene of interest (only on gene at a time)
#' @param normalise logical - If TRUE, gene expression values will be min/max
#' normalised.
#' @param cex numeric - font size modulator
#' @details Visualization of gene expression a layered territory.
#' After isolation or a territory, Vesalius can apply territory layering. The
#' expression shown here describes the mean expression in each layer.
#'
#' Gene expression is shown "as is". This means that if no transformation
#' is applied to the data then normalized raw count will be used for each layer.
#'
#' If normalization and scaling have been applied, normalized counts will be
#' used for each layer
#'
#' This also applies to any data transformation applied on the count matrix
#' or the Seurat object.
#'
#' We recommend using Seurat Objects.
#'
#' NOTE : You might be promoted to use geom_tiles instead of geom_raster.
#' However - this will increase file size to unreasonable heights.
#'
#' @return a ggplot object (geom_raster)
#' @examples
#' \dontrun{
#' data(Vesalius)
#' }


viewLayerExpression <- function(image,
                                counts,
                                genes = NULL,
                                normalise =TRUE,
                                cex =10){

    #------------------------------------------------------------------------#
    # Next lets get the unique barcodes associated to the selected territories
    # Not great but it gets the job done I guess
    #------------------------------------------------------------------------#
    barcodes <- image %>% distinct(barcodes, .keep_all = FALSE)
    barcodes <- barcodes$barcodes

    #------------------------------------------------------------------------#
    # Extract counts from the seurat object
    # This will need to be cleaned up later
    #------------------------------------------------------------------------#
    counts <- subset(counts,cells = barcodes)
    if(is(counts) == "Seurat"){
        counts <- GetAssayData(counts, slot = "data")
    }


    #--------------------------------------------------------------------------#
    # Getting genes - For now it will stay as null
    # I could add multiple gene viz and what not
    # And yes I know it would be better to be consitent between tidyr and base
    #--------------------------------------------------------------------------#
    if(is.null(genes)){
        stop("Please specifiy which gene you would like to visualize")
    } else {
        #----------------------------------------------------------------------#
        # will need some regex here probs
        #----------------------------------------------------------------------#
        inCount <- rownames(counts) == genes
        #----------------------------------------------------------------------#
        # Just in case the gene is not present
        # this should probably be cleaned up
        #----------------------------------------------------------------------#
        if(sum(inCount) == 0){
            warning(paste(genes," is not present in count matrix.
                          Returning NULL"),immediate.=T)
            return(NULL)
        }

        counts <- counts[inCount,]

        counts <- data.frame(names(counts),counts)
        colnames(counts) <-c("barcodes","counts")


    }
    #--------------------------------------------------------------------------#
    # Adding count values to iamge
    #--------------------------------------------------------------------------#
    image <- right_join(image,counts,by = "barcodes")

    image <- image %>% group_by(layer) %>% mutate(counts = mean(counts))
    #--------------------------------------------------------------------------#
    # Normalising counts in image
    # There might be a cleaner way of doing This
    # Should I norm over all counts?
    #--------------------------------------------------------------------------#

    if(normalise){
        image$counts <- (image$counts - min(image$counts)) /
                         (max(image$counts) - min(image$counts))
    }
    ge <- ggplot(image,aes(x,y))+
          geom_raster(aes(fill = counts))+
          scale_fill_gradientn(colors = rev(brewer.pal(11,"Spectral")))+
          theme_classic()+
          theme(axis.text = element_text(size = cex ),
                axis.title = element_text(size = cex),
                legend.title = element_text(size = cex),
                legend.text = element_text(size = cex),
                plot.title = element_text(size=cex)) +
          labs(title = genes,fill = "Mean Expression",
               x = "X coordinates", y = "Y coordinates")
    return(ge)
}
