required_packages <- c("readr", "svglite", "ggplot2", "scales")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(readr)
library(ggplot2)
library(scales)
library(svglite)
Sys.setlocale("LC_ALL", "en_US.utf8")

plot_time_format        <- "%Y-%m-%d"
plot_loc                <- "Germany"
plot_variant            <- "Delta"
plot_cd_thres           <- 0
plot_perc_scaling       <- 600
plot_prim_y_breaks      <- seq(0, 250000, by = 5000)
plot_sec_y_breaks       <- seq(0, 100, by = 5)
plot_colors             <- c(
                             "#00095c",
                             "green3",
                             "#59afff",
                             "#e67301",
                             "gray55",
                             "#0026ff")
data_path <- "Data/"

covid  <- read_csv(paste(data_path, "owid-covid-data.csv", sep = ""),
                   col_types = cols(date = col_date(format = plot_time_format)))

covid  <- covid[covid$location   == plot_loc       &
                covid$new_cases  >= plot_cd_thres  &
                covid$new_deaths >= plot_cd_thres, ]

vec_fatal <- vector(length = length(covid$new_deaths))

for (i in seq_len(length(covid$new_deaths))) {
    vec_fatal[i] <- covid$total_deaths[i] / covid$total_cases[i]
}

covid$fatality <- vec_fatal

plot <- ggplot(NULL,
            aes(x = date),
               fill = group) +
           ggtitle(paste("Total COVID-19 Statistics:", plot_loc, sep = " ")) +

        geom_area(data  = covid, aes(y = new_cases_smoothed,
                  color = "(C) New Cases (smoothed)"),
                  size  = 0.6,
                  alpha = 0.5)  +

        geom_area(data  = covid, aes(y = new_deaths_smoothed ,
                  color = "(C) New Deaths (smoothed)"),
                  size  = 0,
                  alpha = 1,
                  fill = "#0026ff")  +

        geom_line(data  = covid, aes(y = icu_patients,
                  color = "(C) ICU-Patients"),
                  size  = 0.5,)  +

        geom_line(data  = covid, aes(y = people_fully_vaccinated_per_hundred * plot_perc_scaling, # nolint
                  color = "(%) Fully Vacc."),
                  size  = 0.5)  +

        geom_line(data  = covid, aes(y = stringency_index * plot_perc_scaling,
                  color = "(%) Stringency Index"),
                  size  = 0.5)  +

        geom_line(data  = covid, aes(y = fatality * plot_perc_scaling * 100,
                  color = "(%) Case Fatality Rate"),
                  size  = 0.5)  +

        scale_color_manual(name   = "Legend",
                           values = plot_colors) +
        xlab("Date")                             +
        ylab("(C) Cases")                        +
        scale_y_continuous(breaks   = plot_prim_y_breaks,
                           sec.axis = sec_axis(~ . / plot_perc_scaling,
                                               name   = "(%) Percentage",
                                               breaks = plot_sec_y_breaks)) +
        scale_x_date(date_breaks = "2 months", date_labels = "%Y-%b")

plot

ggsave("plot.svg", plot = plot, width = 18, height = 10)