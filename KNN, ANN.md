# ⭕KNN (K-Nearest Neighbor)

#### ❗ 원리

KNN (K-Nearest Neighbor)은 어떤 범주로 나누어져 있는 데이터 셋이 있을 때, 새로운 데이터가 추가된다면 이를 어떤 범주로 분류할 것인지를 결정할 때 사용할 수 있는 분류 알고리즘으로 지도 학습의 한 종류이다.   

정말 간단한 아이디어 인데, `새로운 클래스`를 해당 데이터와 `가장 가까운 k개의 데이터들의 클래스`로 결정하는 것이다. 이때 `가장 가까운 k개`라는 의미는 거리라고 하는 정의에 따라 달라질 수 있다.   

유클리디안, 맨하탄, 민코우스키, 거리 등이 있지만, 대표적으로는 유클리디안 거리를 사용한다고 한다. 공식은 중3 피타고라스를 배운 사람이라면 이해하기 어렵지 않다.

#### ❗ K의 선택

일반적으로 훈련데이터 갯수의 제곱근으로 결정하지만, 데이터의 특성에 따라 달라질 수 있음을 유의하자. 왜냐하면 k를 너무 크게 설정하면 분류하기 어렵고 작게 설정하면 모형이 과적합되기 때문이다.   

R에서는 `class` 패키지의 `knn()`를 통해 knn 모형을 구축할 수 있다.

```R
knn(train, test, cl, k, ...	)
# train: 훈련 데이터
# test: 테스트 데이터
# cl: 훈련데이터의 종속변수
# k: 이웃의 갯수
```

Credit Data로 실습해보자

```R
library(class)
train_data = train[, -1] #knn함수를 쓸때 Train데이터의 종속변수는 따로 저장 해야함.
test_data = test[, -1]
class = train[,1]
# k를 설정하면서 진행
knn_credit3 = knn(train_data, test_data, class, k = 3)
knn_credit7 = knn(train_data, test_data, class, k = 7)
knn_credit10 = knn(train_data, test_data, class, k = 10)

t_3 = table(knn_credit3, test$credit.rating)
t_3

(t_3[1, 1] + t_3[2, 2]) / sum(t_3) # 정확도 계산
[1] 0.6033333

t_7 = table(knn_credit7, test$credit.rating)
t_7

(t_7[1, 1] + t_7[2, 2]) / sum(t_7) # 정확도 계산
[1] 0.6566667

t_10 = table(knn_credit7, test$credit.rating)
t_10

(t_10[1, 1] + t_10[2, 2]) / sum(t_10) # 정확도 계산
[1] 0.6766667
```

`K = 10`으로 했을 때, 정분류율이 `67%`로 가장 높음 맹신은 금물..

그러면 이제 분류를 가장 잘한느 최적의 k값을 찾아보자.

```R
result = numeric() # 수치형 백터 선언
k = 3:22 # 3~22까지 수 생성
for(i in k) { # i를 인자로 k를 돌면서
  pred = knn(train_data, test_data, class, k = i-2)  # knn 분석 진행
  t = table(pred, test$credit.rating) # table 만들고
  result[i-2] = (t[1, 1] + t[2, 2])/sum(t) # 각 결과에 대한 정분류율을 result 객체에 저장
}
result # result 확인
sort(result) # 정렬한 후
which(result == max(result)) # 가장 큰 정분류율값인 index를 찾음
```

# ⭕인공신경망(ANN, Artificial Neural Network)

가중치를 반복 조정하면서 훈련 데이터로 모형을 학습시키는 것임   

뉴런의 활성화 함수: 계단, 부호, 시그모이드, relu, leaky-relu, softmax 등 많음. 사실 인공신경망 자체가 워낙 개념적으로 어려운 부분도 있음. 학부시절 공부해서 다행... 활성화함수를 시그모이드로 할 경우 단층 퍼셉트론은 로지스틱 회귀와 같아짐. R에서는 `nnet` , `neuralnet` 패키지의 `nnet()`와 `neuralnet()`함수를 이용함.   

