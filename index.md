##### 2020 BST260 Final Project - Group 8
# Predicting the movie success  

**Team members: Jie Sun, Ta-Chou Ng (Vincent), Yu Sun**

## Screencast 
<iframe width="80%" src="https://www.youtube.com/embed/CZdfWBSst0U" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Overview and Motivation: 

Predicting the success of a movie is important for the film-making company (to produce what kind of movie). Our primary motivation is to understand how common features and the network properties relate to a movie success, and develop predictive models to identify the next blockbuster. 

## Initial Questions:
We approach this goal using 3 different analysis, and ask these questions

-  (1) **Movie exploration** (Yu Sun):
    - How does the movie industry look over the last two decades, in terms of different features, such as box office, genre, rating and award winning? 
    - Which features correlates with the success of a movie (ratings and the box office)
    - Is there a way to visualize the IMDB movie data on an aggregate scale, based on user inputs such as year, cast and genre?
    
-  (2) **Collaboration network analysis** (Vincent Ng): 
    - How are movies, actors and directors connected, and what is the strength of their associations? 
    - What does the movie collaboration network look like? Are those successful movies clustered together?
    
-  (3) **Logistic regression** (Jie Sun): 
    - What predicts the success of a movie? How likely it is for an upcoming film project to succeed?
    - As an investor for an upcoming filming project, given cast, director and genre, what is the probability that this movie is going to be a success? 
    

## Related Work: 
#### (1) Shiny App for exploring movie exploration:
Since our data is about movies and our purpose is to explore such data and figure out some analysis related to such dataset, Shiny app becomes an appropriate tool for us to make such dataset visualized. Moreover, in the Shiny app gallery, we found one perfect instance for our project. (link: https://shiny.rstudio.com/gallery/movie-explorer.html). In such an example, the data is from a subset of data from the OMDb (link: http://www.omdbapi.com/) that is saved in an SQLite database and came from IMDb and Rotten Tomatoes. (figure 1: screenshot of database)
The major function for this Shiny app is to display a plot with information that selected by the users; for instance, the users can choose the released year, number of Oscar wins, or genre of the movies and the app will make a relative plot based on those selections, which we also have discussed in the class. Moreover, the users can select the x-axis and y-axis that correspond to different variables in the database. Besides, the users can search for specific director or cast members and the app will filter such movies with information on the plot.
Therefore, we were inspired by such work and decided to achieve similar functions that were included in this app by our own dataset and try to understand the method to produce a successful movie.

#### (2) Movie collaboration network analysis:
In network analysis, movie collaboration networks represent the relationship of movies in terms of sharing directors, writers, or casts. For example, in such network, the link between movies exists if they share any same actor or actress (see [co-stardom network](https://en.wikipedia.org/wiki/Co-stardom_network) ). The same logic extends to co-directors, co-writers, and so on. A related famous example is the actor/actress network where we link two actors/actresses when they both appear in a same movie. The [Kevin Bacon game](https://oracleofbacon.org/) then utilize the network to study who is in the center or the periphery of the whole Hollywood universe. 
The notion of collaboration network applies to other fields, like arts and academics (see [here](https://www.nature.com/articles/s41586-018-0315-8) and [here](https://science.sciencemag.org/content/362/6416/825/)). It has been used to predict the success of an artist or a researcher’s career with the premise that success (in a sense of popularity, or citations) has a lot to do with social relationships embedded in the collaboration network. In our project, we try to adopt the same notion, and to explore whether a movie’s success does relate to its network property.

#### (3) Regression modeling:
Netflix has launched a challenge a fews years ago to identify effective movie recommendation system based on user preferences and past watch history. This approach aims at minimizing the RMSE (https://dl.acm.org/doi/10.1145/2843948). 


## Data: 
We expect that features of each movie (such as genre(s), director and cast, etc.), and the movie’s network property in the whole collaboration network can possibly predict its success. These features and the outcome of success(defined by overall ratings or box office) were scraped from the [IMDb](https://www.imdb.com/) website. We mainly focused on recent movies which released during 2000 ~ 2020. Detail of the methods, codes, and demonstration of our web scraping analysis can be found in [here](pages/01_scraping.html), or the [Rmarkdown file](pages/01_scraping.Rmd)

## Exploratory Analysis:
We had two different ways, including a social network graph and interaction scatter plot in Shiny app, to visualize our data. For the social network graph, we were trying to understand the relationship between different actors so that we can find the so-called centre of Hollywood and figure out the successful strategies or methods in movie production. Moreover, for the Shiny app, it was designed to interact with the selections from the users, helping them get familiar with our data set and understand or evaluate our assumptions about the movie industry. 
In order to analyze the success of a specific movie, we decided to utilize a logistic regression model to predict the possibility of achievement based on the crew members of the movie, including the cast, director, and writer. The success of the movie was defined as whether it had a high rating score on the IMDb (above 7) or it had won the award such as Oscar. 
Furthermore, once we finished logistic model, we will try to make a “investment game” that the users can select conditions, such as cast, director and genre, to make a movie they want, and the “investors”, the logistic model, will show a probability of whether that specific movie will be successful based on our standard, corresponding to the conditions of the movie they made. Details can be found in [here](pages/02_exploration.html), or the [Rmarkdown file](pages/02_exploration.Rmd)

## Final Analysis: 
#### (1) Movie exploration
From the Shiny app analysis, we found that we can utilize the different features of movies, such as genre, year, box office, to plot a scatter plot which help us to visualize the data set and achieve the interaction with users. Moreover, based on the plot, we can visualize the trend and overall situations of the movie industry over the last 20 years, such as movies with cumulative worldwide gross over 2 billion dollars that had the overall rating between 3 and 8. Therefore, our question, that focuses on finding a method to visualize the IMDb movie data, was answered by introducing an interactive Shiny App, which allows the users to input different information for specific movie filtration.
#### (2) Network analysis
We visualize the collaboration movie network in the same Shiny app above. The users can explore the local network pattern of their selected movie. They can also select different variables of success and layers of the collaboration network to see if how their movies perform in other perspectives (such as user ratings or awards wined). Details can be found in [here](pages/03_network.html), or the [Rmarkdown file](pages/03_network.Rmd)
#### (3) Logistic regression
We built 4 models to study the relationship between a movie’s success and covariates such as cast, director and genre of the movie. Details can be found in [here](pages/04_logistic_regression.html), or the [Rmarkdown file](pages/04_logistic_regression.Rmd)



## Shiny Application 
Our Shiny application can be online found [here](https://dachuwu.shinyapps.io/2020BST260_group8_movie/), though we recommend to run on your own computer. The data and Shiny script can be found [here](https://github.com/dachuwu/2020BST260_group8_movie)



