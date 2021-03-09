# ⭕ Term-Documet Matrix

전처리된 데이터(텍스트)에서 각 문서와 단어 간의 사용 여부를 이용해 만들어진 matrix가 바로 TDM(Term-Document Matrix)임.

TDM을 통해 문서마다 등장한 단어의 빈도수를 쉽게 파악할 수 있다는 장점이 있음.

## 1️⃣ R을 활용한 TDM 구축

R프로그램에서는 tm패키지에서 TermDocumentMatrix() 함수를 통해 TDM을 구축할 수 있음. 실행 결과에서 행은 각 단어를 나타내고, 열은 각 문서를 의미하게 되어 각 문서에 행의 단어에 대한 빈도를 확인할 수 있음.

```R
TermDocumentMatrix(data, control)
# data: COrpus형태의 데이터
# control: 사전 변경, 가중치 부여 등의 옵션 추가기능 지원
```

```R
VC.news = VCorpus(VectorSource(clean_news2))
VC.news[[1]]$content
[1] "동아대학교총장 한석정가 수요자 데이터기반 스마트헬스케어 서비스분야  차 산업혁명 혁신선도대학으로 최종선정됐습니다 동아대가 혁신선도대학으로 펼치게 될  수요자 데이터기반 스마트헬스케어 서비스  산업은 리빙데이터운동 영양 약물와 메디컬데이터생체계측 진료기록를 종합 분석 다양한 헬스케어 서비스를 제공하는 것입니다 동아대는 건강과학대학과 의료원 재활요양병원 등 경쟁력 있는 인프라를 바탕으로 신뢰도 높은 정밀 분석을 실시  헬스케어 기획 전문가 와  헬스케어 데이터분석 전문가  등 수요자 맞춤형 헬스케어 서비스 분야를 선도하는 전문 인재를 키워나갈 계획입니다  스마트헬스케어 융합전공 을 신설 경영정보학과를 중심으로 한 빅데이터 분석 식품영양학과 의약생명공학과 건강관리학과 중심의 헬스케어 등 학문 간 경계는 교육혁신도 이뤄나갈 방침입니다 "
TDM_news = TermDocumentMatrix(VC.news)
dim(TDM_news)
[1] 1011   10

inspect(TDM_news[1:5,])
<<TermDocumentMatrix (terms: 5, documents: 10)>>
Non-/sparse entries: 5/45
Sparsity           : 90%
Maximal term length: 8
Weighting          : term frequency (tf)
Sample             :
           Docs
Terms       1 10 2 3 4 5 6 7 8 9
  academy는 0  0 0 0 1 0 0 0 0 0
  ai가      0  1 0 0 0 0 0 0 0 0
  ai를      0  0 0 1 0 0 0 0 0 0
  ai와      0  1 0 0 0 0 0 0 0 0
  ai의      0  0 0 0 1 0 0 0 0 0
```

- 전처리가 완료된 `clean_news2` 데이터를 `VC.news`에 Corpus 형태로 저장하고 `VC.news` 데이터를 `TermDocumentMatrix()` 함수를 이용하여 `TDM`을 구축함.
- `dim()`함수를 통해 10개의 기사에서 1011개의 단어가 추출되었다는 것을 확인할 수 있으며, `inspect()`함수로 `TDM` 구축 결과를 확인할 수 있음
- `TDM` 결과를 확인하면, 10개의 문서에서 1~5번째 단어의 분포를 확인할 수 있음. 여기서 `'academy는'`이 3번 문서에서 1번 사용되었음을 알 수 있음. 대부분의 단어가 모든 문서에서 이용되지 않으므로 조회한 내용의 10개 문서와 5개 단어에 대해 사용된 단어는 0 이상의 숫자로 빈도를 나타내고 사용되지 않은 것은 0으로 표현됨. (그니까 대부분 사용 안된거임 -> 문서간 공통적인게 없다는 의미)
- `sparsity`의 경우 전체 행렬에서 0이 차지하는 비중인데, 45/50이니 90%에 해당

```R
words = function(doc) {
  doc = as.character(doc)
  extractNoun(doc)
}


TDM_news2 = TermDocumentMatrix(VC.news, control = list(tokenize = words))
dim(TDM_news2) # 10개의 기사 중 289개의 단어가 추출되었고 289개의 행과 10개의 열을 가지는 형태
[1] 289  10

inspect(TDM_news2)
<<TermDocumentMatrix (terms: 289, documents: 10)>>
Non-/sparse entries: 360/2530
Sparsity           : 88%
Maximal term length: 14
Weighting          : term frequency (tf)
Sample             :
            Docs
Terms        1 10 2 3 4  5  6 7 8 9
  경쟁력     1  0 0 2 0  1  1 0 1 1
  경진대회   0  0 0 0 1  0  0 2 0 5
  관계자     0  1 0 1 0  3  0 1 0 0
  광양제철소 0  0 0 0 0  0  0 0 0 6
  데이터     3  6 3 7 8  7 10 3 5 5
  브라이틱스 0  0 0 0 9  0  0 0 0 0
  빅데이터   1  4 4 1 3 16  0 2 1 6
  서비스     3  3 3 0 0  7  3 1 0 0
  시스템     0  2 0 2 1  3  0 0 0 0
  전문가     2  1 1 4 1  1  1 1 2 1
tdm2 = as.matrix(TDM_news2)
tdm3 = rowSums(tdm2)
tdm4 = tdm3[order(tdm3, decreasing = T)]
tdm4[1:10]
 데이터   빅데이터     서비스     전문가    브라이틱스   경진대회     시스템     경쟁력   관계자    광양제철소 
57         38         20         15          9          8          8          7       6          6 
```

