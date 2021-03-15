# ⭕ ADP 모의고사 2회

## 2️⃣ 정형 데이터 마이닝(사용 데이터: Titanic)

### 1) cabin, embarked변수의 값 중 ""로 처리된 값을 NA로 바꾸고 문자형, 범주형 변수들을 각각 character, factor형으로 변환하시오. 또, 수치형 변수가 NA인 값을 중앙값으로 대체하고, 범주형 변수가 NA인 값을 최빈값으로 대체하고 age변수를 구간화하여 age_1이라는 변수를 생성하고 추가하시오.

```R
titanic = read.csv('titanic.csv') # 타이타닉 데이터 불러오기
head(titanic) # 확인
str(titanic) # 구조 확인

summary(titanic)

# 이 방법을 쓰자
levels(titanic$cabin)[1] = NA
levels(titanic$embarked)[1] = NA

# NA로 변형(이 변형은 factor로 바꾸어도 수치형으로 출력됨)  이 방법은 안 쓰는걸로
# titanic$cabin = ifelse(titanic$cabin == "",NA, titanic$cabin)
# titanic$embarked = ifelse(titanic$embarked == "", NA, titanic$embarked) 
# titanic$cabin = factor(titanic$cabin)
# titanic$embarked  = factor(titanic$embarked)

# 이 방법을 쓰자
titanic$pclass = as.factor(titanic$pclass)
titanic$survived = factor(titanic$survived, levels=c(0, 1), labels=c('dead', 'survived'))
titanic$name = as.character(titanic$name)
titanic$ticket = as.character(titanic$ticket)
titanic$cabin = as.character(titanic$cabin)

summary(titanic)
 pclass      survived       name               sex           age            sibsp            parch          ticket               fare            cabin           embarked  
 1:323   dead    :809   Length:1309        female:466   Min.   : 0.17   Min.   :0.0000   Min.   :0.000   Length:1309        Min.   :  0.000   Length:1309        C   :270  
 2:277   survived:500   Class :character   male  :843   1st Qu.:21.00   1st Qu.:0.0000   1st Qu.:0.000   Class :character   1st Qu.:  7.896   Class :character   Q   :123  
 3:709                  Mode  :character                Median :28.00   Median :0.0000   Median :0.000   Mode  :character   Median : 14.454   Mode  :character   S   :914  
                                                        Mean   :29.88   Mean   :0.4989   Mean   :0.385                      Mean   : 33.295                      NA's:  2  
                                                        3rd Qu.:39.00   3rd Qu.:1.0000   3rd Qu.:0.000                      3rd Qu.: 31.275                                
                                                        Max.   :80.00   Max.   :8.0000   Max.   :9.000                      Max.   :512.329                                
                                                        NA's   :263                                                         NA's   :1 
```

- `levels(titanic$embarked)[1] <- NA`, `levels(titanic$cabin)[1] <- NA`코드를 활용하여 `""`에 해당하는 데이터를 모두 `NA`로 변환하였다. `summary()`함수를 사용하여 결과를 확인했을 때, `""`값이 삭제된 것을 알 수 있다.
- 다음으로 변수의 타입을 변경하였는데, 이는 문제에서 요구한 것을 그대로 실행하였다. 단지 `pclass, name, ticket, cabin` 데이터의 경우 데이터프레임 내에서 수정하는 것으로 생각하여 `as.character()` 함수와 `as.factor()` 함수를 사용하였으며, `survived`의 경우 기존의 `levels`가 0과 1로만 구성되어 있음에 착안하여 `label`을 추가하기 위해 `factor()` 함수를 사용하였다.

