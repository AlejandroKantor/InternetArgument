require(ggplot2)
require(parallel)
require(qdap)
require(quanteda)
require(devtools)
install_github("myeomans/politeness", force=T,
               auth_token = "0a3908ff592c886e1e58f7eaa62383828b34004f")
require(spacyr)
spacyr::spacy_initialize(python_executable = "/anaconda/bin/python")


iac.data<-read.csv("data/output/mturkTask3.csv",stringsAsFactors = F)

#table(iac.data$nasty_nice,useNA="ifany")

all.text<-iac.data$response_presented_text
cont.metric<-iac.data$attacking_respectful

######################################################
TriMetric<-cut(cont.metric,quantile(cont.metric,(0:5)/5,na.rm=T), labels=1:5)

in.rows.all<-which((TriMetric%in%c(1,5))&(!is.na(TriMetric))&(qdap::word_count(all.text,missing=0)>20)&(qdap::word_count(all.text,missing=0)<200))

#in.rows<-in.rows.all
in.rows<-sample(in.rows.all,2500)

text.data<-all.text[in.rows]
split.vector<-(TriMetric[in.rows]==5)
######################################################

polite.data<-politeness::politeness(text.data,binary=T, parser="spacy")

politeness::politenessPlot(polite.data,
                           split.vector,
                           c("Attacking","Respectful"),
                           "Message Style",
                           "Reply Politeness Strategies")

#spacyr::spacy_finalize()