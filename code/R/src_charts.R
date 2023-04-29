
# main
"#1046b1"

# background
"#f7f7f7"
"#e8e8e8"
"#cecece"

# gradient
"#0C6291"
"#4889ab"
"#84b0c5"
"#c0d7df"
"#f697bb"
"#C85B89"
"#B13D70"
"#991E56"

# 4 color scheme
"#4889ab"
"#7fc6a4"
"#B13D70"
"#F7DD72"

# 5 color scheme 2
"#4889ab"
"#7fc6a4"
"#FCB13B"
"#B13D70"
"#f697bb"

# 10-color gradient
"#0C6291"
"#2A769E"
"#4889ab"
"#669DB8"
"#84b0c5"
"#93BACC"
"#A2C4D2"
"#c0d7df"
"#DCE7EB"
"#f7f7f7"

"#2B303A"

"#0C6291"
"#4889ab"
"#c0d7df"
"#B13D70"
"#f697bb"
"#307351"
"#7fc6a4"
"#FCB13B"
"#F7DD72"
"#f7f7f7"

# chart template
charts.theme <- theme(axis.title.y.left = element_text(size = 12, margin = margin(r = 15)),
                      axis.title.y.right = element_text(size = 12, margin = margin(l = 15)),
                      axis.title.x = element_text(size = 12, margin = margin(t = 15)),
                      #axis.text.x = element_text(size = 12, angle = 90, vjust = 0.5),
                      axis.text.x = element_text(size = 12),
                      axis.text.y = element_text(size = 12),
                      axis.ticks = element_blank(),
                      #axis.line.x = element_line("black", size = 0.5), 
                      #axis.line.y = element_line("black", size = 0.5),
                      axis.line.x = element_line("transparent", size = 0.5), 
                      axis.line.y = element_line("transparent", size = 0.5),
                      panel.border = element_rect(color = "#a3a3a3", fill = "transparent"),
                      panel.background = element_rect(fill = "white", color = "white"),
                      #panel.grid.major = element_line(color = "white"),
                      #panel.grid.minor = element_line(color = "white"),
                      panel.grid.major = element_line(color = "#d4d4d4", linetype = "dotted"),
                      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
                      plot.subtitle = element_text(size = 10, face = "italic", hjust = 0.5, margin = margin(b = 15)),
                      legend.position = "bottom",
                      legend.box = "vertical",
                      legend.box.margin = margin(b = 15),
                      legend.margin = margin(r = 10),
                      legend.background = element_rect(fill = "transparent"),
                      legend.spacing.x = unit(0.4, "cm"),
                      legend.key = element_blank(),
                      legend.title = element_blank(),
                      legend.text = element_text(size = 12),
                      plot.caption = element_text(size = 9, hjust = 0, face = "italic"),
                      strip.background = element_rect(fill = "transparent"),
                      strip.text = element_text(size = 12))