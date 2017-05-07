libname Project "C:\Users\axx160830\Desktop\MKT SAS PROJECT";
data appeals;
set Project.appeals;
Dnr_id= put(donor_id,8.);
drop donor_id;
run;
data Donations;
set Project.Donations;
Dnr_id= put(donor_id,8.);
zip=put(zipcode,z5.);
drop donor_id;
drop zipcode;
run;

**************************/*DISCRIPTIVE STATISTICS */*******************************
proc contents data = appeals;
run;
	/* response time*/
PROC SQL;
CREATE TABLE DEG  AS SELECT distinct appeal_id, dnr_id ,appeal_date , gift_date FROM A group by appeal_id, dnr_id; 
QUIT;
proc sql;
create table appealresponse as select dnr_id, appeal_id, appeal_date , gift_date from A  group by appeal_id, dnr_id;
quit;

proc sql;
create table appealresponse_appeal as select distinct dnr_id, appeal_id, appeal_date , gift_date from A ;
quit;
proc sql;
create table resp as select dnr_id, appeal_id, appeal_date , gift_date,
 case 
    when gift_date is null  then '0'
   else '1'
 end
from deg;
quit;

proc sql;
create table resp_1 as
select appeal_id, _TEMA001 from resp ;
quit;
proc sql;
create table dnrresp_1 as
select dnr_id, _TEMA001 from resp ;
quit;
 data resp_1;
 set resp_1;
x1=input(_TEMA001,best12.); 
run;
 data dnrresp_1;
 set dnrresp_1;
x1=input(_TEMA001,best12.); 
run;
proc sql; 
create table  resp_app_1 as select appeal_id ,SUM(x1 ) as sum , count(x1) as count  from resp_1  group by appeal_id;
quit;
proc sql; 
create table  dnrresp_app_1 as select dnr_id ,SUM(x1 ) as sum , count(x1) as count  from dnrresp_1  group by dnr_id;
quit;

proc sql; 
create table  dnrresp_app_4 as select dnr_id , sum , count,  (sum/count)*100 as resp from dnrresp_app_1;
quit;
proc contents  data =  dnrresp_app_4;
quit;

proc sql;
select sum(count) as sum_adnr , avg(resp) as average_response, max(resp) as max , min(resp) as min from dnrresp_app_4;
quit;

proc sql; 
select sum(count)  from resp_app_1;
quit;
proc sort data=  resp_app_4 ;
by descending resp;
quit;

proc means data = resp_app_4 ;
var sum  count resp;
quit;

proc contents data
proc=resp_1;
quit;
proc sql; 
create table  resp_app_2 as select appeal_id , count(_TEMA001='0') as a_1  from resp_1  group by appeal_id;
quit;

proc sql;create table resp_2 as
select dnr_id, _TEMA001 from resp ;
quit;



/*checking variables in appeals*/

data notnull;
set notnull;
zipcode=put(zip,5.);
drop zipcode;
run;


proc sort data=donations;
by descending dnr_id;
run;
proc contents data = donations;
run;
proc freq data= appeals;
table appeal_id/out=Work.appealsfreq;
run;
proc sort data=appealsfreq;
by descending percent;
run;
proc sql;
create table appeal_sum as 
select distinct appeal_id, sum(appeal_cost) as sum from appeals group by appeal_id;
quit;

proc sql;
create table sap as 
select appeal_id, sum(appeal_cost) as appealsum, sum(gift_amount) as dnrsum from notnull group by appeal_id;
quit;
proc sql;
create table sap_1 as 
select appeal_id,appeal_cost , gift_amount from notnull group by appeal_id;
quit;
proc means data = sap_1;
run;

proc sort data= appeal_sum;
by descending sum;
run;
proc freq data= appeals;
table dnr_id/out=Work.donorfreq;
run;
proc sort data=donorfreq;
by descending percent;
run;
proc sql;
select * from donorfreq where dnr_id='9825928';
quit;

proc sql;
create table donor_appeal_sum as 
select distinct dnr_id, sum(appeal_cost) as sum from appeals group by dnr_id  ;
quit;
proc sort data= donor_appeal_sum;
by descending sum;
run;
proc freq data= donations;
table dnr_id/out=Work.dnrfreq;
run;
proc sort data=dnrfreq;
by descending percent;
run;
proc sql;
create table donor_giftsum as 
select distinct dnr_id, sum(gift_amount) as sum from donations group by dnr_id;
quit;
proc sort data= donor_giftsum;
by descending dnr_id;
run;
proc sql;
select * from donor_giftsum where dnr_id='8203945';
quit;
proc freq data=donations noprint;
table zip*dnr_id/out=WORK.StatMETA;
run;
proc sort data= StatMETA; 
by descending percent;
run;
proc means data= appeals;
title "Mean for appeals";
var appeal_cost;
run;
proc means data= donations;
title "Mean for donations";
var gift_amount;
run;
proc sql;
create table zip_amount;
select donations noprint;
table zip*dnr_id*gift_amount/out=WORK.StatMETA_1;
run;
proc contents data = StatMETA;
run;

/*checking variables in donations*/
proc contents data = notnull;
run;
proc contents data = us_postal_codes;
run;

/*means in data*/
proc means data = Appeals;
var appeal_cost;
run;
proc means data = Donations;
var gift_amount;
run;
/*aggregating appeals and donations data */
proc sort data=Appeals;
by appeal_id Dnr_id;
run;
proc sort data=Donations;
by appeal_id Dnr_id;
run;
/*merging appeals with donations */
PROC SORT DATA= appeals;
 BY appeal_id, dnr_id;
RUN;

proc sql;
create table merged as
      select A.dnr_id,A.appeal_id,A.appeal_date,A.appeal_cost,D.Gift_date,D.Gift_amount,D.Appeal_id as Responded_Appeal_id,D.Zip,D.First_gift_date
      from appeals A INNER Join Donations D
      on A.Dnr_id = D.Dnr_id and A.Appeal_id = D.Appeal_id;
quit;
proc sql;
create table merged_DIS as
select distinct A.dnr_id,A.appeal_id from merged A;
QUIT;
proc sql;
create table donated_sum as select distinct dnr_id , sum(gift_amount) as sum from merged group by dnr_id;
quit;
proc sort data=donated_sum;
by descending sum;
quit;

