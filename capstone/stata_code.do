clear all

capture log close

set logtype s

cd E:\24老年社会参与和心理健康

log using Social_Participation, text replace 

set more off

********************************************
/***********数据处理*********************/
********************************************

*******2020CHARLS********

cd "E:\24老年社会参与和心理健康\charls2020\data"

use "Demographic_Background", clear

* 只留下能依靠自己回答采访问题的受访者
codebook proxy_2
keep if proxy_2 == 2 | proxy_2 == .

* 年龄
codebook xrage
* codebook xrage if xrage <=45
* tab xrage if xrage <= 45
keep if xrage >= 60 & xrage <=90 // 保留年龄60-90的群体，老年群体
* tab xrage
* gen mid_age = (xrage >= 45) & (xrage <= 59) // 45-59岁的为中年人
gen low_age = (xrage >= 60) & (xrage <= 74) // 60-74岁的为低龄老年人
gen high_age = (xrage >= 75) & (xrage <= 90) // 75-90岁的为高龄老年人
gen age = xrage

label variable age "Age"
label variable low_age "60<= Age <=74"
label variable high_age "75<= Age <=90"

codebook age

* 居住地
codebook ba008
gen resid = (ba008 == 3) // Village=1

label variable resid "Residence"
label define resid_va 0 "Other" 1 "Village", replace
label values resid resid_va

codebook resid

* 性别
codebook xrgender
gen gender = (xrgender == 2) // 女性=1 男性=0

label variable gender "Gender"
label define gender_va 0 "Male" 1 "Female", replace
label values gender gender_va

codebook gender

* 婚姻状况
codebook xrpartner // miss0
gen partner = (xrpartner == 1) // 婚姻状况：有配偶/伴侣=1 没有=0

label variable partner "Spouse/Partner"
label define partner_va 1 "With spouse/partner" 0 "No spouse/partner", replace
label values partner partner_va

codebook partner

* 医疗保险
codebook ba016
gen medi = (ba016 != 3) // 是否拥有医疗保险：有=1 无=0

label variable medi "Social medical insurance"
label define medi_va 1 "With Social medical insurance" 0 "No Social medical insurance", replace
label values medi medi_va

codebook medi

* 上半年独居情况
codebook ba018
gen lone = (ba018 != 0) // 独居=1

label variable lone "lived alone in the first half of this year"
label define lone_va 1 "Lived Alone" 0 "Not Lived Alone", replace
label values lone lone_va

codebook lone

save "E:\24老年社会参与和心理健康\charls2020\Demo_ID", replace

cd "E:\24老年社会参与和心理健康\charls2020\data"
use "Health_Status_and_Functioning.dta", clear

merge 1:1 ID using E:\24老年社会参与和心理健康\charls2020\Demo_ID
keep if _merge == 3
drop _merge

codebook proxy_5
keep if proxy_5 == 2 | proxy_5 == .

* 过去一年的住院情况
codebook da007
drop if da007 == .
gen hospital = (da007 == 1)

label variable hospital "Hospitalizations in the past year"
label define hospital_va 1 "Hospitalized" 0 "Not hospitalized", replace
label values hospital hospital_va

codebook hospital

* 过去一个月的社会参与情况

codebook da038_s9
drop if da038_s9 == .
gen social = (da038_s9 != 9)

label variable social "Social participation"
label define social_va 1 "With social participation" 0 "No social participation", replace
label values social social_va

codebook social

* 社会参与活跃度
codebook da038_s1-da038_s9
forvalues i = 1/8 {
	
	gen social_activity_`i' = (da038_s`i' == `i')
		
}
sum social_activity_1-social_activity_8

codebook da039_1_-da039_8_
sum da039_1_-da039_8_
recode da039_1_-da039_8_ (1=3)(2=2)(3=1)(.=0)

label define da039_va 3 "Almost Daily" 2 "Almost Every Week" 1 "Not Regularly", replace
label values da039_1_-da039_8_ da039_va

codebook da039_1_-da039_8_

forvalues i = 1/8 {
	
	gen social_level_`i' = social_activity_`i' * da039_`i'_
		
}

