# This is my project in R for Data Cleaning & Extraction.
# Name : Grama Alex Ștefan

# After each task complete I will provide a short visualisation of each result.
# Every statement I left is to provide information about the initial approach
# of the task itself and show my thinking proccess.
# At the end of my project I'm going to run a few hypothesis tests.

# The included dataset was provided from:
# https://mavenanalytics.io/data-playground?accessType=open&dataStructure=Single%20table&order=date_added%2Cdesc

# 1. What is the most title sold worldwide ?
# 2. Which titles sold the most worldwide?
# 3. Which year had the highest sales?
# 4. Do any consoles seem to specialize in a particular genre? 
# 5. What titles are popular in one region but flop in another?

# Importing the initial dataset.

library(readr)

data <- read.csv("D:/Data Analyst Portfolio/Proiect R/Fisiere R/CSV pentru R/vgchartz2024.csv")

library(dplyr)

View(data)

# Deleting unecesarry columns
data_vgames <- data %>% 
  select(-c(img, last_update))

View(data_vgames)

# Checking how many nulls I have in my dataset
sum(is.na(data_vgames))

# Deleting the null values
cleaned_data <- na.omit(data_vgames)
sum(is.na(cleaned_data))
View(cleaned_data)

## 1. The most title sold worldwide
## title, sum of the total sales

library(dplyr)
library(tidyr)

sum_titles <- cleaned_data %>% 
  group_by(title) %>% 
  summarise(total_sales = sum(total_sales)) %>% 
  arrange(desc(total_sales))  
  View(sum_titles)


## 2. Which titles sold the most worldwide?
## The answer is :Grand Theft Auto V with the number
## of total sales by 48.43

top_titles <- sum_titles %>%
slice_max(total_sales, n = 10)

ggplot(top_titles, aes(x = reorder(title, -total_sales), y = total_sales, fill = title)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  labs(title = "Top 10 Titles by Total Sales",
       x = "Game Title",
       y = "Total Sales (in millions)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    text = element_text(size = 10))


## 3. Highest sales per year
## release_date, sum of the total sales 

library(lubridate)

cleaned_data <- cleaned_data %>%
  mutate(release_year = year(release_date))

highest_year_sales <- cleaned_data %>%
  group_by(release_year) %>%
  summarise(total_sales = sum(total_sales)) %>%
  arrange(desc(total_sales)) 
  View(highest_year_sales)

library(ggplot2)

ggplot(highest_year_sales, aes(x = reorder(as.factor(release_year), total_sales), y = total_sales)) +
  geom_bar(stat = "identity", fill = "steelblue", color = "black") +
  coord_flip() +  
  labs(title = "Total Sales by Release Year",
       x = "Release Year",
       y = "Total Sales") +
  theme_minimal() +
  theme(text = element_text(size = 10))


## 4. The console genre specialisation. 
## count the genre, sum of count of the genre, group by console, 
## showing only 

library(dplyr)
library(tidyr)

unique(cleaned_data$genre) 
  
console_genres <- cleaned_data %>% 
  group_by(console, genre) %>% 
  summarise(genre_count = n()) %>%  
  slice_max(genre_count) 
  View(console_genres)

library(ggplot2)

top_consoles <- console_genres %>% slice_max(genre_count, n = 10)

ggplot(top_consoles, aes(x = console, y = genre_count, fill = genre)) +
  geom_bar(stat = "identity") +
  labs(title = "Top Consoles by Most Popular Genres",
       x = "Console",
       y = "Genre Count",
       fill = "Genre") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
  text = element_text(size = 12))
  
## 5. Titles popularity by region. 
## sum of the different regions, grouped by the title
  
library(dplyr)
library(tidyr)
  
sum_titles_worldwide <- cleaned_data %>% 
  group_by(title) %>% 
  summarise(na_sales = sum(na_sales),
            jp_sales = sum(jp_sales),
            pal_sales = sum(pal_sales),
            other_sales = sum(other_sales)) %>% 
    arrange(desc(na_sales))  
    View(sum_titles_worldwide)
    
    
sum_titles_worldwide_long <- sum_titles_worldwide %>%
  pivot_longer(cols = c(na_sales, jp_sales, pal_sales, other_sales),
  names_to = "region",
  values_to = "sales")

top_titles <- sum_titles_worldwide_long %>%
  group_by(title) %>%
  summarise(total_sales = sum(sales)) %>%
  slice_max(total_sales, n = 10) %>%
  inner_join(sum_titles_worldwide_long, by = "title")    

ggplot(top_titles, aes(x = reorder(title, -sales), y = sales, fill = region)) +
  geom_bar(stat = "identity") +
  labs(title = "Top 10 Titles by Regional Sales",
       x = "Game Title",
       y = "Sales (in millions)",
       fill = "Region") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 7),
        text = element_text(size = 10))

    
# The hypothesis tests.

# The hypothesis test is a test for predictabilty similar to an
# A-B testing in Python.
    
# Comparing the sales inbetween two regions.
t_test_result <- t.test(sum_titles_worldwide$na_sales, sum_titles_worldwide$jp_sales)
print(t_test_result)

# p-value < 2.2e-16 being smaller than the standard 0.05
# this rejects the null hypothesis and clearly tell
# that there is significant difference between the regions.

# Association between consoles & genres.
chi_square_result <- chisq.test(table(console_genres$console, console_genres$genre))
print(chi_square_result)

#Warning message:
#  In chisq.test(table(console_genres$console, console_genres$genre)) :
#  Chi-squared approximation may be incorrectv

# Even though the final output of p-value is not correct at least it shows
# something that we can interpret.

# p-value = 0.8998 having a bigger number than the standard 0.05
# will conclude that we don't have sufficient evidence to 
# have a proper result


# Testing sales proportion from na_sales 
prop_test_result <- prop.test(x = sum(sum_titles_worldwide$na_sales), n = sum(sum_titles$total_sales))
print(prop_test_result)

# p-value = 0.0007971 the na_sales have a significant difference

# Testing sales proportion from jp_sales
prop_test_result <- prop.test(x = sum(sum_titles_worldwide$jp_sales), n = sum(sum_titles$total_sales))
print(prop_test_result)

# p-value < 2.2e-16 is significantly differnt and rejects
# the null hypothesis is out of our ecuation.

# Testing sales proportion from pal_sales
prop_test_result <- prop.test(x = sum(sum_titles_worldwide$pal_sales), n = sum(sum_titles$total_sales))
print(prop_test_result)

# p-value < 2.2e-16 same thing as the jp_sales


# I Will export the data results from top to bottom

write.csv(cleaned_data, "cleaned_data.csv", row.names = FALSE)
write.csv(sum_titles, "sum_titles.csv", row.names = FALSE)
write.csv(sum_titles_worldwide, "sum_titles_worldwide.csv", row.names = FALSE)
write.csv(highest_year_sales, "highest_year_sales.csv", row.names = FALSE)
write.csv(console_genres, "console_genres.csv", row.names = FALSE)


# As an enclosure thank you very much sticking by my project
# And also would love to check my other projects.
# HAVE A GOOD DAY ! :) 
  

  






















