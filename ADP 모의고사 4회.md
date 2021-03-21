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

## 2️⃣ 통계분석(사용데이터: bike_marketing)

### 1)  pop_density 변수를 factor형 변수로 변환하고, pop_density별 revenuedml 평균차이가 있는지 통계분석을 시행하여 결과를 해석하시오. 만일 대립가설이 채택된다면 사후분석을 실시하고 결과를 해석하시오.

-  데이터를 불러오고 데이터 구조와 요약을 확인

```R
bm = read.csv('bike_marketing.csv')
str(bm)
summary(bm)
# 8개의 열과 172개의 행으로 이루어짐
# 불러온 결과 pop_density는 백터형 변수임 이를 확인
class(bm$pop_density)
# 이를 다시 factor으로 일단 변환
bm$pop_density = as.factor(bm$pop_density)
```

#### pop_denstity별 revenues의 평균 차이가 있는지 통계분석을 실시(분산분석)

```R
ANOVAres = aov(revenues~pop_density, data=bm)
summary(ANOVAres)
             Df Sum Sq Mean Sq F value Pr(>F)
pop_density   2     42   20.87    0.61  0.545
Residuals   169   5781   34.21 
```

- 유의확률이 0.545로 유의수준 5% 하에서 인구밀집 정도에 따른 매출 평균에 차이가 있다는 의미를 찾을 수 없다. 따라서 대립가설을 채택할 수 없으므로 사후분석을 실시하지 않는다.

###  2) google_adwords, facebook, twitter, marketing_total, employees가 revenues에 영향을 미치는지 알아보는 회귀분석을 전진 선택법 사용하여 수행하고 결과를 해석하시오.

``` R
step(lm(revenues~1, data=bm), 
     scope=list(upper=lm(revenues~google_adwords+facebook+twitter+marketing_total+employees, data=bm)),direction='forward')
Start:  AIC=607.8
revenues ~ 1

                  Df Sum of Sq    RSS    AIC
+ marketing_total  1    4235.3 1587.8 386.29
+ google_adwords   1    3418.9 2404.2 457.64
+ employees        1    3413.9 2409.2 458.00
+ facebook         1    1944.2 3878.9 539.92
+ twitter          1     423.5 5399.6 596.81
<none>                         5823.1 607.80

Step:  AIC=386.29
revenues ~ marketing_total

                 Df Sum of Sq     RSS    AIC
+ facebook        1    632.00  955.78 300.98
+ employees       1    276.11 1311.67 355.43
+ google_adwords  1     98.35 1489.43 377.29
<none>                        1587.78 386.29
+ twitter         1     17.67 1570.11 386.36

Step:  AIC=300.98
revenues ~ marketing_total + facebook

                 Df Sum of Sq    RSS    AIC
+ google_adwords  1   131.845 823.93 277.45
+ twitter         1   130.154 825.62 277.81
+ employees       1    98.114 857.66 284.36
<none>                        955.78 300.99

Step:  AIC=277.45
revenues ~ marketing_total + facebook + google_adwords

            Df Sum of Sq    RSS    AIC
+ employees  1    67.681 756.25 264.71
+ twitter    1    25.292 798.64 274.09
<none>                   823.93 277.45

Step:  AIC=264.71
revenues ~ marketing_total + facebook + google_adwords + employees

          Df Sum of Sq    RSS    AIC
+ twitter  1    18.713 737.54 262.40
<none>                 756.25 264.71

Step:  AIC=262.4
revenues ~ marketing_total + facebook + google_adwords + employees + 
    twitter


Call:
lm(formula = revenues ~ marketing_total + facebook + google_adwords + 
    employees + twitter, data = bm)

Coefficients:
    (Intercept)  marketing_total         facebook   google_adwords        employees  
        28.4433          -1.1696           1.3464           1.2110           0.3865  
        twitter  
         1.1724 
```

- 처음으로 marketing_total 변수가 추가되었음 이후 facebook, google_adwords, employees, twitter 순으로 추가되었음을 확인할 수 있으며 이때의 정보기준 값은 264.71임 가장 작은 정보기준을 갖는 모형은 revenues ~ google_adwords + facebook + twitter + marketing_total + employees 로 결정되었음 이를 자세히 알아보면

