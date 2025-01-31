% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/morph.R
\name{layerTerritory.concave}
\alias{layerTerritory.concave}
\title{layerTerritory.concave layers selected territories using concave hulling}
\usage{
layerTerritory.concave(
  image,
  seedTerritory = NULL,
  layerDepth = NULL,
  concavity = 1,
  length_threshold = 0,
  morphologyFactor = 3,
  captureRadius = 0.2,
  minBar = 10,
  verbose = TRUE
)
}
\arguments{
\item{image}{data.frame - Vesalius formatted data.frame (i.e. barcodes,
x,y,cc,value,cluster, territory)}

\item{seedTerritory}{integer describing which territory should be layered}

\item{layerDepth}{integer describing maximum number of layers}

\item{concavity}{numeric describing concavity of the territory. 1 for highly
detailed structures. At higher values the territory will be considered as
a convex hull.}

\item{length_threshold}{numeric describing the minimum distance between
points to be considered during hulling. High values = simpler shapes}

\item{morphologyFactor}{integer or vector of integers describing growth
and/or shrink extent.}

\item{captureRadius}{numeric - proportion of maximum distance between
barcodes that will be used to pool barcodes together (range 0 - 1).}

\item{minBar}{integer - minimum number of barcodes allowed in each territory}

\item{verbose}{logical - progress message output.}
}
\value{
Returns a Vesalius data.frame with "barcodes","x","y","cc",
"value","tile","cluster","territory" and "layer".
Layer describes the layer to which a barcode belongs.
}
\description{
layerTerritory.concave layers selected territories using concave hulling
}
\details{
To divide a territory into layers, one approach is to use concave
hulling. This approach considers all barcodes locations (only center pixels)
as points on a 2D grid and extracts the "outer" layer of barcodes.

This outer layer is extracted and defined as the first layer of the
territory. The process is applied until no more barcodes can be pooled into
a layer.

It should be noted that due to the geometrical nature of this approach,
sub-territories are isolated prior to concave hulling to ensure that the
hulling is only applied to contiguous barcodes (defined by captureRadius).
}
\examples{
\dontrun{
data(Vesalius)
}
}