proc sql;
create table merged_c as
select distinct dnr_id, appeal_id, appeal_date from merged  
GROUP BY dnr_id,appeal_id, appeal_date having count(*)>1;
QUIT;
proc sql;
create table merged_c as
select distinct dnr_id, appeal_id , sum(gift_amount) as sum from merged  
GROUP BY dnr_id,appeal_id  having count(*)>100;
QUIT;

proc sql;
create table final_merged as
      select A.dnr_id,A.appeal_id,A.appeal_date,A.appeal_cost,A.Gift_date,A.Gift_amount,A.Zip,A.First_gift_date,D.State,D.State_Abbreviation
      from notnull A Join us_postal_codes D
      on A.zip = D.zip;
quit;
data Project.final_merged;
set Work.final_merged;
run;

/*responded appeals vs non responded*/
proc sql;
create table left_merged as
      select A.dnr_id,A.appeal_id,A.appeal_date,A.appeal_cost,D.Gift_date,D.Gift_amount,D.Appeal_id as Responded_Appeal_id,D.Zip,D.First_gift_date
      from appeals A left outer Join Donations D
      on A.Dnr_id = D.Dnr_id and A.Appeal_id = D.Appeal_id;
quit;
/*TOTAL NON REPSONDED APPEALS*/
proc sql; 
create table non_responded_appeal as
select count(*)
from A
where gift_date is null and gift_amount is null and appeal_cost is null;
quit;
/*DONOR NEVER RESPONDED and mx amnt*/
PROC SQL;
create table MAX_DNR as
SELECT dnr_id, SUM(Gift_amount)AS SUM
FROM final_merged GROUP BY dnr_id;
QUIT;
PROC SORT DATA= MAX_DNR;
BY DESCENDING SUM;
QUIT;

proc sql;
create table days as 
select dnr_id, appeal_id ,sum(INTCK('DAY',appeal_date,gift_date)) as days
from notnull
group by dnr_id, appeal_id;
quit;
proc sort data= days ;
BY DESCENDING days;
QUIT;
proc sql;
create table date as 
select dnr_id, days from days 
where days>0;
quit;
proc means data = date;
var days;
run;

/*max appeals*/
proc sql;
select appeal_id, sum(appeal_cost) as sum
from appeals group by appeal_id;
quit;



proc sql;
create table responded_appeal as
      select A.dnr_id,A.appeal_id,A.appeal_date,A.appeal_cost,A.Gift_date,A.Gift_amount,A.Responded_Appeal_id,A.Zip,A.First_gift_date,D.State,D.State_Abbreviation
      from merged A left outer Join us_postal_codes D
      on A.zip = D.zip;
quit;

/*summing donation amount on zip*/
proc sql;
create table year_zip_gift as
      select state_abbreviation , year(Gift_date) as year,Gift_amount
      from final_merged
      group by state_abbreviation,year(Gift_date);
quit;
proc sql;
create table year_zip_gif_tot as
      select state_abbreviation ,  year, sum(Gift_amount) as total_donation
      from year_zip_gift
	  group by state_abbreviation,year;
	  quit;
proc sql;
create table year_zip_gif_tot as
      select state_abbreviation ,  year, sum(Gift_amount) as total_donation
      from year_zip_gift
	  group by state_abbreviation,year;
	  quit;

	  proc sql; 
	  create table year_2004 as 
	  select state_abbreviation , total_donation
	  from year_zip_gif_tot where year=2004;
	  quit;
	  /*plot graphs*/
	  ods graphics on;
	  proc gchart data= year_2004;
	  vbar state_abbreviation;
	  run;

/*graph--works*/
pattern1 value=solid color=pink;
pattern2 value=solid color=cx42C0FB;
proc gchart data=year_zip_gift;
  title "state wise donation amount";
hbar state_abbreviation / type=sum sumvar=gift_amount descending nostats
autoref clipref cref=graydd coutline=gray99
subgroup=year;
run;

/*----qtr n sales*/
Data Quartr ;
set 'Donations.sas7bdat';
Month= month(gift_date);
Quarter= qtr(gift_date);
year= year(gift_date);
date= put(gift_date,MONYY5.);
run;
proc sgplot data=Quartr;
  title 'Actual Donations by Year and Quarter';
  vbar year / response=gift_amount group=quarter groupdisplay=cluster dataskin=gloss;
  xaxis display=(nolabel);
  yaxis grid;
  run;
 
 
  /*amt by quarter----working*/
PROC SGPLOT DATA = Quarterly;
 VBAR qtr / RESPONSE = gift_amount;
 TITLE 'qtr sales for all';
RUN; 


proc freq data=year_zip_gift;
title "Frequency of donation";
tables state_abbreviation / plots=FreqPlot(scale=Percent) out=Freq1Out; /* save Percent variable */
run;
 proc sort data = Freq1Out;
by descending percent;
run;

proc sql;
create table finally_merged as
      select dnr_id,year(Gift_date)as year,State_Abbreviation
      from final_merged
      group by dnr_id,year;
quit;
Proc Freq data = finally_merged ;
     tables state_abbreviation * year /  plots=FreqPlot  out = want (drop = percent) ;
run ;



proc sql;
create table quartr_1 as
select date, gift_amount from quartr;
run;
proc sql;
create table quartr_2 as
select  date, sum(gift_amount)as sum from quartr_1 group by date;

quit;
data quartr_2;
set quartr_2;
IF date=NOV99 THEN DELETE;
  RUN;

/*forecast--*/
proc forecast data=quartr_2 lead=10 out=pred outlimit;
var sum;
run;



proc sort data=year_zip_gif_tot;
by total_donation;
run;

proc sql; 
create table pre_agg as select zip,appeal_id,Dnr_id,sum(Gift_amnt_sum)as total_donation,
sum(appeal_cost_sum) as total_appeal_cost from pre_master group by zip,appeal_id,Dnr_id;
quit; 
proc anova data= pre_agg;
class zip;
model total_donation=zip;
run;
/*Descriptive Stats end*/


/*creating a library and assigning the files to work */
proc means data = Appeals n nmiss;
var _numeric_;
run;
proc means data = Donations n nmiss;
var _numeric_;
run;
/*we can conclude there are no missing variables in the both tables */
PROC IMPORT OUT= WORK.Household_Income_Distribution 
            DATAFILE= "Household Income Distribution.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
PROC IMPORT OUT= WORK.Household_by_Age_and_Family 
            DATAFILE= "Household Type by Householder Age and Family Type.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
PROC IMPORT OUT= WORK.Population_by_Age_and_Gender 
            DATAFILE= "Population by Age and Gender.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
