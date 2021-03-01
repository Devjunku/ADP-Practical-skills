# R을 활용한 이원배치 분산분석

data(mtcars) # 데이터 불러오기

str(mtcars) # 데이터 구조확인

# aov 함수를 사용하기 위해서는 무조건, factor형 변수로 변환해야함.
mtcars$cyl = as.factor(mtcars$cyl) # as는 강제로 데이터를 변환한다는 의미
mtcars$am = as.factor(mtcars$am)

car = mtcars[, c("cyl", "am", "mpg")] # 해당 열만 따로 추출
str(car) # 데이터 구조확인

# aov(formula, data)
car_aov = aov(mpg ~ cyl * am, car) # 이원배치 분산분석 실시
summary(car_aov) # 결과값 확인

# interaction.plot(x.factor, trace.factor, response)
# x.factor : x축에 그릴 변수
# trace.factor : 그래프로 표현할 그룹변수
# response : 반응변수값을 저장한 벡터
# 그외 속성을 지정할 인자들이 존재함.
interaction.plot(car$cyl, car$am, car$mpg, col = c("red", "blue"))

# interaction.plot에서 2개의 선이 겹쳐있다면, 교호작용이 있다는 의미임.
