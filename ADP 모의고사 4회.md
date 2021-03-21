# ⭕ ADP 모의고사 4회

## 1️⃣ 정형 데이터 마이닝(사용 데이터: weatherAUS)

###  1) 데이터의 요약값을 보고 NA 값이 10,000개 이상인 열을 제외하고 남은 변수 중 NA값이 있는 행을 제거하시오. 그리고 AUS 데이터의 Date변수를 Date형으로 변환하고 전처리가 완료된 weatherAUS 데이터를 train(70%), test(30%)로 분할하시오. (set.seed(6789)를 실행한 후 데이터를 분할하시오.)

- 문제의 요구에 따라 NA가 10000개 이상인 열은 다음과 같음 아래 열의 이름을 제외한 나머지를 선택해야함.
- `WindDir9am`
- `Pressure9am`
- `Cloud3pm`
- `Cloud9am`
- `Pressure3pm`

데이터 class를 확인한 후

```R
class(WA)
[1] "data.frame"
```

다음과 같이 데이터 열의 변수 명으로 만들 수 있으나, 열이 많아 졌을 때 사용하기 번거로우므로

```
WA2 = WA[, c('Date', 'Location', 'MinTemp', 'MaxTemp',
			'Rainfall', 'WindGustDir', 'WindGustSpeed',
			'WindDir3pm', 'WindSpeed9am', 'WindSpeed3pm',
			'Humidity9am', 'Humidity3pm', 'Temp9am',
			'Temp3pm', 'RainToday', 'RainTomorrow')]
```

다음과 같이 조건문을 활용하여 데이터를 처리함. 문제 요구에 따른 데이터 셋 정리( NA가 10000 이상이면 추가하지 않음)

```R
wa = data.frame(WA$Date)
for(i in 2:ncol(WA)) {
  if(sum(is.na(WA[,i])) < 10000) wa[,colnames(WA)[i]] <- WA[,i] 
}
str(WA2)
'data.frame':	128576 obs. of  16 variables:
 $ Date         : Date, format: "2008-12-01" "2008-12-02" "2008-12-03" ...
 $ Location     : Factor w/ 49 levels "Adelaide","Albany",..: 3 3 3 3 3 3 3 3 3 3 ...
 $ MinTemp      : num  13.4 7.4 12.9 9.2 17.5 14.6 14.3 7.7 9.7 13.1 ...
 $ MaxTemp      : num  22.9 25.1 25.7 28 32.3 29.7 25 26.7 31.9 30.1 ...
 $ Rainfall     : num  0.6 0 0 0 1 0.2 0 0 0 1.4 ...
 $ WindGustDir  : Factor w/ 16 levels "E","ENE","ESE",..: 14 15 16 5 14 15 14 14 7 14 ...
 $ WindGustSpeed: int  44 44 46 24 41 56 50 35 80 28 ...
 $ WindDir3pm   : Factor w/ 16 levels "E","ENE","ESE",..: 15 16 16 1 8 14 14 14 8 11 ...
 $ WindSpeed9am : int  20 4 19 11 7 19 20 6 7 15 ...
 $ WindSpeed3pm : int  24 22 26 9 20 24 24 17 28 11 ...
 $ Humidity9am  : int  71 44 38 45 82 55 49 48 42 58 ...
 $ Humidity3pm  : int  22 25 30 16 33 23 19 19 9 27 ...
 $ Temp9am      : num  16.9 17.2 21 18.1 17.8 20.6 18.1 16.3 18.3 20.1 ...
 $ Temp3pm      : num  21.8 24.3 23.2 26.5 29.7 28.9 24.6 25.5 30.2 28.2 ...
 $ RainToday    : Factor w/ 2 levels "No","Yes": 1 1 1 1 1 1 1 1 1 2 ...
 $ RainTomorrow : Factor w/ 2 levels "No","Yes": 1 1 1 1 1 1 1 1 2 1 ...
 - attr(*, "na.action")= 'omit' Named int  15 64 65 75 89 182 187 196 199 226 ...
  ..- attr(*, "names")= chr  "15" "64" "65" "75" ...
```

#### 날짜 열 정리

