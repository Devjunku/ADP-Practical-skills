# ⭕ ADP 모의고사 1회

## 1️⃣ 01 정형 데이터 마이닝 lotto

### 1) 연관규칙을 위해 `lotto `데이터셋을 `transaction` 데이터로 변환하시오. (단, 로또번호가 추첨된 순서는 고려하지 않음) 그리고 변환된 데이터에서 가장 많이 등장한 10개의 번호를 순서대로 출력하고 이를 설명하시오.

`transaction` 데이터로 변환하기 위해서는 `as()`를 사용하여 변환할 수 있음. 하지만 이것만 알면 안되고 현재 `lott`o라는 데이터 셋이 어떻게 되어 있는지 알아야함. `lotto`는 `time_id` 로또회차, `numM` 해당 회의 N번 째 당첨번호 6개로 총 7개의 열과 859개의 행으로 이루어져있음. 따라서 각 해당 회차에는 6개의 열로 번호가 표현되어 있음. 이를 하나로 통합한 후 집합처럼 묶어줄것임 이를 위해 `reshape2` 패키지의 `melt()`함수와 `split()`함수를 사용

```R
lotto = read.table('clipboard', sep='\t', header=T)
head(lotto)
  time_id num1 num2 num3 num4 num5 num6
1     859    8   22   35   38   39   41
2     858    9   13   32   38   39   43
3     857    6   10   16   28   34   38
4     856   10   24   40   41   43   44
5     855    8   15   17   19   43   44
6     854   20   25   31   32   36   43

str(lotto)
'data.frame':	859 obs. of  7 variables:
 $ time_id: int  859 858 857 856 855 854 853 852 851 850 ...
 $ num1   : int  8 9 6 10 8 20 2 11 14 16 ...
 $ num2   : int  22 13 10 24 15 25 8 17 18 20 ...
 $ num3   : int  35 32 16 40 17 31 23 28 22 24 ...
 $ num4   : int  38 38 28 41 19 32 26 30 26 28 ...
 $ num5   : int  39 39 34 43 43 36 27 33 31 36 ...
 $ num6   : int  41 43 38 44 44 43 44 35 44 39 ...

# 연관분석을 위한 transaction 데이터 만들기
ibrary(reshape2) # 업로드
lot_melt = melt(lotto, id.vars=1) # 1열을 기준으로 나머지 열을 전부 하나의 열로 맞추기
lot_melt2 = lot_melt[,-2] # 2번째 열은 variable이므로 의미가 없음
str(lot_melt2) # 구조 확인
'data.frame':	5154 obs. of  2 variables:
 $ time_id: int  859 858 857 856 855 854 853 852 851 850 ...
 $ value  : int  8 9 6 10 8 20 2 11 14 16 ...

library(arules) # as함수를 사용하기 위해 라이브러리 업로드
lot_sp = split(lot_melt2$value, lot_melt2$time_id) # id를 기준으로 구분 짓고 하나로 통합
lot_ts = as(lot_sp, 'transactions') # transactions 데이터로 전환
inspect(lot_ts) # transactions 데이터를 출력하기 위해서 inspect 함수를 사용
      items               transactionID
[1]   {10,23,29,33,37,40} 1            
[2]   {9,13,21,25,32,42}  2            
[3]   {11,16,19,21,27,31} 3            
[4]   {14,27,30,31,40,42} 4            
[5]   {16,24,29,40,41,42} 5            
[6]   {14,15,26,27,40,42} 6            
[7]   {2,9,16,25,26,40}   7            
[8]   {8,19,25,34,37,39}  8            
[9]   {2,4,16,17,36,39}   9            
[10]  {9,25,30,33,41,44}  10
# 상위 10개의 로또 번호를 확인

itemFrequencyPlot(lot_ts, topN=10, type='absolute') # 절대도수를 기준으로 파악
itemFrequencyPlot(lot_ts, topN=10) # 상대도수를 기준으로 파악

```

![lot_ts](.\img\lot_ts.png)

유독 34라는 수가 높은 비율로 등장한 것을 확인할 수 있으며 나머지 수에서 큰 비율의 차이가 있지는 않음