```R
str(titanic)
'data.frame':	1309 obs. of  11 variables:
 $ pclass  : Factor w/ 3 levels "1","2","3": 1 1 1 1 1 1 1 1 1 1 ...
 $ survived: Factor w/ 2 levels "dead","survived": 2 2 1 1 1 2 2 1 2 1 ...
 $ name    : chr  "Allen, Miss. Elisabeth Walton" "Allison, Master. Hudson Trevor" "Allison, Miss. Helen Loraine" "Allison, Mr. Hudson Joshua Creighton" ...
 $ sex     : Factor w/ 2 levels "female","male": 1 2 1 2 1 2 1 2 1 2 ...
 $ age     : num  29 0.92 2 30 25 48 63 39 53 71 ...
 $ sibsp   : int  0 1 1 1 1 0 1 0 2 0 ...
 $ parch   : int  0 2 2 2 2 0 0 0 0 0 ...
 $ ticket  : chr  "24160" "113781" "113781" "113781" ...
 $ fare    : num  211 152 152 152 152 ...
 $ cabin   : chr  "B5" "C22 C26" "C22 C26" "C22 C26" ...
 $ embarked: Factor w/ 3 levels "C","Q","S": 3 3 3 3 3 3 3 3 3 1 ...

```

- 이후 수치형 자료의 경우 결측치를 중앙값, 범주형 자료의 경우 결측치를 최빈값으로 대체하기 위해 `DMwR` 패키지의 `complete.case()`함수를 사용하였다.

```R
# 수치형 변수는 중앙값, 범주형 번수는 최빈값으로 대체해주는 함수는
# complete.cases 함수임
install.packages('DMwR')
library(DMwR)
sum(complete.cases(titanic)) # 해당 데이터 출력
titanic2 = centralImputation(titanic)
```

- 문제에서 요구한 age_1 변수를 생성하기 위해 within()함수를 사용했으며 해당 코드와 결과는 다음과 같다.

```R
# within 함수는 조건에 알맞게 변수를 조작하나 뒤 열로 추가해주는 것임
titanic2 = within(titanic2,
                  {
                    age_1 = integer(0)
                    age_1[age >= 0 & age < 10] = 0
                    age_1[age >= 10 & age < 20] = 1
                    age_1[age >= 20 & age < 30] = 2
                    age_1[age >= 30 & age < 40] = 3
                    age_1[age >= 40 & age < 50] = 4
                    age_1[age >= 50 & age < 60] = 5
                    age_1[age >= 60 & age < 70] = 6
                    age_1[age >= 70 & age < 80] = 7
                    age_1[age >= 80 & age < 90] = 8
                  })

head(titanic2)

titanic2$age_1 = factor(titanic2$age_1,
                        levels=c(0, 1, 2, 3, 4, 5, 6, 7, 8),
                        labels = c('10대 미만',
                                   '10대',
                                   '20대',
                                   '30대',
                                   '40대',
                                   '50대',
                                   '60대',
                                   '70대',
                                   '80대'))
str(titanic2)
'data.frame':	1309 obs. of  12 variables:
 $ pclass  : Factor w/ 3 levels "1","2","3": 1 1 1 1 1 1 1 1 1 1 ...
 $ survived: Factor w/ 2 levels "dead","survived": 2 2 1 1 1 2 2 1 2 1 ...
 $ name    : chr  "Allen, Miss. Elisabeth Walton" "Allison, Master. Hudson Trevor" "Allison, Miss. Helen Loraine" "Allison, Mr. Hudson Joshua Creighton" ...
 $ sex     : Factor w/ 2 levels "female","male": 1 2 1 2 1 2 1 2 1 2 ...
 $ age     : num  29 0.92 2 30 25 48 63 39 53 71 ...
 $ sibsp   : int  0 1 1 1 1 0 1 0 2 0 ...
 $ parch   : int  0 2 2 2 2 0 0 0 0 0 ...
 $ ticket  : chr  "24160" "113781" "113781" "113781" ...
 $ fare    : num  211 152 152 152 152 ...
 $ cabin   : chr  "B5" "C22 C26" "C22 C26" "C22 C26" ...
 $ embarked: Factor w/ 3 levels "C","Q","S": 3 3 3 3 3 3 3 3 3 1 ...
 $ age_1   : Factor w/ 9 levels "10대 미만","10대",..: 3 1 1 4 3 5 7 4 6 8 ...
```

### 2) 전처리가 완료된 titanic 데이터를 train(70%), test(30%) 데이터로 분할하시오.(set.seed(12345)를 실행한 후 데이터를 분할하시오.) 또 train 데이터로 종속변수인 survived(생존여부)를 독립변수 pclass, sex, sibsp, parch, fare, embarked로 지정하여 예측하는 분류모델을 3개 이상 생성하고 test 데이터에 대한 예측값을 csv 파일로 각각 제출하시오.

