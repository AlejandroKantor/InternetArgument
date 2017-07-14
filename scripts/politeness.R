iac.data<-read.csv("data/output/mturkTask1And2.csv",stringsAsFactors = F)
options(java.parameters = "-Xmx16g")
require(rJava)
require(coreNLP)
initCoreNLP("/stanford-corenlp/", mem="16g")

library(ggplot2)
library(qdap)
library(devtools)
install_github("myeomans/DTMtools")

install_github("myeomans/politeness",
               auth_token = "0a3908ff592c886e1e58f7eaa62383828b34004f")

#table(iac.data$nasty_nice,useNA="ifany")

all.text<-iac.data$presented_response
cont.metric<-iac.data$attacking_respectful

######################################################
TriMetric<-cut(cont.metric,quantile(cont.metric,(0:3)/3,na.rm=T), labels=1:3)

in.rows<-which((TriMetric!=2)&(!is.na(TriMetric))&(qdap::word_count(all.text,missing=0)>100)&(qdap::word_count(all.text,missing=0)<1000))

in.rows<-in.rows[1:100]

text.data<-all.text[in.rows]
split.vector<-(TriMetric[in.rows]==3)
######################################################

polite.data<-data.frame(politeness::politeness(text.data,binary=T))

politeness::politenessPlot(polite.data,
                           split.vector,
                           c("Respectful","Attacking"),
                           "Message Style",
                           "Reply Politeness Strategies")