### 2) 변환한 데이터에 대해 `apriori()` 함수를 사용하여 다음 괄호 안의 조건을 반영하여 연관규칙을 생성하고, 이를 `'rules_1'`라는 변수에 저장하여 결과를 해석하시오. (최소지지도:0.002, 최소신뢰도:0.8, 최소조합 항목 수:2, 최대조합 항목 수:6)그리고 도출된 연관규칙들을 향상도를 기준으로 내림차순 정렬하여 상위 30개의 규칙을 확인하고 이를 데이터 프레임 형태로 반환하여 CSV파일로 출력하시오

```R
# 연관분석 수행
metric_params = list(supp=0.002, conf=0.8, minlen=2, maxlen=6) # parameter list생성
rule_1 = apriori(lot_ts, parameter = metric_params) # apriori()를 이용해서 결과 생성, -> 총 679개의 데이터가 생성되었다.
inspect(rule_1[1:20,]) # 해당 규칙 20개만 확인 
     lhs           rhs  support     confidence lift     count
[1]  {9,32,43}  => {38} 0.002328289 1          7.601770 2    
[2]  {9,38,43}  => {32} 0.002328289 1          8.855670 2    
[3]  {32,38,43} => {9}  0.002328289 1          9.651685 2    
[4]  {9,23,28}  => {7}  0.002328289 1          7.535088 2    
[5]  {7,9,23}   => {28} 0.002328289 1          8.180952 2    
[6]  {7,9,28}   => {23} 0.002328289 1          8.676768 2    
[7]  {7,23,28}  => {9}  0.002328289 1          9.651685 2    
[8]  {9,23,35}  => {18} 0.002328289 1          7.099174 2    
[9]  {9,18,23}  => {35} 0.002328289 1          8.103774 2    
[10] {9,18,35}  => {23} 0.002328289 1          8.676768 2    
[11] {18,23,35} => {9}  0.002328289 1          9.651685 2    
[12] {1,9,23}   => {12} 0.002328289 1          6.983740 2    
[13] {5,9,30}   => {43} 0.002328289 1          6.872000 2    
[14] {9,30,43}  => {5}  0.002328289 1          7.218487 2    
[15] {6,9,28}   => {1}  0.002328289 1          7.040984 2    
[16] {9,21,29}  => {1}  0.002328289 1          7.040984 2    
[17] {9,17,29}  => {1}  0.002328289 1          7.040984 2    
[18] {9,27,29}  => {40} 0.002328289 1          6.817460 2    
[19] {9,29,40}  => {27} 0.002328289 1          6.817460 2    
[20] {9,27,40}  => {29} 0.002328289 1          8.103774 2 

# lift를 기준으로 규칙을 내림차순 정렬한 후, 30개의 규칙을 확인
rule_2 = sort(rule_1, by = 'lift', decreasing = T)
inspect(rule_2[1:30,])
     lhs              rhs  support     confidence lift     count
[1]  {32,38,43}    => {9}  0.002328289 1          9.651685 2    
[2]  {7,23,28}     => {9}  0.002328289 1          9.651685 2    
[3]  {18,23,35}    => {9}  0.002328289 1          9.651685 2    
[4]  {14,17,33}    => {9}  0.002328289 1          9.651685 2    
[5]  {7,23,29}     => {22} 0.002328289 1          9.336957 2    
[6]  {10,27,42}    => {22} 0.002328289 1          9.336957 2    
[7]  {25,31,45}    => {22} 0.002328289 1          9.336957 2    
[8]  {21,26,37}    => {22} 0.002328289 1          9.336957 2    
[9]  {24,36,38}    => {22} 0.002328289 1          9.336957 2    
[10] {7,24,31}     => {22} 0.002328289 1          9.336957 2    
[11] {7,31,34}     => {22} 0.002328289 1          9.336957 2    
[12] {33,36,37}    => {22} 0.002328289 1          9.336957 2    
[13] {10,34,36}    => {22} 0.002328289 1          9.336957 2    
[14] {10,34,36,44} => {22} 0.002328289 1          9.336957 2    
[15] {7,24,31,34}  => {22} 0.002328289 1          9.336957 2    
[16] {9,38,43}     => {32} 0.002328289 1          8.855670 2    
[17] {14,29,33}    => {32} 0.002328289 1          8.855670 2    
[18] {14,36,42}    => {32} 0.002328289 1          8.855670 2    
[19] {3,24,45}     => {32} 0.002328289 1          8.855670 2    
[20] {3,13,31}     => {32} 0.002328289 1          8.855670 2    
[21] {3,12,18}     => {32} 0.002328289 1          8.855670 2    
[22] {3,18,40}     => {32} 0.002328289 1          8.855670 2    
[23] {10,18,31}    => {32} 0.002328289 1          8.855670 2    
[24] {17,18,31}    => {32} 0.002328289 1          8.855670 2    
[25] {17,33,34}    => {32} 0.003492433 1          8.855670 3    
[26] {7,9,28}      => {23} 0.002328289 1          8.676768 2    
[27] {9,18,35}     => {23} 0.002328289 1          8.676768 2    
[28] {28,30,44}    => {23} 0.002328289 1          8.676768 2    
[29] {25,38,42}    => {23} 0.002328289 1          8.676768 2    
[30] {18,21,39}    => {23} 0.002328289 1          8.676768 2 

rule_2 = as(rule_2, 'data.frame') # data.frame으로 만들기

# 문제의 조건처럼 csv파일로 저장
write.csv(rule_2, file='___')
```

