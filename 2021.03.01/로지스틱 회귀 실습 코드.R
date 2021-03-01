setwd('C:/Users/junkyu/Desktop/DATA ANALYSIS/2021.03.01')
# 확장자명과 파일경로로 데이터를 불러오기 위한 과정이지만
# clipboard를 입력했을 때 딱히 사용하지 않아도 됨.

credit = read.table('clipboard', header=T, sep = '\t') # 데이터 불러오기
str(credit) # 데이터 구조확인

class(credit$credit.rating) # 데이터 class확인

credit$credit.rating = factor(credit$credit.rating) # 종속변수를 factor로 변환
str(credit)


# 데이터 셋 분할, train: 70%, test: 30%
set.seed(123)
idx = sample(1:nrow(credit), nrow(credit)*0.7, replace = F) # 무작위 난수 추출
train = credit[idx,] # train
test = credit[-idx,] # test#

# 로지스틱 회귀분석 실시 glm(formula, data, family = '')
# formula: 분석 모형
# data: 사용할 데이터
# family: 종속변수에게 가정할 분포 이항(binomial, gaussian, gamma, poisson)

logistic = glm(credit.rating~., data = train, family = 'binomial')
summary(logistic) # 유의하지 않은 변수들이 많으므로, step을 이용하여 다시 분석

step_logistic<-step(glm(credit.rating~1, data=train, family="binomial"),
                    scope=list(lower=~1, upper=~account.balance+credit.duration.months+previous.credit.payment.status+
                                 credit.purpose+credit.amount+savings+employment.duration+installment.rate+
                                 marital.status+guarantor+residence.duration+current.assets+age+other.credits+
                                 apartment.type+bank.credits+occupation+dependents+telephone+foreign.worker),
                    direction="both") # direction을 이용하여 단계적 선택법을 지정하였음.

summary(step.logistic) #확인결과 13개의 변수가 선택됨.
# 계수값이 양수이면, 독립변수가 1단위 증가할 때 확률이 1에 가까워지고, 음수이면 독립변수가 1단위 증가할 때 확률 0에 가까워짐.

# 예측을 통한 정분류율 확인
install.packages('caret')
install.packages('e1071')
library(caret)
library(e1071)
pred = predict(step_logistic, test[,-1], type = 'response') # 예측값을 'response'로 지정하여 확률값을 출력 1-1
pred1 = as.data.frame(pred)
pred1$grade = ifelse(pred1$pred < 0.5, pred1$grade <- 0, pred1$grade <- 1) # 1-2
confusionMatrix(data=as.factor(pred1$grade), reference = test[,1], positive = '1') # 1-3


# 구축된 로지스틱 회귀모형으로 test데이터의 기존 credit.rating열을 제외한 데이터로 예측을 한다. 1-1
# 정분류율을 확인하기 전에 예측값이 확률로 나타나기 때문에 기준이 되는 확률보다 크면 1, 작으면 0으로 범주를 주가 1-2
# 정분류율은 0.75 이며 민감도는 0.8878로 높게 계산됨 특이도는 0.4526이다. 정확도가 높은 모형이라 하여 좋은 모형은 아닌 것을 알아야함. 1-3


# ROC 커브 그리기 및 AUC 산출
install.packages('ROCR')
library(ROCR)
pred_logistic_roc = prediction(as.numeric(pred1$grade), as.numeric(test[,1]))
plot(performance(pred_logistic_roc, 'tpr', 'fpr'))
abline(a = 0, b = 1, lty = 2, col = "black")
performance(pred_logistic_roc, 'auc')@y.values

# prediction()와 performance 함수를 값을 구하여 plot 함수로 ROC 커브를 그렸으며, AUC값은 @y.values로 확인한 결과 0.67로 나왔다.

# 예측하고자 하는 분류가 3개 이상이면, 다항 로지스틱 회귀분석을 사용한다. R에서는 nnet패키지의 multinom 등의 함수로 분석한다.
# multinom(formula, data)
# formula : 수식입력
# data : 데이터 입력

# iris 데이터 train, test로 분할 0.7, 0.3
str(iris)
idx = sample(1:nrow(iris), nrow(iris)*0.7, replace = F)
train_iris = iris[idx, ]
test_iris = iris[-idx, ]

library(nnet)
# train 데이터로 다항 로지스틱 회귀분석 실시
mul_iris = multinom(Species~., train_iris) # 종속변수가 factor변수인것을 확인

# 예측을 통한 정분류율 확인
pred_mul = predict(mul_iris, test_iris[,-5]) # 예측 시작
confusionMatrix(pred_mul, test_iris[,5]) # 예측을 분류표로 작성