sum social_level_1-social_level_8

egen social_level = rsum(social_level_1-social_level_8)
sum social_level
* 均值为1.27，>=2 高活跃度，否则为低
kdensity social_level

gen dum_social_level = (social_level >= 2)

label variable dum_social_level "Social participation activation"
label define social_level_va 1 "High Social participation activation" 0 "Low Social participation activation"
label values dum_social_level social_level_va

* 上网 Used the internet
codebook da040
drop if da040 == .

gen inte = (da040 == 1)

label variable inte "Internet access"
label define inte_va 1 "Used the internet" 0 "Not on the Internet", replace
label values inte inte_va

codebook inte

* 抑郁情况（心理健康）
codebook dc016 dc017 dc018 dc019 dc020 dc021 dc022 dc023 dc024 dc025 

global deprelist dc016 dc017 dc018 dc019 dc020 dc021 dc022 dc023 dc024 dc025
foreach var in $deprelist {
	drop if `var' == . | `var' == 997 | `var' == 999
}
* drop if dc016 == . | dc016 == 997 | dc016 == 999
sum dc016 dc017 dc018 dc019 dc020 dc021 dc022 dc023 dc024 dc025

recode dc016 (1=0)(2=1)(3=2)(4=3)
recode dc017 (1=0)(2=1)(3=2)(4=3)
recode dc018 (1=0)(2=1)(3=2)(4=3)
recode dc019 (1=0)(2=1)(3=2)(4=3)
recode dc021 (1=0)(2=1)(3=2)(4=3)
recode dc022 (1=0)(2=1)(3=2)(4=3)
recode dc024 (1=0)(2=1)(3=2)(4=3)
recode dc025 (1=0)(2=1)(3=2)(4=3)

recode dc020 (1=3)(2=2)(3=1)(4=0)
recode dc023 (1=3)(2=2)(3=1)(4=0) 

egen depre = rsum(dc016 dc017 dc018 dc019 dc020 dc021 dc022 dc023 dc024 dc025)
codebook depre
kdensity depre

label variable depre "Depression level"

save "E:\24老年社会参与和心理健康\charls2020\Health_ID", replace


use "Family_Information.dta", clear
merge 1:m householdID using E:\24老年社会参与和心理健康\charls2020\Health_ID
keep if _merge == 3
drop _merge

* 健在子女数量
codebook xchildalivenum 
gen numchid = xchildalivenum

label variable numchid "Number of living children"

sum numchid

save "E:\24老年社会参与和心理健康\charls2020\Family_householdID", replace

use "Work_Retirement.dta", clear

merge 1:1 ID using E:\24老年社会参与和心理健康\charls2020\Family_householdID
keep if _merge == 3
drop _merge

codebook proxy_7
keep if proxy_7 == 2 | proxy_7 == .

* 就业情况Working
codebook fa001 fa004 fa007 fa008
codebook xworking

gen work = xworking

label variable work "Working"
label define work_va 1 "Work" 0 "No work"
label values work work_va 

codebook work

save "E:\24老年社会参与和心理健康\charls2020\Work_ID", replace

cd "E:\24老年社会参与和心理健康\charls2020\data"

use "Household_Income.dta", clear

merge 1:m householdID using E:\24老年社会参与和心理健康\charls2020\Work_ID
keep if _merge == 3
drop _merge


* 是否为贫困户
codebook ge001_s6
drop if ge001_s6 ==.

gen poor = (ge001_s6 == 0)

label variable poor "Poor household"
label define poor_va 1 "Poor" 0 "Non-poor"
label values poor poor_va 

codebook poor

save "E:\24老年社会参与和心理健康\charls2020\Income_householdID", replace

*******2018CHARLS********

cd "E:\24老年社会参与和心理健康\charls2018\data"

use "Demographic_Background", clear

merge 1:1 ID using E:\24老年社会参与和心理健康\charls2020\Income_householdID
keep if _merge == 3
drop _merge

* Education教育水平：最高学历本科及以上 = 1
tab bd001_w2_4
gen educ_2018 = (bd001_w2_4>=9)