우선 로또의 경우 대표적인 독립적인 확률이기 때문에 아무런 연관성이 없을 것으로 생각이 크지만, 연관분석 결과 lift값이 생각보다 높게 측정되었음을 알 수 있다. 하지만, 지지도의 값이 0.002(0.2%)보다 약간 큰 값으로 역시 매우 연관성이 없을 알 수 있다.

### 3) 생성된 연관규칙 `'rules_1'`에 대한 정보를 해석하고 , 1)번 문제를 통해 확인했을 때 가장 많이 추첨된 번호가 우측항에 존재하는 규칙들만을 'rules_most_freq'라는 변수에 저장하고 해당 규칙들을 해석하여 인사이트를 도출하시오.

```R
# rule_1의 정보를 summary()함수로 요약
summary(rule_1)
set of 679 rules

rule length distribution (lhs + rhs):sizes
  4   5 
632  47 

   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  4.000   4.000   4.000   4.069   4.000   5.000 

summary of quality measures:
    support           confidence      lift           count      
 Min.   :0.002328   Min.   :1    Min.   :6.410   Min.   :2.000  
 1st Qu.:0.002328   1st Qu.:1    1st Qu.:7.041   1st Qu.:2.000  
 Median :0.002328   Median :1    Median :7.280   Median :2.000  
 Mean   :0.002364   Mean   :1    Mean   :7.434   Mean   :2.031  
 3rd Qu.:0.002328   3rd Qu.:1    3rd Qu.:7.670   3rd Qu.:2.000  
 Max.   :0.003492   Max.   :1    Max.   :9.652   Max.   :3.000  
mining info:
   data ntransactions support confidence
 lot_ts           859   0.002        0.8
# 679개의 연관규칙분석이 도출되었으며, 그 중 632개의 규칙은 4개의 로또번호로 구성
# 47개의 규칙은 5개의 번호로 구성되어 있음
# 향상도의 최소값은 6.410으로 꽤 높으며
# 지지도의 평균값은 0.002364로 같이포함될 확률이 1%도 되지 않음

rule_most_freq = subset(rule_1,rhs %in% '34')
inspect(rule_most_freq)
# 19개의 규칙이 도출
# 1번의 규칙 살펴보면 7, 22, 31이 뽑힌난 뒤에 34개 뽑힐 지지도는 0.002328289로 0.2%를 이야기하고 있다.
# 여기서 향상도 값이 6.4 이상으로 높은 값을 유지하고 있으나,
# 본 연관 분석의 문제는 단순히 조합에 의한 연관성을 분석했다는 것에 의해
# 분 분석에서 높은 확률로 나타날 조합이 꼭 로또 번호가 되는 것은 아니다.
```

## 2️⃣ 통계분석 FIFA 

### 1) FIFA데이터에서  각 선수의 키는 Height 변수에 피트와 인치로 입력되어 있습니다. 이름을 CM로 변환하여 새로운 변수 Height_cm를 생성하시오.

