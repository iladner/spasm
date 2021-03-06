#' Plot Spasm
#'
#' @param sim a simulation produced by sim_fishery
#' @param type the type of plot to produce, one of patch,totals, and doughnut
#' @param font_size base font size for plots
#'
#' @return a ggplot object
#' @export
#'
#' @examples
#' \dontrun{
#'
#' plot_spasm(sim, type = "patch")
#'
#' }
#'
#'
plot_spasm <- function(sim, type = "patch", font_size = 14){

mpayear <- sim$year[which(sim$mpa == TRUE)[1]]

mpasize <- mean(sim$mpa[sim$year > mpayear])

mpasize <- ifelse(is.na(mpasize), 0, mpasize)

ptheme <-  hrbrthemes::theme_ipsum(
  base_size = font_size,
  axis_title_size = font_size,
  strip_text_size = font_size + 2
)

if (type == "patch"){
  out <- sim %>%
    group_by(year, patch) %>%
    summarise(
      Effort = sum(effort),
      Profits = sum(profits),
      Biomass = sum(biomass)
    ) %>%
    ungroup() %>%
    mutate(`Profit Per Unit Effort` = Profits / Effort) %>%
    gather(metric, value,-year, -patch) %>%
    ggplot(aes(year, value, color = factor(patch))) +
    geom_vline(aes(xintercept = mpayear),
               linetype = 2,
               color = "red") +
    geom_line(show.legend = F, size = 1.5) +
    facet_wrap( ~ metric, scales = "free_y") +
    labs(x = "Year",  y = "", caption = "Each line/color represents a patch. Vertical line shows year MPA put in place",
         title = paste("MPA Size:",scales::percent(mpasize))) +
    ptheme

}

if (type == "totals"){

out <- sim %>%
  group_by(year) %>%
  summarise(
    Effort = sum(effort),
    Profits = sum(profits),
    Biomass = sum(biomass)
  ) %>%
  ungroup() %>%
  mutate(`Profit Per Unit Effort` = Profits / Effort) %>%
  gather(metric, value,-year) %>%
  ggplot(aes(year, value)) +
  geom_vline(aes(xintercept = mpayear),
             linetype = 2,
             color = "red") +
  geom_line(show.legend = F, size = 1.5) +
  facet_wrap( ~ metric, scales = "free_y") +
  labs(x = "Year",  y = "", caption = "Vertical line shows year MPA put in place",
       title = paste("MPA Size:",scales::percent(mpasize))) +
  ptheme

}

if (type == "doughnut"){


  out <- sim %>%
    group_by(year, patch) %>%
    summarise(
      Effort = sum(effort),
      Profits = sum(profits),
      Biomass = sum(biomass),
      mpa = unique(mpa)
    ) %>%
    ungroup() %>%
    mutate(`Profit Per Unit Effort` = Profits / Effort) %>%
    gather(metric, value,-year,-patch,-mpa) %>%
    group_by(metric) %>%
    mutate(svalue = value / max(value, na.rm = TRUE)) %>%
    ungroup()

  out <- out %>%
    # filter(year == max(year)) %>%
    ggplot(aes(patch,svalue, fill = mpa)) +
    geom_col(alpha = 0.75,
             color = "transparent",
             width = 1) +
    facet_wrap(~metric) +
    coord_polar() +
    gganimate::transition_time(year) +
    gganimate::ease_aes('linear') +
    labs(title = 'Year: {frame_time}',x = "'",  y = "Relative Value") +
    ptheme
}

return(out)

}