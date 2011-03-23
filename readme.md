# Phylograph

[Austin G. Davis-Richardson](harekrishna@gmail.com)

## Abstract

Sequences generated from 16s rRNA amplicons can be used to classify or measure the diversity of the organisms in an environmental sample by homology or tree and clustering based methods, respectively.

The goal of this experiment is to attempt to measure differences and similarities between cliques of organisms in environmental samples using a clustering and graph-alignment approach.

In this experiment, 16S rRNA sequences generated by 515F and 806R universal primers will be clustered according to sequence similarity (probably by CD-HIT). Representative sequences will be generated for each cluster and all pairwise alignments between representative sequences will be computed and used to generate a graph.

Nodes in the graph represent OTUs (for example, nodes generated from clustering at 99% sequence similarity would represent individual species). Edges in the graph will represent evolutionary distance between OTUs and will be generated from the pairwise alignment score for the representative sequences for each node.

Graphs generated for two environmental samples can then be aligned using a global network alignment (or local) approach to infer cliques that differ or remain between samples.

The second goal of the experiment would be to construct graphs for different single-copy genes from a single (metagenomic) sample, align them, and return a consensus graph which could possibly be a more robust method of classification than 16S rRNA comparison/numerical taxonomy.

## TODO

 1. Implement a clustering algorithm (DONE, with CD-HIT)
 2. Implement pairwise alignment algorithm
  - Needleman-Wunsch
 3. Implement graph construction algorithm
  - From similarity matrix
 4. Implement graph alignment algorithm

## Project Plan

0. Research
  a. Other similar approaches
  b. Other instances of graph alignment in metagenomics/phylogenomics?
  c. Suitable graph alignment algorithm
  d. Pairwise sequence alignment (probably just needleman-wunsch). It would be nice to find this implemented in C.
  e. Output format: graphical?

1. Need to implement

  a. Clustering algorithm
    - Implement using CD-HIT as it can cluster and generate rep. sequences
    - Possibly implement own approach if needed
    
  b. Graph construction
    - Edge weights = Sequence similarity (N/W edit distance) 
    - Node weight? (could be based on number of sequences that exist in each cluster)
    - How many edges per vertex? Use all or cutoff at some threshold?
    
  c. Graph alignment
    - Local?
    - Global?
    
2. Testing correctness

  a. What defines success in this scenario? Compare against existing methods (such as comparison to a 16S database and finding statistically significant differences based on number of reads, alignment of phylogenetic trees) which have already proven (are widely considered) to be robust.
    
## (Some) Relavent Literature

0. Kuchaiev et al., 2010 Topological network alignment uncovers biological function and phylogeny

a. Weizhong Li and Adam Godzik, Cd-hit: a fast program for clustering and comparing large sets of protein or nucleotide sequences

b. Ruby Graph Library documentation - http://rgl.rubyforge.org/rgl/index.html

c. Clustering 16S rRNA for OTU prediction: a method of unsupervised Bayesian clustering (2011) http://bioinformatics.oxfordjournals.org/content/27/5/611.short

d. A global network of coexisting microbes from environmental and whole-genome sequence data http://genome.cshlp.org/content/20/7/947.full

e. PhylOTU: A High-Throughput Procedure Quantifies Microbial Community Diversity and Resolves Novel Taxa from Metagenomic Data http://www.ploscompbiol.org/article/info%3Adoi%2F10.1371%2Fjournal.pcbi.1001061