```R
FIFA = read.csv('FIFA.csv')
head(FIFA)
str(FIFA) # 구조 확인
sum(is.na(FIFA)) # 결측치 없음
# 1. height 변수의 피트, 인치 단위로 저장된 키에 대한 데이터를 cm 단위의 값으로 변환하고, Height_cm에 저장한다.
# Height는 factor형 자료임 바로 수치로 바꿀 수 없음
FIFA$Height = as.character(FIFA$Height) # 문자형으로 바꾸었다가 수치형으로 바꾸어야함.
# Height 변수를 보면 ' 가 껴있음... 앞의 숫자는 피트 뒤의 숫자는 인치를 뜻함.
# 따라서 앞의 숫자는 30을, 뒤의 숫자는 2.5를 곱하고 더해야 cm가 나옴.
# substr()은 문자열의 부분을 의미함. 피트는 두 자리 수일수 없으므로 1번째만 짜르고 3번째부터 끝까지가 숫자임
FIFA$Height_cm = as.numeric(substr(FIFA$Height, 1, regexpr("'",FIFA$Height)-1)) * 30 +
			   as.numeric(substr(FIFA$Height, regexpr("'",FIFA$Height)+1, nchar(FIFA$Height))) * 2.5
# regexpr는 패턴이 데이터에서 등장하는 index를 반환해줌
```

### 2) 포지션을 의미하는 Position변수를 'Forward', 'Mildfielder', 'Defender', 'GoalKeeper'로 재범주화화고 Factor형으로 변환 Position_class라는 변수를 생성하고 저장하시오

```R
# within()이라는 함수를 이용하여 선수의 포지션을 의미하는 position변수를 재범주화! -> Position_Class라는 변수에 저장
FIFA = within(FIFA,{
  position_Class = character(0)
  position_Class[Position %in% c('LS', 'ST', 'RS', 'LW', 'LF', 'CF', 'RF', 'RW')] = 'Forward'
  position_Class[Position %in% c('LAM', 'CAM', 'RAM', 'LM', 'LCM', 'CM', 'RCM', 'RM')] = 'Midfielder'
  position_Class[Position %in% c('LWB', 'LDM', 'CDM', 'RDM', 'RWB', 'LB', 'LCB', 'CB', 'RCB', 'RB')] = 'Defender'
  position_Class[Position == 'GK'] = 'GoalKeeper'
              })

FIFA$position_Class = factor(FIFA$position_Class,
                             levels=c('Forward', 'Midfielder', 'Defender','GoalKeeper'),
                             labels = c('Forward', 'Midfielder', 'Defender', 'GoalKeeper'))
str(FIFA)
```

### 3) 새로생성한 Position_Class 변수의 각 범주에 따른 Value의 평균값에 차이가 있는지 일원배치 분산분석을 실시하고 평균값이 통계적인 차이가 있는지 비교하시오.

```R
FIFA_aov = aov(Value~position_Class, data = FIFA)
summary(FIFA_aov)
                  Df    Sum Sq   Mean Sq F value Pr(>F)    
position_Class     3 4.081e+09 1.360e+09   41.87 <2e-16 ***
Residuals      16638 5.405e+11 3.249e+07                   
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

- 유의확률이 2e-16보다 작으므로 포지션에 따른 연봉의 차이는 유의미함. 단지 일원배치 분산분석은 집단 간의 평균에 차이가 있는지에 대한 분석이므로 어떤 집단이 더 큰 연봉을 갖고 있는지는 알 수 없음. 이를 위해 TukeyHSD분석을 실시 해야함.

```R
# R의 TukeyHSD함수를 이용하여 4가지 포지션들 중 특히나 어떠한 포지션들 간에 선수의 시장가치에 차이가 있는지를 파악하기 위한 사후검정!
# 분산분석의 사후분석은 TukeyHSD()함수

TukeyHSD(FIFA_aov)

  Tukey multiple comparisons of means
    95% family-wise confidence level

Fit: aov(formula = Value ~ position_Class, data = FIFA)

$position_Class
                            diff        lwr        upr     p adj