-  데이터 셋을 분할하기 위해 set.seed(12345)를 실행하고 sample()함수를 사용하여 해당 데이터의 행수에 0.7를 곱하여 분할하였다. 이때 문제에서 요구한 열만을 따로 추출하여 진행하였다.

```R
set.seed(12345)
idx = sample(1:nrow(titanic2), size=nrow(titanic2)*0.7, replace=F)
train = titanic2[idx,]
test = titanic2[-idx,]
nrow(train)
nrow(test)

train1 = train[,c('pclass','survived','sex','sibsp','parch','fare','embarked')]
test1 = test[,c('pclass','survived','sex','sibsp','parch','fare','embarked')]
str(train1)
'data.frame':	916 obs. of  7 variables:
 $ pclass  : Factor w/ 3 levels "1","2","3": 1 1 3 3 3 3 3 3 2 1 ...
 $ survived: Factor w/ 2 levels "dead","survived": 2 2 2 1 1 1 1 2 2 1 ...
 $ sex     : Factor w/ 2 levels "female","male": 1 1 2 2 2 2 2 1 1 2 ...
 $ sibsp   : int  0 0 0 0 0 0 5 0 1 0 ...
 $ parch   : int  1 1 0 0 0 0 2 0 0 2 ...
 $ fare    : num  63.36 512.33 8.05 7.9 7.22 ...
 $ embarked: Factor w/ 3 levels "C","Q","S": 1 1 3 3 1 3 3 3 3 1 ...
```

- 이 후 본격적인 분류모델을 생성했으며, 대표적인 분류모델인 Decision Tree, RandomForest, Logistic Regression을 사용하였다.

```R
# 나무모형
library(rpart)
library(rpart.plot)

dt.model = rpart(survived~.,
                 method='class',
                 data = train1,
                 control = rpart.control(maxdepth = 4,
                                         minsplit = 15))
dt.model

prp(dt.model)

pred = predict(dt.model, test1[,-2], type='prob')
# write.csv(pred, 'decisionTree predict.csv')

# 랜덤포레스트
library(randomForest)
rf.model = randomForest(survived~.,
                        data = train1)
print(rf.model)

pred = predict(rf.model, test1[,-2], type='prob')
# write.csv(pred, 'randomforest predict.csv')

# logistic
lg.model = step(glm(survived~., data = train1, family = 'binomial'),
                direction = 'both',
                scope = list(lower = ~1,
                             upper = ~sex+pclass+embarked+parch+fare+sibsp))

pred = predict(lg.model, test[,-2], type = 'response')
pred = data.frame(pred)
pred$survived = ifelse(pred$pred <= 0.5,
                       pred$survived <- 'dead',
                       pred$survived <- 'survived')

# write.csv(pred, 'logistic regression predict.csv')
```

- 여기서 특이점은 로지스틱 회귀의 경우 예측을 위한 과정에서 `predict()`함수를 사용 할 때 `type='class'`로 입력하는 것이 아닌, `type='response'`를 입력해야한다.
- 그림은 생략...

### 3) 생성된 3개의 분류모델에 대해 성과분석을 실시하여 정확도를 비교하여 설명하시오. 또 ROC Curve를 그리고 AUC 값을 산출하시오.

