## Descriptives


# I. Preliminaries --------------------------------------------------------

# packages
pacman::p_load(tidyverse, readxl, openxlsx, RDS, scales, knitr, kableExtra, grid, 
               gridExtra, patchwork, ggpubr, lubridate, plyr, ggridges, vtable,
               readr, stringr, quanteda, quanteda.textstats, rvest, tibble, xml2)

# directories
wd = "/Users/janinedevera/Documents/School/MDS 2021-2023/Thesis/multilabel-legal-text-classification-CIA"
pathdata = paste0(wd, "/data")
pathcharts = paste0(wd, "/draft/images")

# charts themes
source(paste0(wd, "/code/R/src_charts.R"))


# II. Load Data -----------------------------------------------------------

text <- read.csv(paste0(pathdata, "/01 legal_texts_pipeline_stopwords.csv")) # unlabeled corpus
text_labeled <- read.csv(paste0(pathdata, "/01 legal_texts_with_labels_grouped.csv")) # labeled corpus 
defs <- read.csv(paste0(pathdata, "/02 oecd_definitions_stopwords_grouped.csv")) # oecd defs

embed_glove <- read.csv(paste0(pathdata, "/03 word_embed_glove.csv")) # reduced glove embeddings
embed_legal <- read.csv(paste0(pathdata, "/03 word_embed_legal.csv")) # reduced legal embeddings


# III. Chapter 4: ---------------------------------------------------

## Summary stats, labeled and unlabeled data ----
text <- text %>% 
  mutate(text_clean_wc = str_count(text_clean,"\\w+"))

summary(text$text_clean_wc)
sd(text$text_clean_wc)

text_labeled <- text_labeled %>% 
  mutate(text_clean_wc = str_count(text_clean,"\\w+"))

summary(text_labeled$text_clean_wc)
sd(text_labeled$text_clean_wc)

## Observations by category ----
text_labeled %>% group_by(Category_New) %>% 
  dplyr::summarise(count = n())

## Observations by category ----
text_labeled %>% distinct(Law) %>% nrow()


# IV. Chapter 5: Research Design and Methodology -------------------------------------

## Term frequencies ----
  # get dfm 
dfmat <- combined %>% select(Text) %>% unlist() %>% 
  tokens(remove_punc = TRUE,
         remove_symbols = TRUE) %>% 
  tokens_remove(pattern=stopwords("en")) %>% 
  tokens_replace(pattern = lexicon::hash_lemmas$token, replacement = lexicon::hash_lemmas$lemma) %>%
  dfm()
  
  # get top terms in dfm 
dfmat_count <- dfmat %>% textstat_frequency() %>% 
  filter(str_length(feature) > 1) %>% 
  filter(!(feature %in% c('shall', 'may', 'can', 'article'))) %>% 
  filter(str_detect(feature, "^[^0-9]*$")) %>% 
  top_n(n = 10, wt = frequency) %>% 
  mutate(type = 'count')

  # get tfidf
dfm_tfidf <- dfm_tfidf(dfmat)

  # get top terms in tf-idf 
dfmat_tfidf <- dfm_tfidf %>% textstat_frequency(force = TRUE) %>% 
  filter(!(feature %in% c('shall', 'may', 'can', 'article', 'paragraph'))) %>% 
  filter(str_detect(feature, "^[^0-9]*$")) %>% 
  top_n(n = 10, wt = frequency) %>% 
  mutate(type = 'tf-idf')

dfmat_freq <- rbind(dfmat_count, dfmat_tfidf)

  # plot
plot05.01_count <- ggplot(dfmat_count, aes(x=fct_reorder(feature, frequency), y=frequency)) +
  geom_point(fill="black", size=3, color = "#3F5AAB")  +
  geom_segment(aes(y = 0, 
                   x = feature, 
                   yend = frequency, 
                   xend = feature),
               size = 1,
               color = "#3F5AAB") +
  charts.theme + 
  xlab("") +
  ylab("") + 
  #scale_y_continuous(labels = label_percent(accuracy = 1L)) + 
  labs(subtitle = "Document feature matrix") +
  coord_flip()
plot05.01_count

plot05.01_tfidf <- ggplot(dfmat_tfidf, aes(x=fct_reorder(feature, frequency), y=frequency)) +
  geom_point(fill="black", size=3, color = "#991E56")  +
  geom_segment(aes(y = 0, 
                   x = feature, 
                   yend = frequency, 
                   xend = feature),
               size = 1,
               color = "#991E56") +
  charts.theme + 
  xlab("") +
  ylab("") + 
  scale_y_continuous(limits = c(0,5000)) + 
  labs(subtitle = "Term frequency-inverse document frequency") +
  coord_flip()
plot05.01_tfidf
  
plot05.01 <- ggarrange(plot05.01_count, plot05.01_tfidf)
plot05.01

ggsave(filename="plot04-01.png", plot=plot05.01, device="png", 
       path=pathcharts, width = 10, height = 4)

## Word embeddings ----

word_embeds <- cbind(embed_glove %>% rename(c(x = "x_glove", y = "y_glove")), 
                     embed_legal %>% 
                       select(x, y) %>% 
                       rename(c(x = "x_legal", y = "y_legal"))) %>%
                mutate(Category_New = fct_relevel(Category_New, "None", after=Inf)) %>% 
                mutate(alpha = ifelse(Category_New == "None", "yes", "no"))

plot05.02_glove <- ggplot(word_embeds, aes(x=x_glove, y=y_glove)) +
  geom_jitter(aes(fill = Category_New, alpha = alpha), size = 5, shape = 21, color = "white")  +
  xlab("") +
  ylab("") + 
  labs(subtitle = "GloVe embeddings") + 
  scale_alpha_manual(values = c("yes" = 0.3, "no" = 0.8), guide="none") + 
  scale_fill_manual(values = c("#991E56", "#307351", "#FCB13B", "#1046b1", "#A2C4D2")) + 
  scale_x_continuous(limits = c(-10, 20)) + 
  scale_y_continuous(limits = c(-10, 20)) + 
  charts.theme
plot05.02_glove

plot05.02_legal <- ggplot(word_embeds, aes(x=x_legal, y=y_legal)) +
  geom_jitter(aes(fill = Category_New, alpha = alpha), size = 5, shape = 21, color = "white")  +
  xlab("") +
  ylab("") + 
  labs(subtitle = "Legalw2v embeddings") + 
  scale_alpha_manual(values = c("yes" = 0.3, "no" = 0.8), guide="none") + 
  scale_fill_manual(values = c("#991E56", "#307351", "#FCB13B", "#1046b1", "#A2C4D2")) + 
  scale_x_continuous(limits = c(-10, 20)) + 
  scale_y_continuous(limits = c(-10, 20)) + 
  charts.theme
plot05.02_legal
  
plot05.02 <- ggarrange(plot05.02_glove, plot05.02_legal,
                       common.legend = TRUE, legend = "bottom")
plot05.02

ggsave(filename="plot04-02.png", plot=plot05.02, device="png", 
       path=pathcharts, width = 10, height = 6)