label variable educ_2018 "Education"
label define educ_2018_va 1 "Bachelor's degree and above" 0 "Below bachelor's degree"
label values educ_2018 educ_2018_va 

codebook educ_2018

save "E:\24老年社会参与和心理健康\charls2018\Demo_ID", replace

use "Health_Status_and_Functioning", clear

merge 1:1 ID using E:\24老年社会参与和心理健康\charls2018\Demo_ID
keep if _merge == 3
drop _merge

* 社会参与2018
codebook da056_s12
drop if da056_s12 == .
gen social_2018 = (da056_s12 != 12)

label variable social_2018 "Social participation in 2018"
label define social_2018_va 1 "With social participation" 0 "No social participation"
label values social_2018 social_2018_va 

codebook social_2018

save "E:\24老年社会参与和心理健康\data\merged", replace

************************************
/*       2011                    **/
************************************
cd "E:\24老年社会参与和心理健康\charls2011\data"
use "community", clear

* 社区是否有老年活动中心或者棋牌室
codebook jb029_1_5_ jb029_1_11_ jb029_1_8_
local varlist jb029_1_5_ jb029_1_11_ jb029_1_8_

foreach var in `varlist' {
	
	drop if `var' == .
	drop if `var' == .d


}
gen activecard = (jb029_1_5_==1) | (jb029_1_11_==1) // 社区是否有老年活动中心或者棋牌室：有=1，无=0
codebook activecard

label variable activecard "=1 if V/C has senior center or boardroom in 2010"


* 社区是否有舞蹈队或锻炼队
gen dance = (jb029_1_8_==1) // 社区是否有舞蹈队或锻炼队：有=1，无=0

label variable dance "=1 if V/C has dance or workout team in 2010"

* 自从2000年以来，村或社区曾经是否被征地。财产权保护
codebook ja035
drop if ja035 == .d
gen exprop = (ja035==1) // 有=1

label variable exprop "=1 if community was once expropriated"

* 地形
codebook ja038
drop if ja038 == .d 
gen land = ja038

label variable land "Main terrain of the community"

* 居委会主任的教育水平

* 村/社区的路况
codebook jb001
* gen road = jb001
rename jb001 road
codebook road

* 2010年饮用净化的自来水的情况
codebook jb006_1

* 冬天是否有集中供暖
codebook jb008
* rename jb008 Heat
gen heat = (jb008 == 1)

label variable heat "=1 if V/C Have Heating System for Winter"

* 下水道系统
codebook jb010
gen sew = (jb010 == 1)

label variable sew "=1 if V/C Have Sewer System"

* 是否有公共厕所, 卫生环境
codebook jb014
gen pubres = (jb014==1) // 有=1

* 通电情况
codebook jb020
list jb020 if missing(jb020)
drop if jb020 == .r
* codebook jb020
kdensity jb020
sum jb020
* tab jb020 // 2社区1年通电天数小于30天
gen light = (jb020>=357) // 一年供电的天数>=均值（357）=1，良好=1


save "E:\24老年社会参与和心理健康\charls2011\community", replace

use "E:\24老年社会参与和心理健康\charls2011\community", clear
duplicates report communityID
duplicates drop communityID, force

save "E:\24老年社会参与和心理健康\charls2011\community", replace


cd "E:\24老年社会参与和心理健康\Draft_table"
use "E:\24老年社会参与和心理健康\data\merged", clear

merge m:1 communityID using E:\24老年社会参与和心理健康\charls2011\community
keep if _merge == 3
drop _merge

save "E:\24老年社会参与和心理健康\data\final_comu_data.dta", replace

global demo_vlist age resid gender partner educ_2018
global beha_vlist medi lone hospital inte work
global hous_vlist poor numchid

sum depre social $demo_vlist $beha_vlist $hous_vlist exprop pubres light land

reg depre social $demo_vlist $beha_vlist $hous_vlist exprop pubres light land, robust

ivregress 2sls depre $demo_vlist $beha_vlist $hous_vlist exprop pubres light land  (social = activecard), robust
estat endogenous // 6.15888  (p = 0.0131)
estat firststage // 20.1142

log close