```R
# 성과분석
library(caret)
library(ROCR)

# 나무모형
pred.dt = predict(dt.model, test1[, -2], type='class')
confusionMatrix(pred.dt, reference=test[, 2], positive='survived')

pred.dt.roc = prediction(as.numeric(pred.dt), as.numeric(test1[, 2]))
plot(performance(pred.dt.roc, 'tpr', 'fpr'))
abline(a=0, b=1, col='black', lty=2)
performance(pred.dt.roc, 'auc')@y.values
[1] 0.7036731

# 랜덤포레스트
pred.rf = predict(rf.model, test[, -2], type='class')
confusionMatrix(pred.rf, reference=test[, 2], positive='survived')

pred.rf.roc = prediction(as.numeric(pred.rf), as.numeric(test1[, 2]))
plot(performance(pred.rf.roc, 'tpr', 'fpr'))
abline(a=0, b=1, col='black', lty=2)
performance(pred.rf.roc, 'auc')@y.values
[1] 0.740431

# 로지스틱
pred.lg = predict(lg.model, test1[, -2], type='response')
pred.lg = as.data.frame(pred.lg)
pred.lg$survived = ifelse(pred.lg$pred.lg <= 0.5,
                          pred.lg$survived <- 'dead',
                          pred.lg$survived <- 'survived')
confusionMatrix(data=as.factor(pred.lg$survived),
                reference=test1[,2],
                positive='survived')

pred.lg$survived = as.factor(pred.lg$survived)
pred.lg.roc = prediction(as.numeric(pred.lg$survived),
                         as.numeric(test[,2]))
plot(performance(pred.lg.roc, 'tpr', 'fpr'))
abline(a=0, b=1, col='black', lty=2)
performance(pred.lg.roc, 'auc')@y.values
[1] 0.7598536
```

- 성과분석 후 logistic regression의 정확도가 가장 높게 판명되었다. 하지만, 중요한 것은 특이도, 민감도 등도 함께 파악하여 해당 데이터에 가장 적절한 분석 모형을 선택해야한다.

## 3️⃣ 비정형 데이터 마이닝(사용 데이터: 문재인 대통령 연설문)

### 1) 연설문.txt 데이터를 읽어온 뒤 숫자, 특수문자 등을 제거하는 전처리 작업을 시행하시오.

```R
keynote = readLines('연설문.txt') # 데이터 로드

library(rJava) # 필요 패키지 로드
library(tm)
library(KoNLP)
library(dplyr)
library(plyr)
library(wordcloud)

useSejongDic() # 필요 사전 로드

clean_txt = function(txt) { # 텍스트 전처리 로드
  txt = tolower(txt)
  txt = removePunctuation(txt)
  txt = removeNumbers(txt)
  txt = stripWhitespace(txt)
  return(txt)
}
```

clean_txt에 tm 패키지에서 제공하는 tolower, removeNumbers, removePunctuation, stripWhitespace함수를 활용하여 대, 소문자 변환, 숫자 제거,구두점, 공백 제거를 수행한다.

### 2) 전처리된 데이터에서 명사를 추출하고 명사의 출현빈도를 10위까지 추출하여 막대그래프로 시각화하시오.

```R
keynote_1 = clean_txt(keynote) # 텍스트 전처리
noun = extractNoun(keynote_1) # 명사 추출
wordcnt = table(unlist(noun)) # 추출된 명사 테이블로 만들기
cnoun = as.data.frame(wordcnt, stringsAsFactors = F) # 테이블형 데이터를 데이터 프레임으로 변환
table.cnoun = cnoun[nchar(cnoun$Var1) >= 2,] # 문자 중 적어도 2회 이상 등장한 명사만 추출

top_10 = table.cnoun %>% arrange(-Freq) %>%  head(10) # 내림차순 이때 dplyr 패키지 활용


barplot(top_10$Freq, # barplot 그리기
        names=top_10$Var1,
        main='문재인 대통령 취임사 빈출 명사',
        xlab='단어',
        ylab='빈도')
```

![문재인 대통령 취임사 빈출 명사 barplot](.\img\문재인 대통령 취임사 빈출 명사 barplot.png)

국민, 대통령, 대한 순으로 단어가 많이 쓰이고 있음을 알 수 있다.

### 3)  전처리된 데이터를 이용해 워드클라우드를 작성하고 인사이트를 추출하시오.

```
result = table.cnoun %>%  arrange(-Freq)
t = wordcloud(result$Var1,
              result$Freq,
              color=brewer.pal(6, 'Dark2'),
              min.freq = 2)
```

![keynote_wordcloud](.\img\keynote_wordcloud.png)

텍스트 마이닝을 통해 추출된 단어들을 이야기하면, 대통령, 국민, 우리, 정치, 우리, 대한, 민국 등 민심에 대한 언급이 가장 많았음을 알 수 있으며, 통일에 대한 문제에 대해 연설문을 작성했음을 알 수 있다.