```R
regression_res = lm(formula = revenues ~ google_adwords + facebook + twitter + 
                      marketing_total + employees, data = bm)
summary(regression_res)

Call:
lm(formula = revenues ~ google_adwords + facebook + twitter + 
    marketing_total + employees, data = bm)

Residuals:
    Min      1Q  Median      3Q     Max 
-5.7788 -1.2437  0.2024  1.4643  4.2835 

Coefficients:
                Estimate Std. Error t value Pr(>|t|)    
(Intercept)      28.4433     0.5962  47.706  < 2e-16 ***
google_adwords    1.2110     0.5708   2.122 0.035348 *  
facebook          1.3464     0.5714   2.356 0.019618 *  
twitter           1.1724     0.5713   2.052 0.041711 *  
marketing_total  -1.1696     0.5708  -2.049 0.042033 *  
employees         0.3865     0.1042   3.708 0.000284 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 2.108 on 166 degrees of freedom
Multiple R-squared:  0.8733,	Adjusted R-squared:  0.8695 
F-statistic: 228.9 on 5 and 166 DF,  p-value: < 2.2e-16

# 모든 변수가 5% 유의수준 하에서 귀무가설을 기각하고 있음, 또한 회귀모형 자체에 대한 유의확률도 2.2e-16 보다 작음
# 따라서 회귀모형도 5% 유의수준 하에서 유의함을 알 수 있음.
# 모두 유의미한 변수이며 marketing_total 변수를 제외한 나머지 변수는 모두 revenues를 증가시키는 요인이됨.
# 정리하자면, 구글 AdWords 비용이 높을수록, 페이스북 광고비용이 높을수록
# 트위터 광고비용이 높을수록, 총 마케팅 예산이 작을수록
# 종원수가 높을수록 매출은 높아지는 결과를 얻음
# 이를 통해 해당 모형은 최종적으로
# y = 28.4433 + 1.2110*google_adwords + 1.3464*facebook + 1.1724twitter -1.1696marketing_total + 0.3865employees 임
```

### 3)  전진선택법을 사용해 변수를 선택한 후 새롭게 생성한 회귀모형에 대한 잔차분석을 수행하고 결과를 해석하시오.

#### 잔차에 대한 세 가지 가정 중 독립성을 가정을 만족하는지 확인한다.

```R
library(lmtest)

dwtest(regression_res)
	Durbin-Watson test

data:  regression_res
DW = 2.1114, p-value = 0.7666
alternative hypothesis: true autocorrelation is greater than 0
# 확인 결과 유의확률값은 0.7666으로 귀무가설을 기각하지 못함.
# 즉 독립성 가정을 만족한다고 할 수 있음.
```

#### 잔차에 대한 정규성 가정을 만족하는지 확인

```R
shapiro.test(resid(regression_res))
	Shapiro-Wilk normality test

data:  resid(regression_res)
W = 0.98658, p-value = 0.0991
# 유의확률은 0.0991이므로 귀무가설을 기각할 수 없음
# 따라서 정규성을 만족한다고 할 수 있음.
```

#### 등분산성을 만족하는지 알아보지 위해 plot을 찍어봄

```R
par(mfrow=c(2, 2))
plot(regression_res)
# scale-location에서 기울기가 0에 가깝지 못한 것을 확인할 수 있음. 따라서
# 본 모형을 활용하기에는 힘듬(3가지 가정 중 등분산성을 만족시키지 못한 것을 확인할 수 있음.)
```

## 3️⃣ 비정형 데이터 마이닝(사용 데이터: instargram_태교여행.txt)

### 1) 'instargram_태교여행.txt'를 읽고 숫자, 특수문자 등을 제거하는 전처리 작업을 수행하시오.

```R
# 필요 패키지, 사전 로드

library(rJava)
library(tm)
library(KoNLP)
library(wordcloud)
library(plyr)

useSejongDic()

insta = readLines('instagram_태교여행.txt')

clean_txt = function(txt) { # 텍스트 전처리
  txt = tolower(txt) # 소문자 변환
  txt = removeNumbers(txt) # 숫자 제거
  txt = removePunctuation(txt) # 구두점 제거
  txt = stripWhitespace(txt) # 공백 제거
  return(txt) # 텍스트 반환
}

insta_clean = clean_txt(insta)
```

### 2) 전처리된 데이터에서 `태교여행`이란 단어를 사전에 추가하고 명사를 추출해 출현빈도 10위까지 막대 그래프로 시각화하시오.

``` R
buildDictionary(ext_dic='woorimalsam', user_dic=data.frame(c("태교여행"),'ncn'), replace_usr_dic=T) # 사전에 태교여행 단어 추가
tour1 = sapply(insta_clean, extractNoun) # 명사 추출
table.cnoun = head(sort(table(unlist(tour1)), decreasing=T), 10) # sorting
barplot(table.cnoun, main="tour 데이터 빈출 명사", xlab="단어", ylab="빈도")
```

### 3) 전처리된 데이터를 이용해 워드 클라우드를 작성하고 인사이트를 추출하시오.

```R
res_word = data.frame(sort(table(unlist(tour1)), decreasing = T))
wordcloud(res_word$Var1, res_word$Freq, color=brewer.pal(6, 'Dark2'), min.freq=20)
```

- 본 데이터의 텍스트마이닝을 통해 태교여행으로 괌, 제주도 같은 곳으로 여행을 다니는 것을 알 수 있다. 또 한 출산부라는 것을 암시하는 태교여행, 임산부, 신혼, 가족, 부부, 태교, 임신과 같은 단어가 들어가있는 것을 알 수 있다. 이러한 결과를 통해 마케팅(예: 스타-유명 연예인 태교여행 패키지), 홍보(제주, 괌 여행 사진 등)를 여행사에 진행 할 수 있도록 인사이트를 활용할 수 있다.