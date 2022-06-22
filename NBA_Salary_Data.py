from bs4 import BeautifulSoup as soup
from urllib.request import urlopen
import re
import time
import pandas as pd
from pathlib import Path

Teams = ['ATL','BRK','BOS','CHO','CHI','CLE','DAL','DEN','DET','GSW','HOU','IND',
'LAC','LAL','MEM','MIA','MIL','MIN','NOP','NYK','OKC','ORL','PHI','PHO','POR','SAC',
'SAS','TOR','UTA','WAS']
Years = [2020,2021,2022]

for year in Years:
    filename = '/home/russelljames/vscode/python_scripts/NBA_Salary_Data_{Year}.csv'.format(Year = year)

    filepath = Path(filename)
    player_name1 = []
    salary1 = []
    
    

    for team in Teams:

        Team_Selection = "https://www.basketball-reference.com/teams/{Team}/{Year}.html".format(Team = team,Year = year)
        raw_data = urlopen(Team_Selection)
        unparsed = raw_data.read()
        Nba_soup = soup(unparsed, 'html.parser')

        string = Nba_soup.select("#all_salaries2")
        pattern_name = r'.html\"\>(\w.+?)\<'
        pattern_name2 = r'.html\'\>(\w.+?)\<'
        pattern_salary = r'\>\$([0-9].+?)\<'
        
        player_name = re.findall(pattern_name,str(string))
        if len(player_name) < 2:
            player_name =  re.findall(pattern_name2,str(string))
        salary =re.findall(pattern_salary,str(string))
        for i in range(0,len(salary)):
            if salary[i][0] == '0':
                salary[i] = '0'
        
        for player in player_name:
            player_name1.append(player)
        for player_salary in salary:
            salary1.append(player_salary)
    
    salary_data = {"Player Name" : player_name1, "Salary" : salary1}    
    salary_df = pd.DataFrame(salary_data)
        

        
    salary_df.to_csv(filepath , index=False)