PROC IMPORT OUT= WORK.Urban_Rural_Housing_Units
            DATAFILE= "Urban Rural Housing Units.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
PROC IMPORT OUT= WORK.us_postal_codes 
            DATAFILE= "us_postal_codes.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
/*importing new datasets*/
data Us_postal_codes(drop=zip);
set Us_postal_codes;
Zip_cde=put(zip,z5.);
rename Zip_cde=zip;
run;
data Household_by_age_and_family(drop=zip);
set Household_by_age_and_family;
Zip_cde=put(zip,z5.);
rename Zip_cde=zip;
run;
data Household_income_distribution(drop=zip);
set Household_income_distribution;
Zip_cde=put(zip,z5.);
rename Zip_cde=Zip;
run;
Data Population_by_age_and_gender (drop=zip);
set Population_by_age_and_gender;
Zip_cde=put(zip,z5.);
rename Zip_cde=Zip;
run;
data Urban_rural_housing_units (drop=zip);
set Urban_rural_housing_units;
Zip_cde=put(zip,z5.);
rename Zip_cde=Zip;
run;
/*importing us 2000 census data and formatting it to convert all zip codes into  text */
proc sql; 
create table Agg_appeals as select appeal_id,Dnr_id,Appeal_date,sum(appeal_cost)as appeal_cost_sum 
from Appeals group by appeal_id,Dnr_id,Appeal_date;
quit;
proc sql; 
create table Agg_donations as select appeal_id,Dnr_id,zip,gift_date,sum(gift_amount)as Gift_amnt_sum 
from Donations group by appeal_id,Dnr_id,zip,gift_date;
quit;
/*aggregating appeals and donations data */
proc sort data=Agg_appeals;
by appeal_id Dnr_id;
run;
proc sort data=Agg_donations;
by appeal_id Dnr_id;
run;
/*sorting the data before merging*/
Data aggregate;
merge Agg_donations(in=A) Agg_Appeals(in=B); 
if A=1;
by appeal_id Dnr_id;
run;
/*merging appeals with donations */
proc sort data =Us_postal_codes;
by zip;
run;
proc sort data =aggregate;
by zip;
run;
Data aggregate_demo;
merge aggregate(in=a)Us_postal_codes(in=b);
if a=1;
by zip;
run;
data aggregate_demo;
set aggregate_demo;
appeal_yr=year(appeal_date);
appeal_mn=month(appeal_date);
gift_yr=year(gift_date);
gift_mn=month(gift_date);
run;
/*merging us ostal code data and extracting months and year */
Data master_set;
merge aggregate_demo(in=a)Household_by_age_and_family(in=b)Household_income_distribution(in=c)
Population_by_age_and_gender(in=d)Urban_rural_housing_units(in=e) ;
if a=1;
by zip;
run;
/*merging all the other datasets for us cesus */
data post_master (WHERE=(gift_date>='01JAN2004:00:00:00'd)); 
set master_set; 
run;
data pre_master (WHERE=(gift_date<'01JAN2004:00:00:00'd)); 
set master_set; 
run;
/*splitting the data into pre 2004 and post 2004*/
proc anova data=pre;
class zip;
model Gift_amnt_sum=zip; 
run;
proc sql; 
create table pre_agg as select zip,appeal_id,Dnr_id,sum(Gift_amnt_sum)as total_donation,
sum(appeal_cost_sum) as total_appeal_cost from pre_master group by zip,appeal_id,Dnr_id;
quit; 
proc anova data= pre_agg;
class zip;
model total_donation=zip;
run;
/*checking if zip codes show vaiation in donation amnt, we conclude they do show variations */
proc reg data=pre;
model Gift_amnt_sum=gift_date appeal_date appeal_cost_sum;
run;
/*running regression on all numerical variables */
proc sql; 
create table donations_by_zip as select zip, sum(total_donation) as total from pre_agg group by zip;
quit; 
proc sort data = donations_by_zip;
by descending total;
run;
proc sql; 
create table donations_by_county as select state, county, sum(gift_amnt_sum) as total from pre_master group by state,county;
quit; 
proc sort data = donations_by_county;
by descending total;
run;
proc sql; 
create table donations_by_state as select state, sum(gift_amnt_sum) as total from pre_master group by state;
quit; 
proc sort data = donations_by_state;
by descending total;
run;
/* aggregating by zip, county , state */
data test;
set donations_by_state;
cum_per=(total/4094390)*100;
run;
proc ANOVA data=Pre;
	title zip code corelation;
	class zip;
	model gift_amnt_sum = zip;
	run;
proc ANOVA data=Post;
	title zip code corelation;
	class zip;
	model gift_amnt_sum = zip;
	run;
 PROC RANK DATA = donations GROUPS=5
 OUT = quint;
VAR gift_date;
RANKS gift_date_5 ;
RUN;
data count;
  set donations;
  count + 1;
  by dnr_id;
  if first.dnr_id then count = 1;
  if last.dnr_id;
run;
proc rank data= agg_donations group=5
out = mon;
Var gift_amnt_sum;
ranks mon;
run;
data post (WHERE=(gift_date>='01JAN2004:00:00:00'd)); 
set donations; 
run;
data pre1 (WHERE=(gift_date<'01JAN2004:00:00:00'd)); 
set donations; 
run;
data pre (WHERE=(gift_date>'01JAN2000:00:00:00'd)); 
set pre1; 
run;
data quarterly ;
set pre;
y=qtr(gift_date);
z=year(gift_date);
x=cat(y,z);
if x=12000 then qtr =1;
if x=22000 then qtr =2;
if x=32000 then qtr =3;
if x=42000 then qtr =4;
if x=12001 then qtr =5;
if x=22001 then qtr =6;
if x=32001 then qtr =7;
if x=42001 then qtr =8;
if x=12002 then qtr =9;
if x=22002 then qtr =10;
if x=32002 then qtr =11;
if x=42002 then qtr =12;
if x=12003 then qtr =13;
if x=22003 then qtr =14;
if x=32003 then qtr =15;
if x=42003 then qtr =16;
if x=12004 then qtr =17;
if x=22004 then qtr =18;
if x=32004 then qtr =19;
if x=42004 then qtr =20;
if x=12005 then qtr =21;
if x=22005 then qtr =22;
if x=32005 then qtr =23;
if x=42005 then qtr =24;
if x=12006 then qtr =25;
if x=22006 then qtr =26;
if x=32006 then qtr =27;
if x=42006 then qtr =28;
drop x y z;
run;
proc sql; 
create table agg_quarter as select dnr_id,zip,qtr, sum(gift_amount) as gift_amnt_qtr from quarterly group by dnr_id,zip,qtr;
quit; 
proc sql; 
create table recency as select dnr_id,zip,max(qtr) as recency from agg_quarter group by dnr_id,zip;
quit;
data freq;
set agg_quarter; 
freq=1;
run;
/*calculating frequency */
proc sql; 
create table Frequency as select Dnr_id,Zip,sum(freq) as frequency from freq group by Dnr_id,Zip;
quit;
proc sql; 
create table monetary as select Dnr_id,Zip,sum(gift_amnt_qtr) as Monetary from agg_quarter group by Dnr_id,Zip;
run;
proc sort data = recency;
by Dnr_id Zip;
run;
proc sort data = Frequency;
by Dnr_id Zip;
run;
proc sort data = Monetary;
by Dnr_id Zip;
run;
/*sorting data before merge */
Data rfm;
merge recency(in=a)frequency(in=b)Monetary(in=c);
if a=1;
by Dnr_id Zip;
run;

