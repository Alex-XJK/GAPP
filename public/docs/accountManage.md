## Introduction

The PCA result is displayed as a scatterplot with error eclipses with 95% coverage of each cluster. The group info of the samples is represented by diffrent shapes, circle for group 1 and square for group 2. The cluster info is represented by different colors, seperated colors, green for cluster 1 and red for cluster 2.

## Invitation Mechanism

### Coordinate TSV Data 

The first line of the file should be a header that contains column names as keys.

Each row in the file should contain data for a sample.

The data has 3 columns at least, the first column lists sample names in each row, the column key name does not matter.

The rest columns lists values for each attribute. The column key names must be different.

### Group TSV Data

The first line of the file should be a header of the column keys.

The data has 2 columns, sample ID and group ID. The column key name does not matter.

### Cluster TSV Data

The file should not have header.

The data has 2 columns, 1.sample ID, 2.cluster ID.


