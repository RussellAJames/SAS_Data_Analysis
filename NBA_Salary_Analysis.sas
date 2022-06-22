%let path=/home/u58912630/NBA_Salary_Analysis_2020_2022;
options validvarname=v7;

%let outpath = /home/u58912630/NBA_Salary_Analysis_2020_2022;


ods escapechar='^';
ods pdf file ="&outpath/NBA_Salary_Analysis.pdf" style = HTMLBlue pdftoc=1;


proc import datafile="&path/NBA_Season_Data_2020_Season.csv" dbms=csv replace out=Season_Data_2020;
guessingrows=max;
run;

proc import datafile="&path/NBA_Season_Data_2021_Season.csv" dbms=csv replace out=Season_Data_2021;
guessingrows=max;
run;

proc import datafile="&path/NBA_Season_Data_2022_Season.csv" dbms=csv replace out=Season_Data_2022;
guessingrows=max;
run;

proc import datafile="&path/NBA_Salary_Data_2020.csv" dbms=csv replace out=Salary_Data_2020;
guessingrows=max;
run;
proc import datafile="&path/NBA_Salary_Data_2021.csv" dbms=csv replace out=Salary_Data_2021;
guessingrows=max;
run;
proc import datafile="&path/NBA_Salary_Data_2022.csv" dbms=csv replace out=Salary_Data_2022;
guessingrows=max;
run;

proc sort data= Salary_Data_2020;
by player_name;
run;
proc sort data= Season_Data_2020;
by player_name;
run;
proc sort data= Salary_Data_2021;
by player_name;
run;
proc sort data= Season_Data_2021;
by player_name;
run;
proc sort data= Salary_Data_2022;
by player_name;
run;
proc sort data= Season_Data_2022;
by player_name;
run;

data NBA_SD_2020;
merge Season_Data_2020 Salary_Data_2020;
by player_name;
Year = 2020;
run;

data NBA_SD_2021;
merge Season_Data_2021 Salary_Data_2021;
by player_name;
Year = 2021;
run;

data NBA_SD_2022;
merge Season_Data_2022 Salary_Data_2022;
by player_name;
Year = 2022;
run;

data NBA_SD_2021_2022;
set nba_sd_2021 nba_sd_2022;
if position = 'PG' or position = 'SG';
if salary = '' then salary = .;
format salary_num comma10.;
format mpg astg fgg ptsg tovg rbg ftg stlg 6.3;
format log_salary 6.3;
salary_num = input(salary,comma10.);

if salary_num = . then delete;
if salary_num > 923000;
if games > 55;


player_name_year = catx(' ,',player_name,year);
mpg = minutes_played / games;
astg = assists / games;
fgper = field_goals / field_goal_attempts;
ptsg = points / games;
tovg = turnover / games;
rbg = total_rebounds / games;
ftg = freethrows / games;
ftper = freethrows / freethrow_attempts;
stlg = steals / games;
log_Salary = log(salary_num);

run;

proc contents data= NBA_SD_2021_2022;
title 'Summary of Data';
run;
ods text='^{style [font_face=arial fontsize=12pt] Data contains 188 observations of NBA point guards and shooting guards from 
the 2020-2021 regular season and 2021-2022 regular season, includes game statistics and salaries. }';


proc corr data=NBA_SD_2021_2022;
title 'Correlation of Data';
var salary_num Log_Salary;
with mpg ptsg  astg tovg rbg fgper ftg ftper stlg games total_rebounds freethrows steals;
run;
ods text='^{style [font_face=arial fontsize=12pt] Correlation of salary and log transform of salary between key variables to see strength of linear relationship. }';
ods text = '';
ods text='^{style [font_face=arial fontsize=12pt] The strongest correlations results are from the following variables minutes per game (mpg), points per game (ptsg), 
assists per game (astg), and turnovers per game (tovg) which will be used to construct a linear model. }';