/*aggregating recency frequency and monatary value in one table */
proc contents data=pre_master out=meta (keep=NAME) ; 
run ; 
/*extracting column names */
proc export data=meta outfile="meta.csv";
run;
proc reg data=pre_master;
 model Gift_amnt_sum =  Avg_HH_Income Avg_HH_Income_HH_GT___200000 
Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child 
Family_HH_Other_witht_own_CHILD_ Family_households Family_households_HH_15_to_34 
Family_households_HH_35_to_54 Family_households_HH_55_to_74 Family_households_HH_75__or_olde 
Family_households___Other_with_o Female Female_0__to_9 Female_10__to_18 Female_19_to_22 
Female_23_29 Female_30_44 Female_45_to_59 Female_60_69 Female_GT_70 Less_than_30_000 Male 
Male_0__to_9 Male_10__to_18 Male_19_to_21 Male_22_29 Male_30_44 Male_45_to_59 Male_60_69 
Male_GT_70 Median_HH_Income Nonfamily_HH Nonfamily_HH_1_person_HH Nonfamily_HH_MT_2_persons_HH 
Nonfamily_households_HH_15_to_34 Nonfamily_households_HH_35_to_54 Nonfamily_households_HH_55_to_74 
Nonfamily_households_HH_75__or_o Rural_Farm Rural_Nonfarm Semi_Urban Total_Households Total_Housing_Units 
Total_population Urban _100_000_to__149_999 _150_000_to__199_999 _200_000_or_more _30000_to_59_999 
_60_000_to_99_999 appeal_cost_sum/VIF STB;
run;
/*running regression */
ods output PearsonCorr = p ; 
proc corr data = pre_master perason nosimple outp= corr;
var Gift_amnt_sum Avg_HH_Income Avg_HH_Income_HH_GT___200000 
Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child 
Family_HH_Other_witht_own_CHILD_ Family_households Family_households_HH_15_to_34 
Family_households_HH_35_to_54 Family_households_HH_55_to_74 Family_households_HH_75__or_olde 
Family_households___Other_with_o Female Female_0__to_9 Female_10__to_18 Female_19_to_22 
Female_23_29 Female_30_44 Female_45_to_59 Female_60_69 Female_GT_70 Less_than_30_000 Male 
Male_0__to_9 Male_10__to_18 Male_19_to_21 Male_22_29 Male_30_44 Male_45_to_59 Male_60_69 
Male_GT_70 Median_HH_Income Nonfamily_HH Nonfamily_HH_1_person_HH Nonfamily_HH_MT_2_persons_HH 
Nonfamily_households_HH_15_to_34 Nonfamily_households_HH_35_to_54 Nonfamily_households_HH_55_to_74 
Nonfamily_households_HH_75__or_o Rural_Farm Rural_Nonfarm Semi_Urban Total_Households Total_Housing_Units 
Total_population Urban _100_000_to__149_999 _150_000_to__199_999 _200_000_or_more _30000_to_59_999 
_60_000_to_99_999 appeal_cost_sum;
attrib _all_ label = ' '; 
run;
proc export data=corr outfile="corr.csv";
run;
/*creating covariance matix */
PROC STANDARD DATA=pre_master MEAN=0 STD=1 OUT=normal;
VAR  Avg_HH_Income Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 
Family_households Family_households_HH_15_to_34 Family_households_HH_75__or_olde Female 
Female_19_to_22 Female_45_to_59 Female_60_69 Female_GT_70 Male Male_19_to_21 Male_60_69 
Male_GT_70 Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban Total_Households 
Total_Housing_Units Total_population Urban _100_000_to__149_999 _150_000_to__199_999 appeal_cost_sum ;
RUN;
PROC FACTOR DATA=normal
 SIMPLE
 METHOD=PRIN
 PRIORS=ONE
 MINEIGEN=1
 SCREE
 ROTATE=VARIMAX
 ROUND  out = PCA;
 VAR  Avg_HH_Income Avg_HH_Income_HH_GT___200000 
Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child 
Family_HH_Other_witht_own_CHILD_ Family_households Family_households_HH_15_to_34 
Family_households_HH_35_to_54 Family_households_HH_55_to_74 Family_households_HH_75__or_olde 
Family_households___Other_with_o Female Female_0__to_9 Female_10__to_18 Female_19_to_22 
Female_23_29 Female_30_44 Female_45_to_59 Female_60_69 Female_GT_70 Less_than_30_000 Male 
Male_0__to_9 Male_10__to_18 Male_19_to_21 Male_22_29 Male_30_44 Male_45_to_59 Male_60_69 
Male_GT_70 Median_HH_Income Nonfamily_HH Nonfamily_HH_1_person_HH Nonfamily_HH_MT_2_persons_HH 
Nonfamily_households_HH_15_to_34 Nonfamily_households_HH_35_to_54 Nonfamily_households_HH_55_to_74 
Nonfamily_households_HH_75__or_o Rural_Farm Rural_Nonfarm Semi_Urban Total_Households Total_Housing_Units 
Total_population Urban _100_000_to__149_999 _150_000_to__199_999 _200_000_or_more _30000_to_59_999 
_60_000_to_99_999 appeal_cost_sum ;
 RUN;
 proc factor data=normal simple corr;
run;
proc pls data=normal nfac=1 method=pls;
 model Gift_amnt_sum = Avg_HH_Income Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 
