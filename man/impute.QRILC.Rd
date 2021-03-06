\name{impute.QRILC}
\alias{impute.QRILC}
\title{ Imputation of left-censored missing data using QRILC method. }
\description{ This function implements QRILC, a missing data imputation method that performs the imputation of left-censored missing data using random draws from a truncated distribution with parameters estimated using quantile regression. }
\usage{ impute.QRILC(dataSet.mvs, tune.sigma = 1) }
\arguments{
  \item{dataSet.mvs}{ A data matrix containing left-censored missing data. }
  \item{tune.sigma}{ A scalar used to tune the standard deviation (if the complete data distribution is not Gaussian). The default value is \code{tune.sigma = 1}, and it corresponds to the case where the complete data distribution is Gaussian. }
}
\value{A list including elements:
  \item{dataSet.imputed}{ A complete expression data matrix with missing values imputed. }
  \item{QR.obj}{ A \code{lm} object that contains the results of the QQ regression, denoting the mean and the standard deviation of the complete data distribution. }
}
\references{ QRILC: a quantile regression approach for the
imputation of left-censored missing data in
quantitative proteomics, Cosmin Lazar et al. - to be submitted. }
\author{ Cosmin Lazar }
\seealso{\code{\link{impute.MinDet}}, \code{\link{impute.MinProb}}, \code{\link{impute.ZERO}}}
\examples{

# generate expression data matrix
exprsDataObj = generate.ExpressionData(nSamples1 = 6, nSamples2 = 6,
                          meanSamples = 0, sdSamples = 0.2,
                          nFeatures = 1000, nFeaturesUp = 50, nFeaturesDown = 50,
                          meanDynRange = 20, sdDynRange = 1,
                          meanDiffAbund = 1, sdDiffAbund = 0.2)
exprsData = exprsDataObj[[1]]
  
# insert 15\% missing data with 100\% missing not at random
m.THR = quantile(exprsData, probs = 0.15)
sd.THR = 0.1
MNAR.rate = 100
exprsData.MD.obj = insertMVs(exprsData,m.THR,sd.THR,MNAR.rate)
exprsData.MD = exprsData.MD.obj[[2]]

# perform missing data imputation
obj.QRILC = impute.QRILC(exprsData.MD)
exprsData.imputed = obj.QRILC[[1]]

\dontrun{
hist(exprsData[,1])
hist(exprsData.MD[,1])
hist(exprsData.imputed[,1])
}

## The function is currently defined as
function (dataSet.mvs, tune.sigma = 1) 
{
    nFeatures = dim(dataSet.mvs)[1]
    nSamples = dim(dataSet.mvs)[2]
    dataSet.imputed = dataSet.mvs
    QR.obj = list()
    for (i in 1:nSamples) {
        curr.sample = dataSet.mvs[, i]
        pNAs = length(which(is.na(curr.sample)))/length(curr.sample)
        upper.q = 0.95
        q.normal = qnorm(seq(pNAs, upper.q, (upper.q - pNAs)/(upper.q * 
            10000)), mean = 0, sd = 1)
        q.curr.sample = quantile(curr.sample, probs = seq(0, 
            upper.q, 1e-04), na.rm = T)
        temp.QR = lm(q.curr.sample ~ q.normal)
        QR.obj[[i]] = temp.QR
        mean.CDD = temp.QR$coefficients[1]
        sd.CDD = as.numeric(temp.QR$coefficients[2])
        data.to.imp = rtmvnorm(n = nFeatures, mean = mean.CDD, 
            sigma = sd.CDD * tune.sigma, upper = qnorm(pNAs, 
                mean = mean.CDD, sd = sd.CDD), algorithm = c("gibbs"))
        curr.sample.imputed = curr.sample
        curr.sample.imputed[which(is.na(curr.sample))] = data.to.imp[which(is.na(curr.sample))]
        dataSet.imputed[, i] = curr.sample.imputed
    }
    results = list(dataSet.imputed, QR.obj)
    return(results)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