ods graphics on;
proc reg data=NBA_SD_2021_2022 plots = (CooksD(label) DFFITS(label) diagnostics(stats=(aic ADJRSQ)));
title 'Model 1 Salary';
model salary_num = mpg ptsg astg tovg;
id player_name_year;
run;
ods text ='^{style [font_face=arial fontsize=12pt] The first constructed model using dependent variable salary and explanatory variables minutes per game (mpg), points per game (ptsg), 
assists per game (astg), and turnovers per game (tovg).}';
ods text = '^{newline}';
ods text ='^{style [font_face=arial fontsize=12pt] From the model analysis the explantory variables that are not statistically significant are turnovers per game (tovg), and minutes per game (mpg). 
The adjusted R-squared of this model is 0.4274 (Which measures the goodness-of-fit of a linear model) and the akaike information criterion (AIC) is 5959.7 (Which estimates the
relative amount of information lost by a model).}';

proc reg data=NBA_SD_2021_2022 plots = (CooksD(label) DFFITS(label) diagnostics(stats=(aic ADJRSQ)));
title 'Model 1 Log Transform Salary';
model log_salary = mpg ptsg astg tovg;
id player_name_year;
run;
ods text ='^{style [font_face=arial fontsize=12pt] The first constructed using dependent variable log transformed salary and explanatory variables minutes per game (mpg), points per game (ptsg), 
assists per game (astg), and turnovers per game (tovg).}';
ods text = '^{newline}';
ods text ='^{style [font_face=arial fontsize=12pt] From the model analysis the only explanatory variable that is not statistically significant is turnovers per game (tovg).
The adjusted R-squared of this model is 0.4642 and the akaike information criterion (AIC) is -119.5,
which is an improvement on both measurements when using a log transformation on the dependent variable salary.  }';

data NBA_SD_2021_2022_rmv_outliers;
set NBA_SD_2021_2022;
if player_name = "Tyrese Maxey" and Year = 2022
or player_name = "Russell Westbrook" and Year = 2022 then delete;
run;


proc reg data=NBA_SD_2021_2022_rmv_outliers plots = (CooksD(label) DFFITS(label) diagnostics(stats=(aic ADJRSQ)));
title 'Model 2 Log Transform Salary';
model log_salary = mpg ptsg astg tovg;
id player_name_year;
run;
ods text ='^{style [font_face=arial fontsize=12pt] The second constructed using dependent variable log transformed salary and explanatory variables minutes per game (mpg), points per game (ptsg), 
assists per game (astg), and turnovers per game (tovg). }';
ods text = '^{newline}';
ods text ='^{style [font_face=arial fontsize=12pt] From the model analysis after the removal of two outliers all of the explanatory variables are statically significant.
The adjusted R-squared of this model is 0.4819 and the akaike information criterion (AIC) is -127.3,
which is an improvement on both measurements after the removal of outliers. }';


data NBA_SD_2021_2022_rmv_outliers2;
set NBA_SD_2021_2022_rmv_outliers;
if player_name = "Russell Westbrook" and Year = 2021
or player_name = "Tyrese Haliburton" and Year = 2022
or player_name = "Jalen Brunson" and Year = 2022 then delete;
run;

proc reg data=NBA_SD_2021_2022_rmv_outliers2 plots = (CooksD(label) DFFITS(label)  diagnostics(stats=(aic ADJRSQ)));
title 'Model 3 Log Transform Salary';
model log_salary = mpg ptsg astg tovg;
id player_name_year;
run;
ods text ='^{style [font_face=arial fontsize=12pt] The third constructed model using dependent variable log transformed salary and explanatory variables minutes per game (mpg), points per game (ptsg), 
assists per game (astg), and turnovers per game (tovg). }';
ods text = '^{newline}';
ods text ='^{style [font_face=arial fontsize=12pt] From the model analysis after the removal of three more outliers all of the explanatory variables are statically significant.
The adjusted R-squared of this model is 0.5054 and the akaike information criterion (AIC) is -136.3,
which is an improvement on both measurements after the removal of outliers. }';