`nnet` 패키지는 전통적인 역전파를 가지고 `feed-forward` 신경망을 훈련하는 알고리즘을 제공. 신경망의 매개변수는 `엔트로피`와 `SSE`로 최적화되며, 출력결과를 `softmax`함수를 사용해 확률 형태로 변환이 가능하고 과적합을 막기 위해 가중치 감소를 제공. `size`, `maxit`, `decay`인자 외에도 가중치를 설정하는 `weight` 초기 가중치 값을 설정하는 `wts` 등의 인자가 있음. `nnet` 함수로 생성된 모델의 변수 중요도를 파악하기 위해서는 `NeuralNetTools` 패키지의 `garson()`를 사용하여 확인

```R
nnet(formula, data, size, maxit, decay = 5e-04,  ... )
# size : hidden node의 개수
# maxit : 학습 반복횟수, 반복 중 가장 좋은 모델을 선정함.
# decay : 가중치 감소의 모수, 보통 5e-04를 선택
garson(mod_in)
# mod_in : 생성된 인공신경망 모델

set.seed(1231) # 인공신경망은 초깃값에 따라서 결과가 달라지니까.
               # 난수 설정
nn_model = nnet(credit.rating~.,
                data = train,
                size = 2,
                maxit = 200,
                decay = 5e-04)
# weights:  45
initial  value 462.977763 
iter  10 value 423.284312
iter  20 value 423.249284 # 45개의 weghit값이 생겼고, iteration이 반복될 수록 error값은 서서히 줄고 있음
iter  30 value 405.868979 
iter  40 value 372.835619
iter  50 value 364.605675
iter  60 value 349.242368
iter  70 value 347.469853
iter  80 value 346.565604
iter  90 value 346.110049
iter 100 value 345.394831
iter 110 value 344.407127
iter 120 value 343.277437
iter 130 value 342.456089
iter 140 value 342.282153 # 아주 조금씩...
final  value 342.280987 
converged

summary(nn_model)
a 20-2-1 network with 45 weights # weghit값은 아주 조금
options were - entropy fitting  decay=5e-04
  b->h1  i1->h1  i2->h1  i3->h1  i4->h1  i5->h1  i6->h1  i7->h1  i8->h1  i9->h1 i10->h1 i11->h1 i12->h1 i13->h1 i14->h1 i15->h1 i16->h1 
 -26.59   21.32   -3.21   22.99  -22.03    0.01   16.43   11.43   -6.84    2.72  -12.33    7.39  -16.61    0.68    3.78    8.62  -16.98  # 숫자들은 각각의 weight 값임
i17->h1 i18->h1 i19->h1 i20->h1 
   1.56  -12.90   18.19   13.53 
  b->h2  i1->h2  i2->h2  i3->h2  i4->h2  i5->h2  i6->h2  i7->h2  i8->h2  i9->h2 i10->h2 i11->h2 i12->h2 i13->h2 i14->h2 i15->h2 i16->h2 
   0.00    0.01   -0.01   -0.01    0.01    0.02    0.01   -0.01    0.00   -0.01   -0.01    0.01   -0.01   -0.01    0.01    0.00   -0.01 
i17->h2 i18->h2 i19->h2 i20->h2 
  -0.01    0.01    0.01    0.01 
  b->o  h1->o  h2->o 
 -0.24   2.36  -0.26 


install.packages('NeuralNetTools')
library(NeuralNetTools)
garson(nn_model) # 중요도 시각화
```

```R
library(caret)
pred_nn = predict(nn_model, test[,-1], type = 'class')
confusionMatrix(as.factor(pred_nn), reference = test[,1], positive = '1')
		# confusion 쓸 때 안에 데이터는 factor형 데이터여야 함.

Confusion Matrix and Statistics

          Reference
Prediction   0   1
         0  59  47
         1  36 158
                                         
               Accuracy : 0.7233         
                 95% CI : (0.669, 0.7732)
    No Information Rate : 0.6833         
    P-Value [Acc > NIR] : 0.07551        
                                         
                  Kappa : 0.38           
                                         
 Mcnemar''s Test P-Value : 0.27236        
                                         
            Sensitivity : 0.7707         
            Specificity : 0.6211         
         Pos Pred Value : 0.8144         
         Neg Pred Value : 0.5566         
             Prevalence : 0.6833         
         Detection Rate : 0.5267         
   Detection Prevalence : 0.6467         
      Balanced Accuracy : 0.6959         
                                         
       'Positive' Class : 1 
```

