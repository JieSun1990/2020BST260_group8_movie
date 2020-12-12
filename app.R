# load packages
pkgs <- c("tidyverse", "shiny", "shinythemes", "visNetwork")
for(x in pkgs){
  if(!x %in% installed.packages()[,1]) install.packages(x)
  library(x, character.only = T)
}

# Tab1 data
# p <- readRDS("dat/Data_people_00to20.RDS")
# s <- readRDS("dat/Data_info_00to20.RDS")
# all_movies <- inner_join(p, s, by = "imdb_ID")
load("dat/Module1_EDA.RData")

# Tab2 data
load("dat/Module2_network.RData")



ui <- fluidPage(theme = shinytheme("cyborg"),
                titlePanel("Movie Adventure"),
                tabsetPanel(
                  tabPanel("Data Exploration", # 
                           fluidRow(
                             column(3,
                                    sliderInput(inputId = "year", label = "Year Released",
                                                min = 2000, max = 2020, value = c(2000,2020),
                                                sep = "", step = 1)),
                             column(3,
                                    sliderInput("boxoffice", "Dollars at Box Office (millions)",
                                                0, 2800, c(0, 2800), step = 10)),
                             column(3,
                                    selectInput("x",
                                                label = "X axis",
                                                c("Rating All","Rating Female", "Rating Male",
                                                  "Award Win", "Award Nominee"),
                                                selected = "Rating All")),
                             column(3,
                                    selectInput("y",
                                                label = "y axis",
                                                c("Budget","Open-week gross in USA",
                                                  "Gross in USA",
                                                  "Cumulative Worldwide Gross"),
                                                selected = "Cumulative Worldwide Gross"))),
                           fluidRow(
                             column(3,
                                    selectInput("country",
                                                label = "Choose a Country",
                                                c("All","USA","UK","Canada","France",
                                                  "Germany", "Australia","India",
                                                  "Italy","China","Spain","Ireland",
                                                  "Japan"))),
                             column(3,
                                    selectInput("genre", "Genre (a movie can have multiple genres)",
                                                c("All", "action", "adventure", "animation", "biography", "comedy",
                                                  "crime", "drama", "family", "fantasy", "history",
                                                  "horror", "music", "musical", "mystery", "romance", "sci-fi",
                                                  "sport", "thriller", "war", "western"))),
                             column(3,
                                    selectInput("language",
                                                label = "Choose a Language",
                                                c("All","English","Spanish","French","German",
                                                  "Italian")))
                           ),
                           fluidRow(
                             column(width = 12,
                                    plotOutput("scatterplot",
                                               click = "sp_click",brush = brushOpts(
                                                 id = "plot1_brush"
                                               )))),
                           fluidRow(
                             column(width = 6,
                                    h4("Points near click"),
                                    verbatimTextOutput("click_info")
                             ),
                             column(width = 6,
                                    h4("Brushed points"),
                                    verbatimTextOutput("brush_info")
                             )
                           )
                                     
                ),
                  tabPanel("Network Exploration", # 
                           br(),
                           fluidRow(
                             column(10,
                                    HTML("<div style='color:#FFFFFF;font-size:110%'>
                                    <b style='color:#ffffcc;font-size:120%'>Movie collaboration networks</b> represent the relationship of movies in terms of co-casting, co-directing, and co-writing. 
                                        Try to see if the network position and predict the success of a movie. Larger nodes means higher success.
                                        <br><br>
                                        <p style='color:#FFFFFF'><b>
                                        (1) Select your favorite movie to see its collaboration network.<br>
                                        (2) Select the type of success (the default of average IMDb rating). This will show as the node size.<br>
                                        (3) Select the layer of the collaboration network, This changes the definition of links.</b>
                                        <br><br>
                                        </p>
                                        Is your movie successful?<br> 
                                        Is it also surrounded by successful movies? Or the other way around?<br>
                                        Hover through the nodes and the links to see their attributes.<br>
                                        Change the settings to see how your movie performs in other perspectives.<br>
                                        </div>")
                                    )
                           ), hr(),
                           fluidRow(
                             column(5,
                                    selectizeInput("m2_mvn", "(1) Select one movie as the center", 
                                                   choices = ndls$title, selected = "Interstellar", 
                                                   multiple = F, 
                                                   options = list(placeholder = "Type to search")))
                             
                           ),
                           fluidRow(
                             column(5,
                                    selectizeInput("m2_y", "(2) Select the type of success", 
                                                   choices = c("Average IMDb rating" = "rating_all", 
                                                               "Total IMDb rating" = "rating_all_vote", 
                                                               "Box office (US)" = "gross_usa", 
                                                               "Box office (World-wide)" = "cumulative_worldwide_gross",
                                                               "Number of awards wined" = "award_win"), 
                                                   multiple = F, 
                                                   options = list(placeholder = "Choose one"))),
                             column(5,
                                    selectizeInput("m2_ntype", "(3) Select the layer of collaboration network", 
                                                    choices = c("Co-starring" = "c_c", 
                                                               "Co-directing" = "c_d", "Co-writing" = "c_w"), 
                                                   multiple = F, 
                                                   options = list(placeholder = "Choose one")))
                           ),
                           fluidRow(
                             column(10,
                                    visNetworkOutput("m2_out_g1", width = "100%", height = "500px")  ),
                             column(2)
                           ),
                           hr(),
                           fluidRow(
                             column(10,
                                    HTML("<div style='color:#FFFFFF;font-size:100%'>
                                    Note: This present the ego network of the movie you choosed. 
                                    Higher order links (links between the neighbors) are ommitted if they are too weak.
                                    <br>
                                    See our <a href='https://dachuwu.github.io/2020BST260_group8_movie/' target='_blank'>website</a> for more information.
                                    <br><br><br><br></div>")
                             )
                           )

                  )
                )
)

server <- function(input, output) {
 
  
  # Module 1 (Yu)
  movies <- reactive({
    minyear <- input$year[1]
    maxyear <- input$year[2]
    minboxoffice <- input$boxoffice[1]
    maxboxoffice <- input$boxoffice[2]
    L <- paste0("lang_", input$language)
    G <- paste0("genre_", input$genre)
    C <- paste0("country_", input$country)
    
    
    m <- all_movies %>%
      filter(
        year >= minyear,
        year <= maxyear,
        cumulative_worldwide_gross >= minboxoffice,
        cumulative_worldwide_gross <= maxboxoffice
      )
    
    if (input$genre != "All") {
      m <- m %>% filter(.data[[G]] == 1)
    }
    if (input$language != "All"){
      m <- m %>% filter(.data[[L]] == 1)
    }
    if (input$country != "All"){
      m <- m %>% filter(.data[[C]] == 1)
    }
    m <- data.frame(m)
  })
  
  click1 <- reactive(movies()[, c("year", "title", "rating_all","rating_female",
                                  "rating_male","genres",
                                  "director", "writer","cast",
                                  "award_win","award_nom", "winner_oscar",
                                  "budget", "opening_weekend_usa", "gross_usa",
                                  "cumulative_worldwide_gross")])
  
  click2 <- reactive(movies()[, c("year", "title", "rating_all","rating_female",
                                  "rating_male","genres",
                                  "award_win","award_nom",
                                  "budget", "opening_weekend_usa", "gross_usa",
                                  "cumulative_worldwide_gross")])
  
  output$scatterplot = renderPlot({
    if (input$x == "Rating All"){
      if (input$y == "Budget"){
        movies() %>%
          ggplot(aes(rating_all,budget)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      }
      else if (input$y == "Open-week gross in USA"){
        movies() %>%
          ggplot(aes(rating_all,opening_weekend_usa)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      } else if (input$y == "Gross in USA"){
        movies() %>%
          ggplot(aes(rating_all,gross_usa)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      } else if (input$y == "Cumulative Worldwide Gross"){
        movies() %>%
          ggplot(aes(rating_all,cumulative_worldwide_gross)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      }
    } else if (input$x == "Rating Female"){
      if (input$y == "Budget"){
        movies() %>%
          ggplot(aes(rating_female,budget)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      }
      else if (input$y == "Open-week gross in USA"){
        movies() %>%
          ggplot(aes(rating_female,opening_weekend_usa)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      } else if (input$y == "Gross in USA"){
        movies() %>%
          ggplot(aes(rating_female,gross_usa)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      } else if (input$y == "Cumulative Worldwide Gross"){
        movies() %>%
          ggplot(aes(rating_female,cumulative_worldwide_gross)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      }
    } else if (input$x == "Rating Male"){
      if (input$y == "Budget"){
        movies() %>%
          ggplot(aes(rating_male,budget)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      }
      else if (input$y == "Open-week gross in USA"){
        movies() %>%
          ggplot(aes(rating_male,opening_weekend_usa)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      } else if (input$y == "Gross in USA"){
        movies() %>%
          ggplot(aes(rating_male,gross_usa)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      } else if (input$y == "Cumulative Worldwide Gross"){
        movies() %>%
          ggplot(aes(rating_male,cumulative_worldwide_gross)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          scale_x_continuous(breaks = seq(0, 10, 1), limits = c(0, 10)) +
          ggtitle(paste0(input$x, " vs ", input$y))
      }
    } else if (input$x == "Award Win"){
      if (input$y == "Budget"){
        movies() %>%
          ggplot(aes(award_win,budget)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          ggtitle(paste0(input$x, " vs ", input$y))
      }
      else if (input$y == "Open-week gross in USA"){
        movies() %>%
          ggplot(aes(award_win,opening_weekend_usa)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          ggtitle(paste0(input$x, " vs ", input$y))
      } else if (input$y == "Gross in USA"){
        movies() %>%
          ggplot(aes(award_win,gross_usa)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          ggtitle(paste0(input$x, " vs ", input$y))
      } else if (input$y == "Cumulative Worldwide Gross"){
        movies() %>%
          ggplot(aes(award_win,cumulative_worldwide_gross)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          ggtitle(paste0(input$x, " vs ", input$y))
      }
    } else {
      if (input$y == "Budget"){
        movies() %>%
          ggplot(aes(award_nom,budget)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          ggtitle(paste0(input$x, " vs ", input$y))
      }
      else if (input$y == "Open-week gross in USA"){
        movies() %>%
          ggplot(aes(award_nom,opening_weekend_usa)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          ggtitle(paste0(input$x, " vs ", input$y))
      } else if (input$y == "Gross in USA"){
        movies() %>%
          ggplot(aes(award_nom,gross_usa)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          ggtitle(paste0(input$x, " vs ", input$y))
      } else if (input$y == "Cumulative Worldwide Gross"){
        movies() %>%
          ggplot(aes(award_nom,cumulative_worldwide_gross)) +
          geom_point() +
          xlab(paste0(input$x)) +
          ylab(paste0(input$y, " (in Million US dollar)")) +
          ggtitle(paste0(input$x, " vs ", input$y))
      }
    } 
  })
  output$click_info <- renderPrint({
    nearPoints(click1(),input$sp_click, addDist = TRUE)
  })
  output$brush_info <- renderPrint({
    brushedPoints(click2(), input$plot1_brush)
  })
  
  # Module 2 (Vincent)
  m2_g1 <- reactive({
    if(input$m2_mvn %in% ndls$title){
      plot_mv_ego(input$m2_mvn, evar = input$m2_ntype, max.n = 70, 
                  nodeLS = ndls, edgeLS = edls, m2i = mvn2id, i2r = id2rating, yvar = input$m2_y)
    }
  })
  output$m2_out_g1 <- renderVisNetwork(m2_g1())
  
  # Module 2 (Jie)
}

shinyApp(ui = ui, server = server)