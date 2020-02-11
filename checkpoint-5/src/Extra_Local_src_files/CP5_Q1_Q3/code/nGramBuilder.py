import load_dataset
import pandas as pd
from aws import host as ahost, port as aport, user as auser, password as apassword, database as adatabase
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize, sent_tokenize
import pickle


def load_all_tags():
    ld = load_dataset.LoadDataSet(ahost, aport, auser, apassword, adatabase)
    df = ld.run_query('select * from document_tags_all')
    df.to_csv('../data/document_tags.csv')


def clean_data(df):
    # Get rid of documents where the text is null
    indices_notNull = df.index[pd.notnull(df['document_text'])]
    df = df.loc[indices_notNull]  # Pandas return 1 indexing, so use loc instead of iloc

    # Delete rows with no incident date
    indices_notNull = df.index[pd.notnull(df['incident_date'])]
    df = df.loc[indices_notNull]

    # Delete rows with null entries in categories

    # Divide document into two sections, before 2015 and 2015 onwards
    df['incident_date'] = pd.to_datetime(df['incident_date'])
    df['incident_date'] = pd.DatetimeIndex(df['incident_date']).year
    df_b2015 = df[df['incident_date'] < 2015]
    df_a2015 = df[df['incident_date'] >= 2015]

    return df_b2015, df_a2015


def divide_by_category(df):
    '''
    This function will divide the data into 11 categories by storing their indices
    :param df: The document tags
    :return:
    '''
    columns_of_interest = [
        'nudity_penetration', 'sexual_harassment_remarks',
       'sexual_humiliation_extortion_or_sex_work', 'tasers', 'trespass',
       'racial_slurs', 'planting_drugs_guns', 'neglect_of_duty',
       'refuse_medical_assistance', 'irrational_aggressive_unstable',
       'searching_arresting_minors']


    category_map = {}
    # Initialize the dictionary with column names
    for col in df.columns:
        if col in columns_of_interest:
            indices = df.index[pd.notnull(df[col])]
            indices_true = df.index[df[col] == True]
            print("Number of labelled documents for {} are {}".format(col, len(indices)))
            print("Number of true labels for {} are {}".format(col, len(indices_true)))
            category_map[col] = indices_true

    return category_map


def generate_words(doc_text):
    stop_words = set(stopwords.words('english'))
    tokenized_words = word_tokenize(doc_text)

    key_words = ['narrative', 'alleged', 'allege ', 'allogos']

    words = [word.lower() for word in tokenized_words if word.lower() not in stop_words and word.isalpha()]
    total_words = len(words)
    # Perform a sliding window across words near the key words
    final_words = []
    window_size = 50
    for word in key_words:
        if word in words:
            start_index = words.index(word)+1  # We need the word after the key word, hence +1

            # Add next n words to final_words
            if start_index + window_size < total_words:
                temp = words[start_index: start_index + window_size]
            else:
                temp = words[start_index: ]

            final_words.extend(temp)

    if final_words:
        # Take only the unique words
        final_words = list(set(final_words))
        adjacentWords = zip(final_words[0:], final_words[1:], final_words[2:])

    return final_words



def generate_prob_dict(df):
    '''
    This function will be called again and again for every category
    So we will be generating 11 dictionaries in the end.
    :param df:
    :return:
    '''
    word_dict = {}
    prob_dict = {}
    counter = 0
    for text in df['document_text']:
        if counter % 5 == 0:
            print("Processed ", counter, "records")
        final_words = generate_words(doc_text=text)
        if final_words:
            adjacentWords = zip(final_words[0: ], final_words[1: ])

            for cur, next_word in adjacentWords:
                # print(cur, next_word)
                # The cartesian product results in tuples having same words. So, ignore those.
                if cur != next_word:
                    # Format current_word = {next_word_word: number_of_occurrences}

                    # If the current word(first) doesn't exist in word dist, then create an entry
                    if cur not in word_dict:
                        word_dict[cur] = {next_word: 1}

                    # If the current word exists but not the adjacent, then create an entry for it
                    elif next_word not in word_dict[cur]:
                        word_dict[cur][next_word] = 1

                    # If word and next_word word exists, increase the count
                    else:
                        word_dict[cur][next_word] += 1

        counter += 1

    # Create the probability distribution from the count
    for cur, next_words in word_dict.items():
        prob_dict[cur] = {}
        total_count = sum(next_words.values())
        for w in next_words:
            prob = next_words[w] / total_count
            prob_dict[cur][w] = prob

    print("Length of probability dictionary", len(prob_dict))

    return prob_dict



if __name__ == '__main__':
    # Save the document data in a csv file
    # load_all_tags()
    # Load the saved data
    df_doc = pd.read_csv('../data/document_tags.csv')
    df_b2015, df_a2015 = clean_data(df_doc)
    print("Before 2015")
    cmap_b2015 = divide_by_category(df_b2015)
    # print(cmap_b2015)
    print("After 2015")
    cmap_a2015 = divide_by_category(df_a2015)

    # probd = generate_prob_dict(df_b2015.loc[cmap_b2015['nudity_penetration']])
    # Generate the probability distributions for each class before 2015
    print("--Before 2015--")
    for key in cmap_b2015.keys():
        print("Generating distribution for: ", key)
        prob_dict = generate_prob_dict(df_b2015.loc[cmap_b2015[key]])
        with open('../models/{}_B2015.pickle'.format(key), 'wb') as handle:
            pickle.dump(prob_dict, handle, protocol=pickle.HIGHEST_PROTOCOL)

    print("---After 2015---")
    # Do the same for data after 2015
    for key in cmap_a2015.keys():
        print("Generating distribution for: ", key)
        prob_dict = generate_prob_dict(df_a2015.loc[cmap_a2015[key]])
        with open('../models/{}_A2015.pickle'.format(key), 'wb') as handle:
            pickle.dump(prob_dict, handle, protocol=pickle.HIGHEST_PROTOCOL)