- `'academy'는`과 같은 명사 뒤에 조사가 붙는 경우가 있다. `extractNoun()`함수를 통해 명사만 추출하여 TDM을 다시 구축하면 위와 같은 결과가 나타남. 모든 문서의 단어 빈도를 분석한 후 상위 10개를 추출한 것인데, `'데이터'`, `'빅데이터'` 등 순서로 단어의 빈도를 확인할 수 있음.

```R
mydict = c('빅데이터', '스마트', '산업혁명', '인공지능', '사물인터넷', 'AI', '스타트업', '머신러닝')
my_news = TermDocumentMatrix(VC.news, control=list(tokenize=words, dictionary=mydict))
inspect(my_news)
<<TermDocumentMatrix (terms: 8, documents: 10)>>
Non-/sparse entries: 21/59
Sparsity           : 74%
Maximal term length: 5
Weighting          : term frequency (tf)
Sample             :
            Docs
Terms        1 10 2 3 4  5 6 7 8 9
  AI         0  0 0 0 0  0 0 0 0 0
  머신러닝   0  0 0 0 0  0 0 0 0 0
  빅데이터   1  4 4 1 3 16 0 2 1 6
  사물인터넷 0  0 0 0 0  0 0 0 0 0
  산업혁명   1  0 2 0 0  0 0 0 1 1
  스마트     3  0 2 0 0  0 0 0 0 1
  스타트업   0  0 0 0 0  2 1 0 0 0
  인공지능   0  1 1 0 0  0 0 0 1 0
```

- 분석하고자하는 데이터를 사전으로 만든 뒤(사실상 문자열 벡터) 해당 문자가 몇개가 나왔는지 알 수 있음.

## 2️⃣ `TDM`을 활용한 분석 및 시각화

- `TDM`을 구축하고 구축된 데이터로 단어를 분석하고 시각화 할 수 있음.

### ✔ 연관성 분석

- 작성된 `TDM`에서 특정 단어와의 연관성에 따라 단어를 조회할 수 있음. `findAssocs()` 함수를 통해 `TDM`과 연관된 단어와의 연관성이 일정 수치 이상인 단어들만 표시할 수 있음.

```R
findAssocs(data, terms, corlimit)
# data: TDM 형태의 데이터
# terms: 연관성을 확인할 데이터
# corlimit: 최소연관성
```

`VC.news` 데이터를 명사만 추출하는 `TDM`으로 변경한 후 빅데이터라는 단어와의 연관성이 0.9 이상인 단어들만 추출!

```R
words = function(doc) {
  doc = as.character(doc)
  extractNoun(doc)
}

TDM_news2 = TermDocumentMatrix(VC.news, control=list(tokenize=words))
findAssocs(TDM_news2, '빅데이터', 0.9) # 빅데이터란 단어와 무슨 내용이 연관되어 함께 언급되는지 알 수 있음.
```

- 구축된 `TDM`과 '빅데이터'라는 단어와의 연관성을 파악한 결과, '가맹점', '개발자' 등의 단어들이 연관된 단어로 나타나며, 연관성에 대한 수치도 해당 단어 아래에 같이 표시됨.

### ✔ 워드 클라우드

- 문서에 포함되는 단어의 사용 빈도를 효과적으로 보여주기 위한 막대그래프 등의 시각화 도구가 있지만, `wordcloud()`를 이용하여 더 효율적으로 보여줄 수 있음.

```R
wordcloud(words, freq, min.freq, random.order, colors)
# words: 워드클라우드를 만들고자 하는 단어
# freq: 단어의 빈도
# min.freq: 시각화하려는 단어의 최소 빈도
# random.order: 단어의 배치를 랜덤으로 할지 정함. F일 때, 빈도순으로 그려짐.
# colors: 빈도에 따라 단어의 색을 지정
```

```R
library(wordcloud)
tdm2 = as.matrix(TDM_news2)
term.freq = sort(rowSums(tdm2), decreasing = T)
head(term.freq, 15)

wordcloud(words = names(term.freq), # term.freq의 이름만 가져옴
          freq = term.freq,
          min.freq = 5,
          random.order = F,
          colors = brewer.pal(8, 'Dark2'))
```

![wordcloud](.\img\wordcloud.png)

- `TDM`을 `Matrix`형태로 변환하여 행 결합을 통해 각 단어마다 빈도를 합쳐 내림차순으로 정렬 `term.freq` 데이터에 저장하고 `head()` 함수를 통해 확인 가능.
- `wordcloud()` 함수로 `term.freq` 데이터에서 단어만 가져오고, 빈도는 `term.freq`의 빈도로 지정, 최소 빈도 5로 하여 워들을 그림.