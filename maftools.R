#!/compile/R/R-3.5.2/bin/Rscript

#https://byteofbio.com/archives/11.html

args <- commandArgs()
scriptPath = strsplit(args[4], '=', fixed = T)[[1]][2]
scriptName = basename(scriptPath)
scriptDir = dirname(scriptPath)
args = args[-(1:5)]
source(paste0(scriptDir, '/common.R'))
library(maftools, quiet = T)

usage = function(){
    cat(paste0("Usage: ", scriptName) )
    cat(" -p=outputName.pdf input.maf[ input2.maf]
Option:
    -p|pdf        PDF   Pdf for figures except for plots specified by the following options[maftools.pdf]
    -w|width      INT   The figure width
    -height       INT   The figure height

    -AAchange     STR   Column name of AAchange (e.g.: Protein_Change, HGVSp_Short)
    -VAF          STR   Column name of VAF (e.g.: i_TumorVAF_WU, t_vaf)

    -pdfOncostrip            PDF  Pdf for oncostrip plot
    -pdfVAF                  PDF  Pdf for VAF plot
    -pdfGeneCloud            PDF  Pdf for gene cloud plot
    -pdfSomaticInteractions  PDF  Pdf for somatic interaction plot
    -pdfDrugInteractions     PDF  Pdf for drug interaction plot
      
    -h|help             Show help
")
    q(save = 'no')
}

myPdf = 'maftools.pdf'
myWidth = 10

for(i in 1:length(args)){
    arg = args[i]
    if(arg == '-h' || arg == '-help') usage()
    tmp = parseArg(arg, 'p(df)?', 'p')
    if(!is.null(tmp)){
        myPdf = tmp
        args[i] = NA
        next
    }
    tmp = parseArgNum(arg, 'w(idth)?', 'w')
    if(!is.null(tmp)){
        myWidth = tmp
        args[i] = NA
        next
    }
    tmp = parseArgNum(arg, 'height', 'height')
    if(!is.null(tmp)){
        height = tmp
        args[i] = NA
        next
    }

    tmp = parseArg(arg, 'AAchange', 'AAchange')
    if(!is.null(tmp)){
        AAchange = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'VAF', 'VAF')
    if(!is.null(tmp)){
        VAF = tmp
        args[i] = NA
        next
    }

    tmp = parseArg(arg, 'pdfOncostrip', 'pdfOncostrip')
    if(!is.null(tmp)){
        pdfOncostrip = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'pdfVAF', 'pdfVAF')
    if(!is.null(tmp)){
        pdfVAF = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'pdfGeneCloud', 'pdfGeneCloud')
    if(!is.null(tmp)){
        pdfGeneCloud = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'pdfSomaticInteractions', 'pdfSomaticInteractions')
    if(!is.null(tmp)){
        pdfSomaticInteractions = tmp
        args[i] = NA
        next
    }
    tmp = parseArg(arg, 'pdfDrugInteractions', 'pdfDrugInteractions')
    if(!is.null(tmp)){
        pdfDrugInteractions = tmp
        args[i] = NA
        next
    }
}
args = args[!is.na(args)]
if(length(args) == 0) stop('Please specify maf file!')

cat(paste0('[DEBUG] ', Sys.time(), ' Check if the following variables are correct as expected:'))
cat('\npdf\t'); cat(myPdf)
cat('\nwidth\t'); if(exists('myWidth')) cat(myWidth)
cat('\nheight\t'); if(exists('height')) cat(height)
cat('\nAAchange\t'); if(exists('AAchange')) cat(AAchange)
cat('\nVAF\t'); if(exists('VAF')) cat(VAF)
cat('\n')

myCmd = 'pdf(myPdf'
if(exists('myWidth')) myCmd = paste0(myCmd, ', width = myWidth')
if(exists('height')) myCmd = paste0(myCmd, ', height = height')
myCmd = paste0(myCmd, ')')
eval(parse(text = myCmd))

cat(paste0('\n\n[INFO] ', Sys.time(), ' Read maf\n'))
maf = read.maf(maf = args[1])

cat(paste0('\n\n[INFO] ', Sys.time(), ' Sample summary\n'))
getSampleSummary(maf)

# Redundant
#cat(paste0('\n\n[INFO] ', Sys.time(), ' Gene summary\n'))
#getGeneSummary(maf)

cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot maf summary\n'))
plotmafSummary(maf = maf)

cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot oncoplot\n'))
plot.new()
oncoplot(maf = maf, top = 10)

cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot TiTv\n'))
titv = titv(maf = maf, useSyn = TRUE)

if(exists('AAchange')){
    cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot lollipop\n'))
    lollipopPlot(maf = maf, gene = 'DNMT3A', AACol = AAchange, showMutationRate = TRUE, labelPos = 'all')

    cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot Oncodrive\n'))
    sig = oncodrive(maf = maf, AACol = AAchange, minMut = 5, pvalMethod = 'zscore')
    head(sig)
    plotOncodrive(res = sig, fdrCutOff = 0.1, useFraction = TRUE)

    #cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot pfam\n'))
    #pfam = pfamDomains(maf = maf, AACol = AAchange, top = 10)
    #pfam$proteinSummary[,1:7, with = FALSE]
    #pfam$domainSummary[,1:3, with = FALSE]
}

#cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot rainfall\n'))
#rainfallPlot(maf = maf, detectChangePoints = TRUE, pointSize = 0.6)

cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot mutation load\n'))
mutload = tcgaCompare(maf = maf, cohortName = 'Your MAF')

if(length(args) > 1){
    maf2 = read.maf(maf = args[2])
    vs = mafCompare(m1 = maf, m2 = maf2, minMut = 5)
    cat(paste0('\n\n[INFO] ', Sys.time(), ' Maf VS\n'))
    print(vs)
    forestPlot(mafCompareRes = vs, pVal = 0.1, color = c('royalblue', 'maroon'), geneFontSize = 0.8)

    genes = vs$results$Hugo_Symbol[0:5]
    cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot CoOnco\n'))
    plot.new()
    coOncoplot(m1 = maf, m2 = maf2, genes = genes, removeNonMutated = TRUE)

    # error
    #if(exists('AAchange')){
    #    cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot lollipop2\n'))
    #    lollipopPlot2(m1 = maf, m2 = maf2, gene = genes[0], AACol1 = AAchange, AACol2 = AAchange)
    #}
}

OP = OncogenicPathways(maf = maf)
cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot oncogenic pathway\n'))
PlotOncogenicPathways(maf = maf, pathways = OP$data$Pathway[1])

if(exists('VAF')){
    cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot cluster\n'))
    het = inferHeterogeneity(maf = maf, tsb = 'TCGA-AB-2802-03B-01W-0728-08', vafCol = VAF)
    print(het$clusterMeans)
    plotClusters(clusters = het)
}
dev.off()


if(exists('pdfOncostrip')){
    pdf(pdfOncostrip)
    cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot oncostrip\n'))
    oncostrip(maf = maf, genes = c('TP53', 'MYC'))
    dev.off()
}

if(exists('pdfVAF') && exists('VAF')){
    pdf(pdfVAF)
    cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot VAF\n'))
    plotVaf(maf = maf, vafCol = VAF)
    dev.off()
}

if(exists('pdfGeneCloud')){
    pdf(pdfGeneCloud)
    cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot genecloud\n'))
    geneCloud(input = maf, minMut = 3)
    dev.off()
}

if(exists('pdfSomaticInteractions')){
    pdf(pdfSomaticInteractions)
    cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot somatic interaction\n'))
    somaticInteractions(maf = maf, top = 25, pvalue = c(0.05, 0.1))
    dev.off()
}

if(exists('pdfDrugInteractions')){
    pdf(pdfDrugInteractions)
    cat(paste0('\n\n[INFO] ', Sys.time(), ' Plot drug interaction\n'))
    dgi = drugInteractions(maf = maf, fontSize = 0.75)
    dev.off()
}