```R
WA2$Date = as.Date(WA2$Date)
# 분할 전 결측치 행은 사용할 수 없으므로 해당 행을 제거해야함.
# 따라서 na.omit()을 사용하여 분할 전 NA를 정제
WA2 = na.omit(WA2)
summary(WA2)
```

#### train과 test 분할

```R
set.seed(6789) # 난수 설정
# 분할을 위한 index 설정
train_idx = sample(1:nrow(WA2), as.integer(nrow(WA)*0.7), replace = F)
train_WA = WA2[train_idx,] # train 분할
test_WA = WA2[-train_idx,] # test 분할
# 데이터 분할 완료
```

-  해당 데이터는 약 10냔치의 데이터임.

### 2) train 데이터로 종속변수인 RainTomorrow(다음날 강수 여부)를 예측하는 분류모델을 3개 이상 생성하고 test 데이터에 대한 예측값을 csv 파일로 제출하시오.

- 이번 실습은 배깅, 부스팅 랜덤포레스트

```R
# 1. 랜덤포레스트
library(caret)
library(randomForest)
wa.rf = randomForest(RainTomorrow~., data=train_WA)
print(wa.rf)
pred.rf = predict(wa.rf, test_WA[,-16], type='prob')
# write.csv(pred.rf, 'RamdomForest_res.csv')

# 2. 배깅
install.packages('adabag')
library(adabag)
wa.bg = bagging(RainTomorrow~., data=train_WA, mfinal=15, control=rpart.control(maxdepth=5, minsplit=15))
pred.bg = predict(wa.bg, test_WA[,-16], type='prob')
pred1.bg = data.frame(pred.bg$prob, RainTomorrow=pred.bg$class)
summary(pred1.bg)
# write.csv(pred1.bg, 'bagging_res.csv')

# 3. 부스팅
wa.bt = boosting(RainTomorrow~., data=train_WA, boos=F, mfinal=15, control=rpart.control(maxdepth=5, minsplit=15))
pred.bt = predict(wa.bt, test_WA[,-16], type='prob')
pred1.bt = data.frame(pred.bt$prob, RainTomorrow=pred.bt$class)
```

### 3)  생성된 3개의 분류모델에 대해 성과분석을 실시하여 정확도를 비교하여 설명하시오. 또 roc-curve를 그리고 AUC값을 산출하시오.

```R
# 1. bagging
library(ROCR)
pred.bg = predict(wa.bg, test_WA[,-16], type='class')
confusionMatrix(data=as.factor(pred.bg$class), reference=test_WA[,16], positive='No')

pred.bg.roc = prediction(as.numeric(as.factor(pred.bg$class)), as.numeric(test_WA[,16]))
plot(performance(pred.bg.roc, 'tpr', 'fpr'))
abline(a=0, b=1, lty=2)

performance(pred.bg.roc, 'auc')@y.values

# 2. boosting
pred.bt = predict(wa.bt, test_WA[,-16], type='class')
confusionMatrix(as.factor(pred.bt$class), reference = test_WA[,16], positive='No')

pred.bt.roc = prediction(as.numeric(as.factor(pred.bt$class)), as.numeric(test_WA[, 16]))
plot(performance(pred.bt.roc, 'tpr', 'fpr'))
abline(a=0, b=1, lty=2)
performance(pred.bt.roc, 'auc')@y.values

# 3. RandomForest
pred.rf = predict(wa.rf, test_WA[,-16], type='class')
confusionMatrix(pred.rf, reference=test_WA[,16], positive='No')

pred.rf.roc = prediction(as.numeric(as.factor(pred.rf)), as.numeric(test_WA[,16]))
plot(performance(pred.rf.roc, 'tpr','fpr'))
abline(a=0, b=1, lty=2)

performance(pred.rf.roc, 'auc')@y.values

# RandomForest 모형이 가장 정확도가 높게 연산되었음.
# 따라서 위 3개의 모형 중 분류모형으로 RandomForest를 선택하는 것이 알맞으나
# 단순히 정확도가 높은 것 만으로 모형을 선택하는 것은 부적절함.
# 보다 정확하게는 민감도, 특이도를 함께 파악하여 해당 모형을 선택해야함.
```

