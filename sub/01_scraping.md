Scraping the IMDb website
================
Ta-Chou V. Ng (02 Dec, 2020)

This document demonstrate how to scrape movie profiles from
[IMDb](https://www.imdb.com/). There are three steps: First, we
retrieved the catalog listing the movie IDs and names which will be use
to scrape further in-depth information. Second, we iterated through the
catalog to get various information including ratings, box office, cast
list, and other details of each movie. Finally, we cast the scraped data
into formats that can be used for regression and network analysis.

### 1\. Retriveing the catalog

The search engine on [IMDb](https://www.imdb.com/) website provides
convenient way to search for movie with custom criteria through URL
links. See the following example.

> <https://www.imdb.com/search/title/?title_type=feature&release_date=2001-01-01,2001-12-31&languages=en&sort=release_date,asc&start=1&view=simple>

This URL will give us the list of feature films (`?title_type=feature`)
which released in 2001 (`release_date=2001-01-01,2001-12-31`), and will
show from the first item (`start=1`) in English (`languages=en`), sorted
by releasing dates (`sort=release_date,asc`) with simple views
(`view=simple`). We used this method to filter out the feature films
released from 2000\~2020, and to retrieve the movie ID’s (`imdbID`,
uniquely defined for each movie by IMBb).

The annotated script is shown below. We define `scrape_cat_yr()` to
retrieve the catalog by each year.

``` r
require(tidyverse)
require(rvest)

scrape_cat_yr <- function(yr, export = T){
  
  # specify the time period of releasing dates
  url <- paste0(
    "https://www.imdb.com/search/title/?title_type=feature&release_date=",
    yr, "-01-01,", yr, "-12-31",
    "&languages=en&sort=release_date,asc&start=1&view=simple")
  
  # the number of movies in the search result
  N <- load_page(url)%>% 
    html_nodes(css = "#main > div > div.nav > div.desc > span:nth-child(1)") %>%
    html_text() %>% str_replace("(.+)(of\\s)(.+)(\\stitles.)", "\\3") %>%
    str_replace(",", "") %>% as.integer()
  
  # Because they only show 50 items per page, we have to batch the movies by 50
  # and we use lapply() to iterate through the batches
  df <- lapply(seq(1, N, 50), function(i){
    
    # to avoid being blocked for frequent incessant requests from the website
    Sys.sleep(1)
    # navigating to the sub-page
    h <- str_replace(url, "start=1", paste0("start=", i)) %>%
      load_page()
    
    # get the searched items
    items <- h %>%
      html_nodes(css = "#main > div > div.lister.list.detail.sub-list > div")%>%
      html_children()
    
    # get the movie title and releasing year
    tmp <-items %>% 
      html_nodes(xpath = "//span[@title]") %>%
      html_text(trim = T)%>%
      str_remove("\\n\\s+")
    title <- str_sub(tmp, 1, -7)
    year <- str_sub(tmp, -5, -2) %>% as.integer()
    
    # get the imdb ID
    imdb_ID <- items %>% 
      html_nodes(xpath = "//span[@title]/a")%>% 
      html_attr(name = "href")%>% 
      str_split("/") %>% purrr::map_chr(3)
    
    # output a one-row tibble
    out <- tibble(year = year, title = title, imdb_ID = imdb_ID)
    return(out)
  }) %>% 
    bind_rows()
  
  # save to disk
  if(export) saveRDS(df, file = paste0("dat/FilmCatalog_yr",yr,".RDS"))
  invisible(df)
}
```

And we run the following code snippet to get all catalogs by year.

``` r
lapply(2000:2020, scrape_cat_yr)
```

### 2\. Retriveing individual movie information

Next, we use the movie ID (`imdb_ID`) to scrape for various information
of each movie. We’ll use [A Beautiful Mind
(2001)](https://www.imdb.com/title/tt0268978) as the example. Its
`imdb_ID` is `"tt0268978"`, and we can use that to find the main page of
the movie using the URL: `https://www.imdb.com/title/tt0268978`.

![<https://www.imdb.com/title/tt0268978>](tt0268978.PNG)

And the pages for other details of this movies can be found in the
sub-directories of the main page. We also retrieved information from the
following pages:

  - `.../tt0268978/fullcredits`: A full [credit
    list](https://www.imdb.com/title/tt0268978/fullcredits) including
    the director(s), writer(s), and casts of the movie.
  - `.../tt0268978/ratings`: The IMDb [rating
    scores](https://www.imdb.com/title/tt0268978/ratings) and number of
    votes (by gender and age group).
  - `.../tt0268978/awards`: A list of
    [awards](https://www.imdb.com/title/tt0268978/awards) winned or
    nominated by the movie.
  - `.../tt0268978/taglines`: A list of
    [taglines](https://www.imdb.com/title/tt0268978/taglines) of the
    movie.
  - `.../tt0268978/quotes`: A list of
    [quotes](https://www.imdb.com/title/tt0268978/quotes) of the movie.
  - `.../tt0268978/parentalguide`: The [MPAA
    rating](https://www.imdb.com/title/tt0268978/parentalguide) of the
    movie.

For each movie, therefore, there are in total 7 web pages (1 main page +
6 sub-pages) that we’ll scrape from. We will walk through the codes used
to extract information contained in these pages. Let’s start from the
main page.

#### 2.1 Main page

The main page contains several variables of interest, namely, the
genres, box office, language, country, and plot keywords of the movie.

First, we define a function that loads a web page with http headers
ensuring that we get the returning content in English.

``` r
load_page <- function(x){
  try({
    url(x, headers = c("Accept-Language"= "en-US")) %>%
    read_html(x)
  })
}
```

``` r
iID <- "tt0268978"
url <- paste0("https://www.imdb.com/title/", iID)
```

#### 2.2 Credit list

#### 2.3 Rating scores

#### 2.4 Awards

#### 2.5 Taglines

#### 2.6 Quotes

#### 2.7 MPAA rating