Midfielder-Forward     -169.4944  -507.0010   168.0122 0.5691282
Defender-Forward       -930.3730 -1250.0048  -610.7412 0.0000000
GoalKeeper-Forward    -1437.7579 -1865.9257 -1009.5900 0.0000000
Defender-Midfielder    -760.8787 -1035.0465  -486.7108 0.0000000
GoalKeeper-Midfielder -1268.2635 -1663.6509  -872.8761 0.0000000
GoalKeeper-Defender    -507.3848  -887.6282  -127.1415 0.0034079
```

- 사후분석에서는 귀무가설: `집단들 사이의 평균은 같다.` 대립가설: `집단들 사이의 평균은 같지않다.`로 두고, 모든 집단 수준에 대해서 두 집단씩 짝을 지어 각각 다중비교한다. 사후분석 결과 1개의 두 집단인 `Midfielder-Forward`를 제외한 나머지 모든 집단에서 연봉의 차이가 통계적으로 유의미하다고 도출되었다. 따라서 `Midfielder`와 `Forward` 둘 중 연봉이 어느 집단이 높은지는 말할 수 없다. 하지만 다른 결과들을 보았을 때, 그 차이가 명확한 점을 알아야한다.

### 4) Preferred_Foot(주로 사용하는 발)과 Position_Class(재범주화 된 포지션)변수에 따라 Value(연봉)의 차이가 있는지를 알아보기 위해 이원배치분산분석을 수행하고 결과를 해석 하시오.

- `귀무가설`
  - 선수의 주발에 따른 선수의 연봉에는 차이가 없다.
  - 선수의 포지션에 따른 선수의 연봉에는 차이가 없다.
  - 주발과 포지션 간 상호작용 효과는 없다.
- `대립가설`
  -  선수의 주발에 따른 선수의 연봉에는 차이가 있다.
  - 선수의 포지션에 따른 선수의 연봉에는 차이가 있다.
  - 주발과 포지션 간 상호작용 효과는 있다.

```R
FIFA_aov2 = aov(Value~Preferred_Foot+
                  position_Class+
                  Preferred_Foot:position_Class,
                data = FIFA)
summary(FIFA_aov2)
                                 Df    Sum Sq   Mean Sq F value  Pr(>F)
Preferred_Foot                    1 1.461e+08 1.461e+08   4.501 0.03390
position_Class                    3 4.087e+09 1.362e+09  41.976 < 2e-16
Preferred_Foot:position_Class     3 4.736e+08 1.579e+08   4.864 0.00221
Residuals                     16634 5.399e+11 3.246e+07                
                                 
Preferred_Foot                *  
position_Class                ***
Preferred_Foot:position_Class ** 
Residuals                        
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
```

- 이원배치 분산분석 결과 `5% `유의수준 하에서 주발의 유의확률은 `0.03390`, 포지션의 유의확률은 `2e-16`로 귀무가설을 기각하여 대립가설을 선택한다. 이를 통해 주발과 포지션은 선수의 연봉의 차이에 영향을 미치고 있었으며, 주발과 포지션은 상호작용효과를 갖고 있었다. 단 이원배치 분산분석을 통해 연봉 변동의 원인이 주발과 포지션이라는 것은 알 수 있으나, 이 요소가 `+`방향으로 영향을 주는지` -`방향으로 영향을 주는지 알 수 없다.

### 5) Age, Overall, Wage, Height_cm, Weight_lb 가 Value에 영향을 미치는지 알아보는 회귀분석을 단계적 선택법으로 수행하고 결과를 해석하시오.

바로 회귀분석을 돌려보자

```R
step(lm(Value~1, # 처음 회귀분석을 돌릴때의 모습
        data=FIFA),
     scope=list(lower=~1, # 상수 회귀에서
                upper=~Age+Overall+Wage+Height_cm+Weight_lb), # 문제에서 이야기한 모든 변수를 넣은 회귀
     direction = 'both') # 단계적 선택법

Start:  AIC=287969.5
Value ~ 1

            Df  Sum of Sq        RSS    AIC
+ Wage       1 4.0424e+11 1.4037e+11 265409
+ Overall    1 2.1561e+11 3.2900e+11 279584
+ Age        1 3.1824e+09 5.4143e+11 287874
+ Weight_lb  1 1.0611e+09 5.4355e+11 287939
<none>                    5.4461e+11 287969
+ Height_cm  1 1.9447e+06 5.4461e+11 287971

Step:  AIC=265408.8
Value ~ Wage

            Df  Sum of Sq        RSS    AIC
+ Overall    1 1.4741e+10 1.2563e+11 263564
+ Age        1 1.4800e+09 1.3889e+11 265234
+ Height_cm  1 1.3065e+08 1.4024e+11 265395
+ Weight_lb  1 7.9650e+07 1.4029e+11 265401
<none>                    1.4037e+11 265409
- Wage       1 4.0424e+11 5.4461e+11 287969

