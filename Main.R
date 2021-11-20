library(tidyverse)
library(ggplot2)

covid <- read_csv("Data/owid-covid-data.csv",
                  col_types = cols(date = col_date(format = "%Y-%m-%d")))

variants <- read_csv("Data/covid-variants.csv",
                  col_types = cols(date = col_date(format = "%Y-%m-%d")))

covid <- covid[covid$location   == "Germany" &
               covid$new_cases  >= 0         &
               covid$new_deaths >= 0, ]

variants <- variants[variants$location == "Germany" &
                     variants$variant  == "Delta", ]

prim_y_breaks <- c(0, 5000, 10000, 15000, 20000, 25000, 30000,
                   35000, 40000, 45000, 50000, 55000, 60000, 65000)
sec_y_breaks  <- c(0, 15, 30, 45, 60, 75, 90, 100)
colors        <- c("firebrick2",
                   "navyblue",
                   "green3",
                   "darkorchid",
                   "#e67301",
                   "gray55",
                   "black",
                   "mediumpurple4")

vec_fatal <- vector()

for (i in seq_len(length(covid$new_deaths))) {

    vec_fatal[i] <- covid$total_deaths[i] / covid$total_cases[i]
}

covid$fatality <- vec_fatal
#View(covid)

p <- ggplot(NULL,
            aes(x = date),
            fill = group) +
     ggtitle("Total COVID-19 statistics: Germany") +

     geom_area(data  = covid, aes(y       = new_cases,
               color = "(C) New Cases"),
               size  = 0.5,
               alpha = 0.5) +

     geom_line(data  = covid, aes(y       = new_cases_smoothed,
               color = "(C) New Cases (smoothed)"),
               size  = 0.6)  +

     geom_line(data  = covid, aes(y       = new_deaths,
               color = "(C) New Deaths"),
               size  = 0.6)  +

     geom_line(data  = covid, aes(y       = icu_patients,
               color = "(C) ICU-Patients"),
               size  = 0.5)  +

     geom_line(data  = covid, aes(y       = people_fully_vaccinated_per_hundred * 500,
               color = "(%) Fully Vacc."),
               size  = 0.5)  +

     geom_line(data  = covid, aes(y       = stringency_index * 500,
               color = "(%) Stringency Index"),
               size  = 0.5)  +

     geom_line(data  = covid, aes(y       = fatality * 500000,
               color = "(%) Case Fatality Rate * 10"),
               size  = 0.5)  +

    geom_line(data  = variants, aes(y     = perc_sequences * 500,
              color = "(%) Delta variant"),
              size  = 0.25,
              linetype = "dotted")  +

     scale_color_manual(name   = "Legend",
                        values = colors) +
     xlab("Date")                        +
     ylab("(C) Cases")                   +
     scale_y_continuous(breaks   = prim_y_breaks,
                        sec.axis = sec_axis(~ . / 50000 * 100,
                                            name   = "(%) Percentage",
                                            breaks = sec_y_breaks))
p