# BetFlix-Excellence-Metrics

This project analyzes the content success on Betflix, a video streaming company used for this study. The data for this project is sourced from Netflix, and we explore trends, patterns, and factors that contribute to the success of movies and TV shows on the platform.

# Project Overview
The goal of this project is to assess the success of Betflix (using Netflix data) content through data-driven analysis. We identify key attributes that drive content popularity, including genre, release year, average user ratings, and viewership numbers. The insights gathered from this analysis could help video streaming platforms make strategic decisions about content creation and curation.

## Project Motivation

Identify the top features that determine the success of a TV show or movie on Betflix.
Provide actionable insights that will guide content strategy decisions to maximize ROI. 
Build a predictive model to forecast the likelihood of success for upcoming content.

 
# Data Description
 - [**Netflix_titles**](https://www.kaggle.com/datasets/paramvir705/netflix-dataset)
 - [**IMDB Dataset**](https://docs.google.com/spreadsheets/d/1MnhUFfkANskF_f-JHaWFxpIJPppSrqrY8R05s-A84fQ/edit?gid=1971309909#gid=1971309909)
 - [**Netflix User Base**](https://www.kaggle.com/datasets/arnavsmayan/netflix-userbase-dataset/data)
 - [**Global_all_weeks**](https://docs.google.com/spreadsheets/d/198DZVpLAxUZDBlGA5cMYl3-bIJQAdm9h/edit?usp=sharing&ouid=106503551153519138225&rtpof=true&sd=true)
 - [**Netflix_stock**](https://www.kaggle.com/datasets/mayankanand2701/netflix-stock-price-dataset)
 - [**Netflix_Global_Revenue**](https://www.kaggle.com/datasets/adnananam/netflix-revenue-and-usage-statistics/data)

 - [**Tables' ERD**](https://lucid.app/lucidchart/5c148e6c-b7a1-41d5-8d01-31189a4c7e86/edit?page=0_0&invitationId=inv_488da03f-fd0f-4428-8153-a8e92569e2d3#)
![ERD](https://github.com/user-attachments/assets/f05dedba-bba2-49e3-a4d7-8a8a1d08483d)


# Data Exploration 
## Methods
- **Data Cleaning**:GoogleSheets/Bigquery(SQL)/GoogleColab(Python)
- **Exploratory Data Analysis (EDA)**: Bigquery(SQL)/GoogleColab(Python)
- **Dashboarding**: Looker Studio
 
# Looker Studio Dashboards and Insights
You can access the Looker studio file from this [link](https://lookerstudio.google.com/u/0/reporting/82a09ffe-b1fc-4b3f-b2db-fb27591a300f/page/p_dh00duy3kd/edit).

## Overview Dashboard
This page is an overview of the project and the contents to be explored,including the context of the project, hypothsis designed as well as a general summary of the data souce being used.


## Financial Performance Dashboard
The Financial Performance dashboard is a page that collected the stock, revenue and subscription performance from 2015-2024. 

-**Global Membership Growth**

First, we decided to take a look over the past 12 years, at both the global revenue and stock prices of Betflix and the subscription. 
The analysis showed steady and incremental growth. Since subscriptions are the primary source of revenue, there's a strong positive correlation between the two. 

-**Impact of Successful Content on Memberships**

The chart Impact of Successful Content on Memberships illustrates the clear relationship between the release of successful content and the annual growth in subscription memberships. It highlights how consistently delivering high-performing content positively influences membership growth.Notably, in 2020, we witnessed the highest subscription growth in the history of the company, which matches the release of the most successful content in that year.This means that to boost revenue, the focus should be on producing content that drives subscription growth - successful content.

-**Global revenue per release date**

This chart shows that for the shows that are most successful in generating revenue and popularity among the audience are usually released on Friday,this is quite logical, as people easily watch TV programs over the weekend.

## Content Analysis Dashboard
The Content Analysis dashboard is an overview of all the watching contents based on their performance metrics.

-**Top 10 directors' and content on average final score**

We saw that the top performers correlated with the ones that the highest average final score  as you can see in this chart.
With the top being Cocomelon of course - with over more than 200 weeks on top 10 on the year 2021-2024.

-**Distribution of Genres by Age Rating**

 So we could provide an overview of the distribution of genres across age categories. It illustrates the relative popularity of each one, with comedy and drama largely dominating the other categories. This chart helps visualize general genre trends across different age groups.

-**Average Viewership score by type**

Television shows are the most successful type of program and it has the highest viewership score.


## User Analysis Dashboard

The User Analysis dashboard is an explores who are our users and what might be their behavirial patterns.

-**Users by Continent**

The majority of our users are in North America, which cohere to the fact that the majority of our contents profuced on the platform is in English. 

-**Users Age partrition**
This chart combined with the pie charts have shown the demographic information of our users. We have a pretty balanced portion in gender group and subscription type. Our users' age group also tend to be younger.The device usage portfolio is also quite evenly distributed. 

## Challenges and Limitations
 
## Future Work