```R
library(ROCR)
pred_nn_roc = prediction(as.numeric(pred_nn), as.numeric(test[,1]))
# prediction 함수를 사용할 때, 안에 데이터는 수치형 자료여야 함.
plot(performance(pred_nn_roc, 'tpr', 'fpr'))
abline(a = 0, b = 1, lty = 2, col = 'black')
performance(pred_nn_roc, 'auc')@y.values
[[1]]
[1] 0.6958922
```

`neuralnet()` 예제

```R
neuralnet(formula, data, algorithm, threshold, hidden, stepmax, ... )
# algorithm : 사용할 알고리즘 지정
#################### backprop, rprop+(default), 'rprop-'등이 있음
# threshold : 훈련중단 기준, default는 0.01임. (임계치라 보면 됨)
# hidden : 은닉 노드의 개수, c(n, m)으로 입력하면 첫 번째 hidden layer에 n개의 hidden node를 가지고
#		  두 번째 hidden layer에 m개의 hidden node를 가짐
# stepmax : 인공 신경망 훈련 수행 최대회수
```

```R
library(neuralnet)
data(infert) # 자연유산, 인공유산 후의 불임에 대한 사례-대조 연구자료
in_part = createDataPartition(infert$case, # 말그대도 데이터 파티션임 확률적으로 70% 뽑아줌
                              times = 1,
                              p = 0.7)
table(infert[in_part$Resample1,  'case'])
  0   1 
118  56 
parts = as.vector(in_part$Resample1)
train_infert = infert[parts,] # 70% 는 train
test_infert = infert[-parts,] # 30% 는 test
nn_model2 = neuralnet(case~age+parity+induced+spontaneous,
                      data = train_infert,
                      hidden = c(2, 2),
                      algorithm = 'rprop+',
                      threshold = 0.01,
                      stepmax = 1e+5)

plot(nn_model2)
names(nn_model2)
 [1] "call"  "response"  "covariate"  "model.list"  "err.fct"  "act.fct"            
 [7] "linear.output"  "data"  "exclude"  "net.result"  "weights"  "generalized.weights"
[13] "startweights"  "result.matrix"

library(neuralnet)
set.seed(1231)
test_infert$nn_model2_pred.prob = compute(nn_model2, covariate = test_infert[, c(2:4,6)])$net.result
test_infert$nn_model2_pred = ifelse(test_infert$nn_model2_pred.prob > 0.5, 1, 0)
confusionMatrix(as.factor(test_infert$nn_model2_pred), as.factor(test_infert[, 5]))

Confusion Matrix and Statistics

          Reference
Prediction  0  1
         0 43 13
         1  4 14
                                          
               Accuracy : 0.7703          
                 95% CI : (0.6579, 0.8601)
    No Information Rate : 0.6351          
    P-Value [Acc > NIR] : 0.009198        
                                          
                  Kappa : 0.4665          
                                          
 Mcnemar''s Test P-Value : 0.052345        
                                          
            Sensitivity : 0.9149          
            Specificity : 0.5185          
         Pos Pred Value : 0.7679          
         Neg Pred Value : 0.7778          
             Prevalence : 0.6351          
         Detection Rate : 0.5811          
   Detection Prevalence : 0.7568          
      Balanced Accuracy : 0.7167          
                                          
       'Positive' Class : 0
```

compute()함수는 각 뉴런의 출력값을 계산해주며, 기존의 분류모형에서 사용된 predict 함수의 역할을 하여 예측값을 구해준다. 분석에 사용한 예측변수를 covariate인자에 추가하여 예측값을 $net.result를 통해 확인할 수 있다.   

로지스틱  회귀분석과 동일하게 neuralnet의 예측값은 범주로 나타나는 것이 아닌 확률 값으로 나타나기 때문에 기준이 되는 확률보다 크면 1, 작으면 0으로 범주를 추가한다.