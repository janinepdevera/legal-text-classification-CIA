## PARSING SOURCE CODES

import pandas as pd
from glob import glob
import re
import pdfplumber
from pdfminer.high_level import extract_text
from langdetect import detect, DetectorFactory
from deep_translator import GoogleTranslator
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import sent_tokenize, word_tokenize
from string import punctuation
from nltk.stem.porter import PorterStemmer
from nltk.stem import WordNetLemmatizer
nltk.download("stopwords")
nltk.download('punkt')
from nltk.corpus import stopwords
lemmatizer = WordNetLemmatizer()
stemmer = PorterStemmer()

# Functions

def text_split(text):
    # find double line breaks
    if text.find("\n\n") != -1:
        split = text.split("\n\n")
    elif text.find("\n \n") != -1:
        split = text.split("\n \n")
    # find section/article divisions
    elif len(re.findall('\\n[A-Z]{2,}', text)) > 0:
        split = re.split('\\n[A-Z]{2,}', text)
    elif len(re.findall('\\nSection', text)) > 0:
        split = re.split('\\nSection', text)
    # find single line breaks
    elif text.find('\n“') != -1:
        split = text.split('\n“')
    elif text.find('\\n') != -1:
        split = text.split('\\n')
    else: 
        split = [text]

    # second split
    if len(split) > 1:
        new_split = []
        for s in split:
            if s.find("\n\n") != -1:
                new_split += s.split("\n\n")
            elif s.find("\n \n") != -1:
                new_split += s.split("\n \n")
            elif len(re.findall('\\n[A-Z]{2,}', s)) > 0:
                new_split += re.split('\\n[A-Z]{2,}', s)
            elif len(re.findall('\\nSection', s)) > 0:
                new_split += re.split('\\nSection', s)
            elif s.find('\n“') != -1:
                new_split += s.split('\n“')
            elif s.find('\\n') != -1:
                new_split += s.split('\\n')
            else:
                new_split.append(s)
        split = new_split
    
    return split


def create_df(list):
    df_text = pd.DataFrame(columns = ['file_name', 'country', 'text', 'lang', 'length'])

    for pdf_file in list:
        # search for pdf file name from path 
        file_name = re.search('[a-zA-Z0-9]*_([a-zA-Z0-9]+)[^\\>.]+', pdf_file)[0]
        country = re.search('^[A-Z]{2}', file_name)[0]
        with pdfplumber.open(pdf_file) as pdf:
            text = []
            # load pdf by page 
            for i in range(len(pdf.pages)):
                page = pdf.pages[i]
                page_text = page.extract_text()
                text.append(page_text)
            text = ' '.join(text)
            lang = detect(text)
            # split by paragraph 
            paragraphs = text_split(text)
            for p in paragraphs:
                paragraph = p
                length = paragraph.count(' ')
                # create dataframe
                row = pd.DataFrame({'file_name': file_name, 'country': country,
                        'text': paragraph, 'lang': lang, 'length': length}, index=[0])
                df_text = pd.concat([row,df_text.loc[:]]).reset_index(drop=True)

        return df_text

def preprocess_corpus(texts):
    eng_stopwords = set(stopwords.words("english"))
    def remove_stops_digits(tokens):
        token_list =  [token.lower() for token in tokens if token not in eng_stopwords and token not in punctuation and token.isdigit() == False]
        processed_text = ' '.join(token_list)
        return processed_text
    return [remove_stops_digits(word_tokenize(text)) for text in texts]

def preprocess_corpus_keep_stop_words(texts):
    def remove_stops_digits(tokens):
        token_list =  [token.lower() for token in tokens if token not in punctuation and token.isdigit() == False]
        processed_text = ' '.join(token_list)
        return processed_text
    return [remove_stops_digits(word_tokenize(text)) for text in texts]

def stem_lemmatize(text):
    stemmed = [stemmer.stem(token) for token in word_tokenize(text)]
    lemmatized = [lemmatizer.lemmatize(token) for token in stemmed]
    processed_text = ' '.join(lemmatized)
    return processed_text