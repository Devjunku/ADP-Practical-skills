# ⭕ SVM(Support Vector Machine)

서포트 벡터 머신은 기계학습 분야 중 하나로 패턴인식, 자료분석 등을 위한 지도학습 모델이며 주로 회귀와 분류 문제 해결에 사용됨. SVM은 주어진 데이터 집합을 바탕으로 하여 새로운 데이터가 어떤 범주에 속할 것인지를 판단하는 비확률적 이진 선형 분류 모델을 생성함.   

SVM의 원리는 데이터가 사상된 공간에 초평면을 만듬. 거기서 가장 큰 폭을 갖는 평면을 기준으로 분류를 시작, 데이터의 각 그룹을 구분하는 분류자를 `결정 초평면(decision hyperline)`, 각 그룹에 속한 데이터들 중에서도 초평면에 가장 가까이에 붙어있는 최전방 데이터들을 `서포트 벡터(support vector)`, 서포트 벡터와 초평면 사이의 수직거리를 `마진(margin)`이라고 함.   

즉 SVM은 고차원 혹은 무한 차원의 공간에서 마진(margin)을 최대화하는 초평면을 찾아 분류와 회귀를 수행. 또한 선형 분류 뿐만 아니라 비선형 분류에도 사용할 수 있음. 이때는 다차원 공간상으로 매핑할때 커널 트릭(kernel trick)을 사용하기도 함.   

R에서는 SVM을 위한 패키지가 `e1071`이며 `svm()`함수를 이용하여 분석할 수 있음. 여기서 중요한게 svm 모형에서 최적의 파라미터 값을 찾아내기 위해 `tune.svm()`함수를 사용. `cost`는 과적합을 막는 정도를 지정하는 파라미터, `gamma`는 초평면의 기울기를 의미.   

```R
svm(formula, data, kernel, gamma, cost, ...) # svm을 수행하는 함수
# kernel: 훈련과 예측에 사용되는 커널, radial, linear, polynomial, sigmoid
# gamma: 초평면 기울기, default = 1/(데이터차원)
# cost: 과적합 정도를 막는 정도, default = 1
tune.svm(formula, data, kernel, gamma, cost, ...) # 최적 파라미터를 찾아주는 함수
# 위 svm()함수와 같은 맥락으로 입력하면 됨.
```

Credit Date 모형 구축 시작

```R
library(e1071)
# tune.svm를 활용하여 최적의 파라미터값 찾기
tune.svm(credit.rating~.,
         data = credit,
         gamma = 10^(-6:-1), # 여기서는 6*2개의 모수로 이루어짐
         cost = 10^(1:2))    # 컴퓨터 성능이 좋지 않다면, 연산 시간이 오래걸림
#####
Parameter tuning of ‘svm’:

- sampling method: 10-fold cross validation 

- best parameters:
 gamma cost
  0.01   10

- best performance: 0.233 
#####
svm_model = svm(credit.rating~.,
                data = credit,
                kernel = 'radial',
                gamma = 0.01, # tune.svm에서 사용하여 도출된
                cost = 10)    # gamma, cost를 사용하면 됨
#####
Call:
svm(formula = credit.rating ~ ., data = credit, kernel = "radial", 
    gamma = 0.01, cost = 10)


Parameters:
   SVM-Type:  C-classification 
 SVM-Kernel:  radial 
       cost:  10 

Number of Support Vectors:  558

 ( 301 257 )


Number of Classes:  2 

Levels: 
 0 1
#####
```

tune.svm() 함수로 최적 파라미터를 계산한 결과 gamma는 0.01, cost는 10인 것을 알 수 있고, 이를 svm()의 파라미터에 대입하여 모형을 구축. kernel의 경우 radial(Gaussian RBF)이 default값임. summary()로 support vectors의 수를 확인할 수 있음.

예측 시작

```R
library(caret)
pred_svm = predict(svm_model, test, type = "class")
confusionMatrix(pred_svm, reference = test[,1], positive = '1')
#####
Confusion Matrix and Statistics

          Reference
Prediction   0   1
         0  56  14
         1  39 191
                                          
               Accuracy : 0.8233          
                 95% CI : (0.7754, 0.8648)
    No Information Rate : 0.6833          
    P-Value [Acc > NIR] : 3.033e-08       
                                          
                  Kappa : 0.5608          
                                          
 Mcnemar''s Test P-Value : 0.0009784       
                                          
            Sensitivity : 0.9317          
            Specificity : 0.5895          
         Pos Pred Value : 0.8304          
         Neg Pred Value : 0.8000          
             Prevalence : 0.6833          
         Detection Rate : 0.6367          
   Detection Prevalence : 0.7667          
      Balanced Accuracy : 0.7606          
                                          
       'Positive' Class : 1

#####
```

ROC 커브 그리기

``` R
library(ROCR)
pred_svm_roc = prediction(as.numeric(pred_svm), as.numeric(test[,1]))
plot(performance(pred_svm_roc, 'tpr', 'fpr'))
abline(a = 0, b= 1, lty = 2, col = 'black')
performance(pred_svm_roc, 'auc')@y.values
[[1]]
[1] 0.7605905
```

iris data로 모형 구축 시작