data NBA_SD_2021_2022_rmv_outliers3;
set NBA_SD_2021_2022_rmv_outliers2;
if player_name = "Trae Young" and Year = 2022
or player_name = "Kevin Porter Jr." and Year = 2022 
or player_name = "James Harden" and Year = 2022 then delete;
run;

proc reg data=NBA_SD_2021_2022_rmv_outliers3 plots = (CooksD(label) DFFITS(label)  diagnostics(stats=(aic ADJRSQ)));
title 'Model 4 Log Transform Salary';
model log_salary = mpg ptsg astg tovg;
id player_name_year;
run;
ods text ='^{style [font_face=arial fontsize=12pt] The fourth constructed model using dependent variable log transformed salary and explanatory variables minutes per game (mpg), points per game (ptsg), 
assists per game (astg), and turnovers per game (tovg). }';
ods text = '^{newline}';
ods text ='^{style [font_face=arial fontsize=12pt] From the model analysis after the removal of three more outliers all of the explanatory variables are statically significant.
The adjusted R-squared of this model is 0.5115 and the akaike information criterion (AIC) is -138.8,
which is an improvement on both measurements after the removal of outliers. }';




data magic_johnson_predict;
	intercept = 13.25437;
	pts = 19.5;
	ast = 11.2;
	to = 3.9;
	mp = 36.7;
	format salary comma11.;
	salary = exp(intercept + pts * 0.05545	+ ast * 0.16781 + to * 	-0.45313 + mp * 0.06823);
run;


proc print data = magic_johnson_predict;
title 'Magic Johnson Prediciton';
run;
ods text ='^{style [font_face=arial fontsize=12pt] Using the selected fourth model to make a prediction on the salary if Earvin (Magic) Johnson was to play in the NBA today. 
In his 13 seasons in the NBA he recorded a average of 36.7 minutes per game (mpg), 19.5 points per game (ptsg), 11.2 assists per game (astg), and 3.9 turnovers per game (tovg). }';
ods text ='^{style [font_face=arial fontsize=12pt] The model predicts that he would earn $23,021,774 (USD). }';
 
 
title 'Points per game vs. Salary_log';
proc sgplot data = NBA_SD_2021_2022_rmv_outliers3;
scatter y=log_salary x=ptsg;
reg y=log_salary x = ptsg / CLM CLI;
run;

title 'Assists per game vs. Salary_log';
proc sgplot data = NBA_SD_2021_2022_rmv_outliers3;
scatter y=log_salary x=astg;
reg y=log_salary x = astg / CLM CLI;
run;

title 'Minutes per game vs. Salary_log';
proc sgplot data = NBA_SD_2021_2022_rmv_outliers3;
scatter y=log_salary x=mpg;
reg y=log_salary x = mpg / CLM CLI;
run;

title 'Turnovers per game vs. Salary_log';
proc sgplot data = NBA_SD_2021_2022_rmv_outliers3;
scatter y=log_salary x=tovg;
reg y=log_salary x = tovg / CLM CLI;

run;
ods text ='^{style [font_face=arial fontsize=12pt] Plots of variables chosen for model. }';


title "Removed Outliers";
proc sql;
select player_name, age, salary_num, mpg, ptsg, astg, tovg , year
from NBA_SD_2021_2022
where player_name = "Tyrese Maxey" and Year = 2022
or player_name = "Russell Westbrook" and Year = 2022 
or player_name = "Russell Westbrook" and Year = 2021
or player_name = "Tyrese Haliburton" and Year = 2022
or player_name = "Jalen Brunson" and Year = 2022
or player_name = "Trae Young" and Year = 2022
or player_name = "Kevin Porter Jr." and Year = 2022
or player_name = "James Harden" and Year = 2022
order by salary_num desc;
quit;

ods pdf close;