Step:  AIC=263564.5
Value ~ Wage + Overall

            Df  Sum of Sq        RSS    AIC
+ Age        1 1.1662e+10 1.1397e+11 261945
+ Weight_lb  1 7.0549e+08 1.2493e+11 263473
+ Height_cm  1 2.3851e+08 1.2539e+11 263535
<none>                    1.2563e+11 263564
- Overall    1 1.4741e+10 1.4037e+11 265409
- Wage       1 2.0337e+11 3.2900e+11 279584

Step:  AIC=261945.2
Value ~ Wage + Overall + Age

            Df  Sum of Sq        RSS    AIC
+ Height_cm  1 5.1404e+07 1.1392e+11 261940
+ Weight_lb  1 4.9934e+07 1.1392e+11 261940
<none>                    1.1397e+11 261945
- Age        1 1.1662e+10 1.2563e+11 263564
- Overall    1 2.4922e+10 1.3889e+11 265234
- Wage       1 1.8259e+11 2.9656e+11 277858

Step:  AIC=261939.7
Value ~ Wage + Overall + Age + Height_cm

            Df  Sum of Sq        RSS    AIC
<none>                    1.1392e+11 261940
+ Weight_lb  1 6.1905e+06 1.1391e+11 261941
- Height_cm  1 5.1404e+07 1.1397e+11 261945
- Age        1 1.1475e+10 1.2539e+11 263535
- Overall    1 2.4906e+10 1.3883e+11 265228
- Wage       1 1.8264e+11 2.9656e+11 277860

Call:
lm(formula = Value ~ Wage + Overall + Age + Height_cm, data = FIFA)

Coefficients:
(Intercept)         Wage      Overall          Age    Height_cm  
  -8690.818      184.184      241.345     -202.160       -8.445  
```

- 분석 결과 문제에서 이야기한 모든 변수를 회귀모형의 독립변수로 대입하였을 때, `AIC`값이 가장 낮았으며, 최적의 모형이라 할 수 있다. 따라서 문제에서 이야기한 단계적 선택법을 활용한 최적의 회귀모형은 다음과 같다.

`y = -8690.818 + 184.184*Wage + 241.345*Overall - 202.160*Age - 8.445*Height_cm`

- 이 변수들을 선택하여 회귀분석을 실시한다.

```R
FIFA_lm = lm(formula = Value ~ Wage + Overall + Age + Height_cm, data = FIFA)
summary(FIFA_lm)

Call:
lm(formula = Value ~ Wage + Overall + Age + Height_cm, data = FIFA)

Residuals:
   Min     1Q Median     3Q    Max 
-24272   -837   -120    668  58287 

Coefficients:
             Estimate Std. Error t value Pr(>|t|)    
(Intercept) -8690.818    588.280  -14.77  < 2e-16 *** # 유의
Wage          184.184      1.128  163.32  < 2e-16 *** # 유의
Overall       241.345      4.002   60.31  < 2e-16 *** # 유의
Age          -202.160      4.938  -40.94  < 2e-16 *** # 유의
Height_cm      -8.445      3.082   -2.74  0.00615 **  # 유의
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 2617 on 16637 degrees of freedom
Multiple R-squared:  0.7908,	Adjusted R-squared:  0.7908 
F-statistic: 1.572e+04 on 4 and 16637 DF,  p-value: < 2.2e-16
```

- 회귀분석 결과 모든 독립변수가 `5%` 유의수준 하에서 통계적으로 유의미함을 알 수 있으며, 주급과 선수의 능력치는 연봉에 `+`영향을 나이와 키는 `- `영향을 주는 것을 알 수 있다. 특히나 축구선수의 빠른 은퇴의 원인으로 빠르게 감소하는 연봉이 어느 정도 영향을 미쳤을 것이라는 인사이트를 이야기할 수 있다. 모형의 `R_squared` 값도 `0.7908`로 전체 변동의 약 `79%` 설명할 만큼 좋은 결과를 내놓은 것을 확인할 수 있다. 모형의 유의성 역시 유의확률이 `2.2e-16`보다 작게 나와 `0.01%`에서도 유의함을 알 수 있다.