Family_households Family_households_HH_15_to_34 Family_households_HH_75__or_olde Female 
Female_19_to_22 Female_45_to_59 Female_60_69 Female_GT_70 Male Male_19_to_21 Male_60_69 
Male_GT_70 Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban Total_Households 
Total_Housing_Units Total_population Urban _100_000_to__149_999 _150_000_to__199_999 appeal_cost_sum;
run;
/*/*running regression on selected variables  */*/

/*fresh start using master data set*/
/**/
;
proc contents data=master_set out=meta_master (keep=NAME); 
run;
proc export data=meta_master outfile="meta_master.csv";
run;
data master;
set master_set;
working_male=Male_19_to_21 + Male_22_29 + Male_30_44 + Male_45_to_59;
retd_male=Male_60_69 + Male_GT_70;
working_female=Female_19_to_22 + Female_23_29 + Female_30_44 + Female_45_to_59;
retd_female=Female_60_69 + Female_GT_70;
avg_per_household=Total_population/Total_Households;
drop Avg_HH_Income Family_HH_Other_witht_own_CHILD_ Family_households_HH_15_to_34 
Family_households_HH_35_to_54 Family_households_HH_55_to_74 Family_households_HH_75__or_olde 
Family_households___Other_with_o Lat Less_than_30_000 Nonfamily_HH_1_person_HH 
Nonfamily_HH_MT_2_persons_HH Nonfamily_households_HH_15_to_34 
Nonfamily_households_HH_35_to_54 Nonfamily_households_HH_55_to_74 
Nonfamily_households_HH_75__or_o long Total_population _100_000_to__149_999 
_150_000_to__199_999 _200_000_or_more _30000_to_59_999 _60_000_to_99_999 
Female_0__to_9 Female_10__to_18 Female_19_to_22 Female_23_29 Female_30_44 
Female_45_to_59 Female_60_69 Female_GT_70 Male_0__to_9 Male_10__to_18 Male_19_to_21 
Male_22_29 Male_30_44 Male_45_to_59 Male_60_69 Male_GT_70 Female Male
state_abbreviation total_households;
if cmiss(of _all_) then delete;
gift_sum_rnd= round(gift_amnt_sum,1);
if gift_sum_rnd le 10 then cat1="lt_10";
if gift_sum_rnd > 10 and gift_sum_rnd<=50 then cat1="10_50";
if gift_sum_rnd > 50 and gift_sum_rnd<=100 then cat1="50_100";
if gift_sum_rnd ge 100 then cat1="mt_100";
if region='South' then South=1;else South=0;
if region='West' then West=1;else West=0;
if region='Northeast' then Northeast=1;else Northeast=0;
if region='Midwest' then Midwest=1;else Midwest=0;
run;
proc contents data=master out=meta_master (keep=NAME); 
run;
proc export data=meta_master outfile="meta_master.csv";
run;
PROC STANDARD DATA=master MEAN=0 STD=1 OUT=normal;
VAR Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch 
Family_HH_Married_with_own_child Family_households Median_HH_Income Nonfamily_HH 
Rural_Farm Rural_Nonfarm Semi_Urban Total_Housing_Units Urban appeal_cost_sum avg_per_household 
retd_female retd_male working_female working_male;
RUN;
data master_post (WHERE=(gift_date>='01JAN2004:00:00:00'd)); 
set normal; 
run;
data master_pre1 (WHERE=(gift_date<'01JAN2004:00:00:00'd)); 
set normal; 
run;
data master_pre (WHERE=(gift_date>'01JAN2000:00:00:00'd)); 
set master_pre1; 
run;
proc logistic data = master_pre;
model cat1=Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 
Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child Family_households 
Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban Total_Housing_Units 
Urban appeal_cost_sum avg_per_household retd_female retd_male working_female working_male
appeal_mn gift_mn/ link = glogit;
run;
proc reg data=master_pre outest=RegOut;
 YHat: model Gift_amnt_sum = Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 
Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child Family_households 
Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban Total_Housing_Units 
Urban appeal_cost_sum avg_per_household retd_female retd_male working_female working_male
appeal_mn gift_mn/selection=maxr;
run;
proc reg data=master_pre;
 model Gift_amnt_sum = Avg_HH_Income_HH_GT___200000  
Nonfamily_HH appeal_cost_sum avg_per_household 
appeal_mn gift_mn/VIF STB;
run;
proc score data=master_post score=RegOut type=parms predict out=Pred;
   var Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 
Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child Family_households 
Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban Total_Housing_Units 
Urban appeal_cost_sum avg_per_household retd_female retd_male working_female working_male
appeal_mn gift_mn;
run;
proc sql;
select gift_sum_rnd, count(gift_sum_rnd) from master group by 1;
quit;
proc reg data=clv outest=RegOut1;
 YHat: model clvalue = Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 
Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child Family_households 
Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban Total_Housing_Units 
Urban avg_per_household retd_female retd_male working_female working_male
appeal_mn gift_mn/selection=stepwise;
run;

/*after running regression we can conclude that demographics do not have an impact on donations */
proc sort data=appeals;
by appeal_id dnr_id;
run;
proc sort data=donations;
by appeal_id dnr_id;
run;
data q2;
merge appeals(in=a) donations(in=b);
if a =1;
by appeal_id dnr_id;
run;
data q2;
set q2;
array change _numeric_;
do over change;
if change=. then change=0;
end;
if gift_amount > 0  then cat1=1;else cat1=0;
run;
proc reg data=q2 outest=Regq2;
 YHat: model cat1 = appeal_cost gift_amount/selection=stepwise;
run;
/*after sas mid term 25th April multinomial logit and conditional logit  */
data choice;
set master_pre;
keep appeal_cost_sum cat1 south west northeast midwest App_mn Gft_mn;
App_mn = put(appeal_mn,6.);
Gft_mn = put(gift_mn,6.);
run;
data choice1;
length Select $20.;
array selection [4] $  _temporary_ ('lt_10' '10_50' '50_100' 'mt_100' ) ;
set choice;
Subject = _n_;
do i = 1 to 4;
Select = selection[i];
Choice = 3 - (cat1 eq Select);
	Choice2 = cat1 eq Select;
 	output;
 end;
run;
proc logistic data = choice1;
class select (ref = 'lt_10') App_mn Gft_mn;
model choice (event='2') = select appeal_cost_sum south west northeast midwest App_mn Gft_mn/ link = glogit;
run;
/*basis the output of this regression we can reccomend some regions and their states to acquire new customers */

