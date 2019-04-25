library(rpart)
library(plotly)
library(data.table)

fit <- rpart(Species~Sepal.Length +Sepal.Width,
             method="class", data=iris)

printcp(fit)
plot(fit, uniform=TRUE, 
     main="Classification Tree for IRIS")
text(fit, use.n=TRUE, all=TRUE, cex=.8)
fit


treeFrame=fit$frame
isLeave <- treeFrame$var == "<leaf>"
nodes <- rep(NA, length(isLeave))
ylevel <- attr(fit, "ylevels")
nodes[isLeave] <- ylevel[treeFrame$yval][isLeave]
nodes[!isLeave] <- labels(fit)[-1][!isLeave[-length(isLeave)]]

library(rpart.utils)
treeFrame=fit$frame
treeRules=rpart.utils::rpart.rules(fit)

targetPaths=sapply(as.numeric(row.names(treeFrame)),function(x)  
  strsplit(unlist(treeRules[x]),split=","))

lastStop=  sapply(1:length(targetPaths),function(x) targetPaths[[x]] 
                  [length(targetPaths[[x]])])

oneBefore=  sapply(1:length(targetPaths),function(x) targetPaths[[x]] 
                   [length(targetPaths[[x]])-1])


target=c()
source=c()
values=treeFrame$n
for(i in 2:length(oneBefore))
{
  tmpNode=oneBefore[[i]]
  q=which(lastStop==tmpNode)
  
  q=ifelse(length(q)==0,1,q)
  source=c(source,q)
  target=c(target,i)
  
}
source=source-1
target=target-1

p <- plot_ly(
  type = "sankey",
  orientation = "h",
  
  node = list(
    label = nodes,
    pad = 15,
    thickness = 20,
    line = list(
      color = "black",
      width = 0.5
    )
  ),
  
  link = list(
    source = source,
    target = target,
    value=values[-1]
    
  )
) %>% 
  layout(
    title = "Basic Sankey Diagram",
    font = list(
      size = 10
    )
  )


p

htmlwidgets::saveWidget(as_widget(p), "rpart_sankey.html")