```R
tune.svm(Species~.,
         data = iris,
         gamma = 2^(-1:1),
         cost = 2^(2:4))

svm_model_iris = svm(Species~.,
                     data = train_iris,
                     kernel = 'radial',
                     gamma = 0.5,
                     cost = 16)
summary(svm_model_iris)
#####
Call:
svm(formula = Species ~ ., data = train_iris, kernel = "radial", 
    gamma = 0.5, cost = 16)


Parameters:
   SVM-Type:  C-classification 
 SVM-Kernel:  radial 
       cost:  16 

Number of Support Vectors:  39

 ( 16 9 14 )


Number of Classes:  3 

Levels: 
 setosa versicolor virginica
#####
pred_svm_iris = predict(svm_model_iris, test_iris, type = 'class')
confusionMatrix(pred_svm_iris, reference = test_iris[,'Species'], positive = '1')
#####
Confusion Matrix and Statistics

            Reference
Prediction   setosa versicolor virginica
  setosa         15          0         0
  versicolor      0          9         1
  virginica       0          1        19

Overall Statistics
                                          
               Accuracy : 0.9556          
                 95% CI : (0.8485, 0.9946)
    No Information Rate : 0.4444          
    P-Value [Acc > NIR] : 2.275e-13       
                                          
                  Kappa : 0.9308          
                                          
 Mcnemar''s Test P-Value : NA              

Statistics by Class:

                     Class: setosa Class: versicolor Class: virginica
Sensitivity                 1.0000            0.9000           0.9500
Specificity                 1.0000            0.9714           0.9600
Pos Pred Value              1.0000            0.9000           0.9500
Neg Pred Value              1.0000            0.9714           0.9600
Prevalence                  0.3333            0.2222           0.4444
Detection Rate              0.3333            0.2000           0.4222
Detection Prevalence        0.3333            0.2222           0.4444
Balanced Accuracy           1.0000            0.9357           0.9550
#####
```

# ⭕ 나이브 베이즈 분류(Naive Bayes Classification)

나이브 베이즈 분류!!는 데이터에서 변수들에 대한 조건부 독립을 가정하는 알고리즘으로 클래스에 대한 사전 정보와 데이터로부터 추출된 정보를 결합하고, 베이즈 정리(Bayes Theorem)를 이용하여 어떤 데이터가 특정 클래스에 속하는지 분류하는 알고리즘임.   

텍스트 분류에서 문서를 여러 범주(스팸, 경제, 스포츠 등) 중 하나로 판단하는 문제에 대한 솔루션으로 사용될 수 있음.   

나이브 베이즈 알고리즘의 기본이 되는 개념으로는, 두 확률 변수의 사전 확률과 사후 확률 사이의 관계를 나타내는 정리인 베이즈 정리(Bayes Theorem)이 있음.   

R에서는 `e1071`의 `naiveBayes()`함수를 이용하여 모형을 구축할 수 있음. 이 모형은 분류만 가능함.

```R
naiveBayes(formula, data, laplace = 0, ...) # 나이브베이즈를 수행하는 함수
# laplace 라플라스 보정여부
```

Credit Data로 모형 구축 시작

```R
nb_model = naiveBayes(credit.rating~.,
                      data = train,
                      laplace = 0)
# summary() 함수를 따로 사용안해도 자세히 뜸 summary() 사용하면 결과가 뜨는게 아니라, 해당 리스트의 class를 보여줌
#####
> nb_model
Naive Bayes Classifier for Discrete Predictors

Call:
naiveBayes.default(x = X, y = Y, laplace = laplace)

A-priori probabilities: # 사전 확률
Y
        0         1 
0.2928571 0.7071429 

Conditional probabilities: # 조건부 확률
   account.balance
Y       [,1]      [,2]
  0 1.746341 0.7436323
  1 2.381818 0.7983236

   credit.duration.months
Y       [,1]     [,2]
  0 24.37073 13.31920
  1 18.99192 11.00404

   previous.credit.payment.status
Y       [,1]      [,2]
  0 2.126829 0.6211250
  1 2.375758 0.5728491

   credit.purpose
Y       [,1]      [,2]
  0 3.102439 0.8768504
  1 2.868687 0.9841504
##### 생략
pred_bg_model = predict(nb_model, test, tyep = 'class')
confusionMatrix(pred_bg_model, reference = test[,1], positive = '1')
#####
Confusion Matrix and Statistics

          Reference
Prediction   0   1
         0  65  53
         1  30 152
                                         
               Accuracy : 0.7233         
                 95% CI : (0.669, 0.7732)
    No Information Rate : 0.6833         
    P-Value [Acc > NIR] : 0.07551        
                                         
                  Kappa : 0.3997         
                                         
 Mcnemar''s Test P-Value : 0.01574        
                                         
            Sensitivity : 0.7415         
            Specificity : 0.6842         
         Pos Pred Value : 0.8352         
         Neg Pred Value : 0.5508         
             Prevalence : 0.6833         
         Detection Rate : 0.5067         
   Detection Prevalence : 0.6067         
      Balanced Accuracy : 0.7128         
                                         
       'Positive' Class : 1
#####
##### ROC 커브는 생략 그래도 중요한건 performance(예측돌린 자료, 'auc')@y.values로 꼭 그 너비를 확인해야함.
#####
```