/*the below code will transform data and runa linear regression model to check for customer lifetime value predictions*/
data clv; 
set master; 
clvalue=gift_amnt_sum+appeal_cost_sum;
Ln_Nonfamily_HH=log10(Nonfamily_HH);
ln_Rural_Farm =log10(Rural_Farm);
ln_Rural_Nonfarm =log10(Rural_Nonfarm);
Sq_Semi_Urban =sqrt(Semi_Urban);
Ln_avg_per_household=log10(avg_per_household);
run;
data clv;
set clv;
array change _numeric_;
do over change;
if change=. then change=0;
end;
run;
PROC STANDARD DATA=clv MEAN=0 STD=1 OUT=clv_normal;
VAR Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child 
Family_households Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban Total_Housing_Units Urban avg_per_household 
retd_female retd_male working_female working_male ;
RUN;

proc means data=clv N mean median skew;
var Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child 
Family_households Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban Total_Housing_Units Urban avg_per_household 
retd_female retd_male working_female working_male Ln_Nonfamily_HH ln_Rural_Farm ln_Rural_Nonfarm Sq_Semi_Urban Ln_avg_per_household;
run;
PROC STANDARD DATA=clv MEAN=0 STD=1 OUT=clv_normal;
var Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child 
Family_households Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban Total_Housing_Units Urban avg_per_household 
retd_female retd_male working_female working_male Ln_Nonfamily_HH ln_Rural_Farm ln_Rural_Nonfarm Sq_Semi_Urban Ln_avg_per_household;
RUN;
proc contents data=clv out=meta_master (keep=NAME); 
run;
proc export data=meta_master outfile="meta_master.csv";
run;
proc reg data=clv outest=Clv_RegOut;
 YHat: model clvalue = Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child 
Family_households Median_HH_Income  Total_Housing_Units Urban retd_female retd_male working_female working_male Ln_Nonfamily_HH 
ln_Rural_Farm ln_Rural_Nonfarm Sq_Semi_Urban Ln_avg_per_household south west northeast midwest/VIF selection=maxr;
run;
proc reg data=clv outest=Clv_RegOut;
 YHat: model clvalue = Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 Ln_Nonfamily_HH 
ln_Rural_Farm ln_Rural_Nonfarm Sq_Semi_Urban Ln_avg_per_household south west northeast midwest/VIF selection=maxr;
run;
proc reg data=clv outest=Clv_RegOut;
 YHat: model clvalue =  Avg_HH_Income_LT__200000  ln_Rural_Nonfarm south west northeast midwest/VIF selection=maxr;
run;
proc princomp data=clv out=clv_pca;
   var Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child 
Family_households Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban Total_Housing_Units Urban avg_per_household 
retd_female retd_male working_female working_male Ln_Nonfamily_HH ln_Rural_Farm ln_Rural_Nonfarm Sq_Semi_Urban Ln_avg_per_household;
run;
proc reg data=clv_pca;
model clvalue= prin1 prin2 prin3 prin4 prin5 prin6 prin7 prin8 prin9/selection=maxr;
run;
/*running a linear regressio with pca also does not yield desirable results */

/*running appeals analysis below */
proc sort data=appeals;
by appeal_id dnr_id;
run;
proc sort data=donations;
by appeal_id dnr_id;
run;
data Appeals_analysis;
merge appeals(in=a) donations(in=b);
if a =1;
by appeal_id dnr_id;
run;

data Appeals_analysis;
set Appeals_analysis;
appeal_yr=year(appeal_date);
appeal_mn=month(appeal_date);
gift_yr=year(gift_date);
gift_mn=month(gift_date);
run;
proc sort data= Appeals_analysis; 
by zip; 
run;
proc sort data= us_postal_codes; 
by zip; 
run;
/*merging us ostal code data and extracting months and year */
Data Appeal_analysis;
merge Appeals_analysis(in=a)us_postal_codes(in=b);
if a=1;
by zip;
run;
data Appeal_analysis( drop=State State_abbreviation county lat long region Place_name);
set Appeal_analysis;
if region='South' then South=1;else South=0;
if region='West' then West=1;else West=0;
if region='Northeast' then Northeast=1;else Northeast=0;
if region='Midwest' then Midwest=1;else Midwest=0;
run;
/*array change _numeric_;*/
/*do over change;*/
/*if change=. then change=0;*/
/*end;*/

/*kshitij*/
Data Appeal_analysis;
set Appeal_analysis; 
if gift_amount>0 then donate=1;else donate=0;
Sqrt_appeal_cost= sqrt(appeal_cost);
App_mn = put(appeal_mn,6.);
Gft_mn = put(gift_mn,6.);
run;
data Appeal_analysis; 
set Appeal_analysis; 
drop zip appeal_mn gift_mn; 
run;
proc sort data = Appeal_analysis; 
by Dnr_id; 
run; 
proc sort data = donations; 
by Dnr_id; 
run; 
data appeal_region; 
merge Appeal_analysis (in=a) donations (in=b);
by Dnr_id; 
if a=1; 
run;
data appeal_region; 
set appeal_region; 
drop first_gift_date south west northeast midwest; 
run;
proc sql ; select zip, count(zip) from appeal_region group by 1; quit;
proc sort data= Appeal_region; 
by zip; 
run;
data Appeals_final; 
merge Appeal_region(in=a) us_postal_codes(in=b); 
by zip; 
if a=1; 
run;
data appeals_final; 
set Appeals_final; 
if region='South' then South=1;else South=0;
if region='West' then West=1;else West=0;
if region='Northeast' then Northeast=1;else Northeast=0;
if region='Midwest' then Midwest=1;else Midwest=0;
appeals_qtr=qtr(appeal_date);
donation_qtr=qtr(gift_date);
array change _numeric_;
do over change;
if change=. then change=0;
end;
run; 
data appeals_final; 
set appeals_final; 
if gift_date='01JAN1960:00:00:00'd then donation_qtr=0; 
run;
/*drop appeal_id dnr_id place_name state county lat long region ; */

/*data processing complete for runnign logit and probit */
proc means data=Appeal_analysis N mean median skew;
	var appeal_cost gift_amount Sqrt_appeal_cost;
	run;
proc logistic data = Appeals_final;
class appeals_qtr donation_qtr;
model donate (event='1')=  South West Northeast Midwest Sqrt_appeal_cost appeals_qtr donation_qtr;
   output out = Appeal_logit pred = Appeal_Log;
run;
title ’Probit Model’;
proc logistic data =  Appeals_final;
   model donate (event='1')= South West Northeast Midwest Sqrt_appeal_cost appeals_qtr donation_qtr / link = probit;
   output out = Appeal_probit pred = Appeal_prob;
