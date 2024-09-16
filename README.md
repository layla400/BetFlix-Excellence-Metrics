# **BetFlix-Excellence-Metrics**

This project focuses on analyzing content success metrics for Betflix, a video streaming platform. Using real Netflix data, we explore the trends, patterns, and factors that contribute to the success of TV shows and movies on the platform.

## **Project Overview**

The objective is to provide a data-driven assessment of Betflix content. We aim to identify key attributes that drive content popularity, such as genre, release year, user ratings, and viewership metrics. Insights from this analysis will guide strategic decisions in content creation and maximize ROI for the platform.

## **Project Motivation**

1. Identify key features contributing to the success of Betflix content.
2. Provide actionable insights to optimize content strategy and increase viewership.
3. Develop a predictive model to forecast the success of future content.

---

## **Data Description**

- [**Netflix_titles**](https://www.kaggle.com/datasets/paramvir705/netflix-dataset)
- [**IMDB Dataset**](https://docs.google.com/spreadsheets/d/1MnhUFfkANskF_f-JHaWFxpIJPppSrqrY8R05s-A84fQ/edit?gid=1971309909#gid=1971309909)
- [**Netflix User Base**](https://www.kaggle.com/datasets/arnavsmayan/netflix-userbase-dataset/data)
- [**Global_all_weeks**](https://docs.google.com/spreadsheets/d/198DZVpLAxUZDBlGA5cMYl3-bIJQAdm9h/edit?usp=sharing&ouid=106503551153519138225&rtpof=true&sd=true)
- [**Netflix_stock**](https://www.kaggle.com/datasets/mayankanand2701/netflix-stock-price-dataset)
- [**Netflix_Global_Revenue**](https://www.kaggle.com/datasets/adnananam/netflix-revenue-and-usage-statistics/data)

- [**Tables' ERD**](https://lucid.app/lucidchart/5c148e6c-b7a1-41d5-8d01-31189a4c7e86/edit?page=0_0&invitationId=inv_488da03f-fd0f-4428-8153-a8e92569e2d3#)
![ERD](https://github.com/user-attachments/assets/f05dedba-bba2-49e3-a4d7-8a8a1d08483d)

---

## **Data Exploration**

### **Methods**
- **Data Cleaning**: GoogleSheets / BigQuery (SQL) / GoogleColab (Python)
- **Exploratory Data Analysis (EDA)**: BigQuery (SQL) / GoogleColab (Python)
- **Dashboarding**: Looker Studio

---

## **Looker Studio Dashboards and Insights**

You can access the Looker Studio dashboard from this [link](https://lookerstudio.google.com/u/0/reporting/82a09ffe-b1fc-4b3f-b2db-fb27591a300f/page/p_dh00duy3kd/edit).

### **Overview Dashboard**

This dashboard provides an overview of the project, including the context, hypothesis, and a general summary of the data sources used.

### **Financial Performance Dashboard**

This dashboard focuses on financial metrics such as stock prices, global revenue, and subscription performance from 2015 to 2024.

- **Global Membership Growth**  
  The analysis reveals steady and incremental growth in both global revenue and subscription numbers over the past 12 years. A strong positive correlation is observed between global memberships and revenue growth, which aligns with the business model of Betflix.

- **Impact of Successful Content on Memberships**  
  The chart shows the correlation between the release of successful content and the annual growth in subscriptions. In 2020, there was the highest subscription growth, coinciding with the release of successful content.

- **Global Revenue by Release Date**  
  This analysis shows that most successful content is released on Fridays, when users are more likely to engage with streaming platforms over the weekend.

### **Content Analysis Dashboard**

This dashboard explores content performance based on metrics like viewership scores, genres, and director impact.

- **Top 10 Directors & Content on Average Final Score**  
  Directors and content with the highest average final score are displayed, with Cocomelon being the top performer, spending over 200 weeks in the top 10 between 2021-2024.

- **Distribution of Genres by Age Rating**  
  Comedy and drama dominate across all age groups, reflecting general audience preferences.

- **Average Viewership Score by Type**  
  TV shows consistently outperform other content types in terms of viewership scores.

### **User Analysis Dashboard**

This dashboard explores user demographics and behavior patterns.

- **Users by Continent**  
  The majority of users come from North America, which corresponds with the platform's heavy focus on English-language content.

- **User Age Distribution**  
  The age distribution chart shows that a majority of Betflix's users are younger, with a relatively balanced gender distribution. Device usage for streaming is also evenly distributed.

---

## **Challenges and Limitations**

1. Data availability was limited to certain regions, which might skew some of the global analyses.
2. There were some missing values and inconsistencies in the data that required extensive cleaning.

---

## **Future Work**

1. Expand analysis to include more granular data on user engagement (e.g., time spent watching content, repeat views).
2. Incorporate machine learning models to predict future content success based on historical data.
3. Explore user preferences by deeper demographic insights (e.g., income, education).

---