run;
/*Running logit and probit models */
proc qlim data=Appeals_final plots=none;
 model donate= South West Northeast Midwest Sqrt_appeal_cost;
 endogenous donate ~ censored(lb=0);
run;
/*Tobit model */

data proc_appeal;
set appeals_final;
where gift_date>='01JAN2000:00:00:00'd;
run;
Proc rank data = proc_appeal out = rank_appeal_cost groups = 3;
	var appeal_cost;
	ranks a_c;
run;
proc logistic data = rank_appeal_cost;
class appeals_qtr donation_qtr a_c;
model donate (event='1')=  South West Northeast Midwest Sqrt_appeal_cost appeals_qtr donation_qtr a_c;
   output out = Appeal_logit pred = Appeal_Log;
run;
/*new analysis on aggregate data */
data new_model; 
set master; 
turnaroundtime= gift_date-appeal_date; 
run;
proc sql; 
create table new_model1 as select zip,avg(turnaroundtime)as turnarnd_time from new_model group by zip;
quit;
proc sql; 
create table new_model2 as select zip,sum(Appeal_cost_sum) as total_cost,sum(gift_amnt_sum)as total_donation,
avg(Appeal_cost_sum) as avg_cost, avg(gift_amnt_sum) as avg_donation
from new_model group by zip;
quit;
data new_model3; 
set new_model; 
drop appeal_id dnr_id gift_date gift_amnt_sum appeal_date appeal_cost_sum appeal_yr appeal_mn gift_yr 
gift_mn gift_sum_rnd cat1 turnaroundtime;
run;
proc sort data=new_model3 noduprecs;
by _all_ ; 
Run;
proc sort data= new_model1; 
by zip; 
run;
proc sort data= new_model2; 
by zip; 
run;
proc sort data= new_model3; 
by zip; 
run;

data new_model4; 
merge new_model1(in=a)new_model2(in=b)new_model3(in=c);
if a=1; 
run;
proc contents data=new_model4 out=new_head (keep=NAME) ; 
run ; 
proc export data=new_head outfile="new_head.csv";
run;
proc means data=new_model4 N mean median skew;
var Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child Family_households Median_HH_Income Midwest Nonfamily_HH Northeast Rural_Farm Rural_Nonfarm Semi_Urban South Total_Housing_Units Urban West avg_cost avg_donation avg_per_household retd_female retd_male total_cost total_donation turnarnd_time working_female working_male;
run;
data new_model4; 
set new_model4;
sqrt_rural_farm=sqrt(rural_farm);
sqrt_semiurban=sqrt(semi_urban);
sqrt_avg_per_hh=sqrt(avg_per_household);
sqrt_turnarnd_time= sqrt(turnarnd_time);
run;
proc means data=new_model4 N mean median skew;
var Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 Family_HH_MarrieD_without_own_ch 
Family_HH_Married_with_own_child Family_households Median_HH_Income Midwest Nonfamily_HH 
Northeast Rural_Farm Rural_Nonfarm Semi_Urban South Total_Housing_Units Urban West avg_cost avg_donation avg_per_household 
retd_female retd_male total_cost total_donation turnarnd_time working_female working_male;
run;


proc reg data=new_model4;
model total_donation  =  Avg_HH_Income_HH_GT___200000 Avg_HH_Income_LT__200000 
Family_HH_MarrieD_without_own_ch Family_HH_Married_with_own_child Family_households
Median_HH_Income Nonfamily_HH Rural_Farm Rural_Nonfarm Semi_Urban
Total_Housing_Units Urban avg_per_household retd_female retd_male
total_cost turnarnd_time working_female working_male west northeast midwest south/selection=maxr;
run;

/*end of donations analysis */

/*Appeals analysis starts below after aggregating info at zip code level */

Proc sort data=DSN out=sample nodupkey dupout=Duplicate;
     by var1;   Run;

proc sort data=appeals;
by appeal_id dnr_id; 
run;
proc sort data=donations;
by appeal_id dnr_id; 
run;
data appeal_model1; 
merge appeals(in=a)donations(in=b);
by appeal_id dnr_id; 
run;
data appeal_model1; 
set appeal_model1;
drop zip; 
run;
data donor; 
set donations; 
keep dnr_id zip gift_date first_gift_date;
run;
proc sort data=donor noduprecs;
by _all_ ; 
Run;
proc sql; 
create table appeal_model2 as select * from donor group by dnr_id having gift_date=max(gift_date);
quit;
proc sort data=appeal_model2 noduprecs;
by _all_ ; 
Run;
proc sql; 
create table appeal_model3 as select * from donor group by dnr_id having first_gift_date=max(first_gift_date);
quit;

data appeal_model4; 
set appeal_model3;
drop gift_date first_gift_date; 
run;
proc sort data=appeal_model4 noduprecs;
by _all_ ; 
Run; 
proc sql; 
select dnr_id,count(*) from appeal_model4 group by dnr_id;
quit;
/*RFM MODEL for RFM ANALYSIS STARTS HERE*/

data preprocess (WHERE=(gift_date>='01JAN2000:00:00:00'd)); 
set donations; 
run;
data quarterly ;
set preprocess;
y=qtr(gift_date);
z=year(gift_date);
x=cat(y,z);
if x=12000 then qtr =1;
if x=22000 then qtr =2;
if x=32000 then qtr =3;
if x=42000 then qtr =4;
if x=12001 then qtr =5;
if x=22001 then qtr =6;
if x=32001 then qtr =7;
if x=42001 then qtr =8;
if x=12002 then qtr =9;
if x=22002 then qtr =10;
if x=32002 then qtr =11;
if x=42002 then qtr =12;
if x=12003 then qtr =13;
if x=22003 then qtr =14;
if x=32003 then qtr =15;
if x=42003 then qtr =16;
if x=12004 then qtr =17;
if x=22004 then qtr =18;
if x=32004 then qtr =19;
if x=42004 then qtr =20;
if x=12005 then qtr =21;
if x=22005 then qtr =22;
if x=32005 then qtr =23;
if x=42005 then qtr =24;
if x=12006 then qtr =25;
if x=22006 then qtr =26;
if x=32006 then qtr =27;
if x=42006 then qtr =28;
drop x y z;
run;
proc sql; 
create table agg_quarter as select dnr_id,zip,qtr, sum(gift_amount) as gift_amnt_qtr from quarterly group by dnr_id,zip,qtr;
quit; 
data post (WHERE=(qtr>16)); 
set agg_quarter; 
run;
data pre (WHERE=(qtr<17)); 
set agg_quarter; 
run;
proc sql; 
create table recency_pre as select dnr_id,zip,max(qtr) as recency from pre group by dnr_id,zip;
quit;
data freq_pre;
set pre; 
freq=1;
run;

/*calculating frequency */
proc sql; 
create table Frequency_pre as select Dnr_id,Zip,sum(freq) as frequency from freq_pre group by Dnr_id,Zip;
quit;
proc sql; 
create table monetary_pre as select Dnr_id,Zip,sum(gift_amnt_qtr) as Monetary from pre group by Dnr_id,Zip;
run;
proc sort data = recency_pre;
by Dnr_id Zip;
run;
proc sort data = Frequency_pre;
by Dnr_id Zip;
run;
proc sort data = Monetary_pre;
by Dnr_id Zip;
run;
/*sorting data before merge */
Data rf_pre;
merge recency_pre(in=a)frequency_pre(in=b);
if a=1;
by Dnr_id Zip;
run;
Data rfm_pre;
merge rf_pre(in=a)Monetary_pre(in=b);
if a=1;
by Dnr_id Zip;
avg_mon=monetary/frequency;
run;
/*aggregating recency frequency and monatary value in one table */
Proc rank data = rfm_pre out = quartile_pre groups = 5;
	var recency frequency monetary;
	ranks r f m;
run;
data rfm_score_pre;
set quartile_pre;
r+1;
f+1;
m+1;
rfm_score=cat(r,f,m);
run;
proc sql; 
create table recency_post as select dnr_id,zip,max(qtr) as recency from post group by dnr_id,zip;
quit;
data freq_post;
set post; 
freq=1;
run;

/*calculating frequency */
proc sql; 
create table Frequency_post as select Dnr_id,Zip,sum(freq) as frequency from freq_post group by Dnr_id,Zip;
quit;
proc sql; 
create table monetary_post as select Dnr_id,Zip,sum(gift_amnt_qtr) as Monetary from post group by Dnr_id,Zip;
run;
proc sort data = recency_post;
by Dnr_id Zip;
run;
proc sort data = Frequency_post;
by Dnr_id Zip;
run;
proc sort data = Monetary_post;
by Dnr_id Zip;
run;
/*sorting data before merge */
Data rf_post;
merge recency_post(in=a)frequency_post(in=b);
if a=1;
by Dnr_id Zip;
run;
Data rfm_post;
merge rf_post(in=a)Monetary_post(in=b);
if a=1;
by Dnr_id Zip;
avg_mon=monetary/frequency;
run;
/*aggregating recency frequency and monatary value in one table */
Proc rank data = rfm_post out = quartile_post groups = 5;
	var recency frequency monetary;
	ranks r f m;
run;
data rfm_score_post;
set quartile_post;
r+1;
f+1;
m+1;
rfm_score=cat(r,f,m);
run;
data rename;
set rfm_score_pre;
rename recency=recency_pre frequency=frequecy_pre monetary=monetary_pre rfm_score=rfm_score_pre r=r_pre f=f_pre m=m_pre avg_mon=avg_mon_pre;
run;
Data rfm_compare_1;
merge rename(in=a)rfm_score_post(in=b);
if a=1;
by Dnr_id;
run;
data rfm_compare_miss;
   set rfm_compare_1;
   array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
 run ;
 proc ttest data=rfm_compare_miss;
 paired avg_mon_pre*avg_mon;
 run;
 data rfm_convert;
 set rfm_compare_miss;
 if frequency>0 then frequent=1;
 if frequency=0 then frequent=0;
  run;
data pre_quarter_8_recency;
set rfm_convert;
where recency_pre<9;
run;
data post_quarter_12_recency;
set rfm_convert;
where recency_pre>11;
run;
proc freq data=pre_quarter_8_recency;
tables frequent;
run;
/*procedure to show the when recency quarter is less than 8, whats the impact on frequency*/
proc freq data=post_quarter_12_recency;
tables frequent;
run;
/*procedure to show the when recency quarter more than 12, whats the impact on frequency*/
data high_frequency;
set rfm_convert;
where frequecy_pre>8;
keep frequecy_pre frequency;
run;
data low_frequency;
set rfm_convert;
where frequecy_pre<9;
run;
proc freq data=low_frequency;
tables frequency;
run;
/*procedure to show whats the impact of low frequency on frequency*/
proc freq data=high_frequency;
tables frequency;
run;
/*procedure to show whats the impact of high frequency on frequency*/
PROC GPLOT DATA=high_frequency;
     PLOT frequecy_pre*frequency ;
RUN;
TITLE 'High Frequency Bar Chart ';
PROC GCHART DATA=high_frequency;
      VBAR frequency/levels=4;
RUN;
TITLE 'High Frequency Pie Chart '; 
PROC GCHART DATA=high_frequency;
      PIE frequency/ DISCRETE VALUE=INSIDE
                 PERCENT=INSIDE SLICE=OUTSIDE;
RUN; 
TITLE 'Low Frequency Bar Chart ';
PROC GCHART DATA=low_frequency;
      VBAR frequency/levels=4;
RUN;
TITLE 'Low Frequency Pie Chart '; 
PROC GCHART DATA=low_frequency;
      PIE frequency/ DISCRETE VALUE=INSIDE
                 PERCENT=INSIDE SLICE=OUTSIDE;
RUN; 
/*Above 4 graphs for descriptive Analytics for Frequency*/

TITLE 'Post 12 Recency Bar Chart ';
PROC GCHART DATA=post_quarter_12_recency;
      VBAR frequent/levels=2;
RUN;
TITLE 'Post 12 Recency Pie Chart '; 
PROC GCHART DATA=post_quarter_12_recency;
      PIE frequent/ DISCRETE VALUE=INSIDE
                 PERCENT=INSIDE SLICE=OUTSIDE;
RUN; 
TITLE 'Pre 8 Recency Bar Chart ';
PROC GCHART DATA=pre_quarter_8_recency;
      VBAR frequent/levels=2;
RUN;
TITLE 'Pre 8 Recency Bar Chart '; 
PROC GCHART DATA=pre_quarter_8_recency;
      PIE frequent/ DISCRETE VALUE=INSIDE
                 PERCENT=INSIDE SLICE=OUTSIDE;
RUN; 
/*Above 4 graphs for descriptive Analytics for Frequency*/


******************************************************END***********************************************************************
