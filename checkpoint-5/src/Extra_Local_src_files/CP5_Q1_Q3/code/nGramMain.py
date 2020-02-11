import pickle
from nltk.tokenize import word_tokenize
import nltk

if __name__ == '__main__':
    # Load the models
    model_names = [
        'nudity_penetration', 'sexual_harassment_remarks',
       'sexual_humiliation_extortion_or_sex_work', 'tasers', 'trespass',
       'racial_slurs', 'planting_drugs_guns', 'neglect_of_duty',
       'refuse_medical_assistance', 'irrational_aggressive_unstable',
       'searching_arresting_minors']

    models_b2015 = []
    models_a2015 = []

    for name in model_names:
        with open('../models/{}_B2015.pickle'.format(name), 'rb') as handle:
            cur_model = pickle.load(handle)

        models_b2015.append(cur_model)

        with open('../models/{}_A2015.pickle'.format(name), 'rb') as handle:
            cur_model = pickle.load(handle)

        models_a2015.append(cur_model)

    #
    # while True:
    #     print("Select years: ")
    #     print("1. Before 2015")
    #     print("2. From 2015")
    #     year = int(input())
    #     print("Select model: ")
    #     for index, name in enumerate(model_names):
    #         print('{}. {}'.format(index, name))
    #
    #     model_num = int(input())
    #     if year == 1:
    #         prob_dist = models_b2015[model_num]
    #     else:
    #         prob_dist = models_a2015[model_num]
    #
    #     # query = input("Enter query: ")
    #     # words = word_tokenize(query)
    #     print(prob_dist)
    #     # for w in words:
    #     #
    #     #     if w.lower() in prob_dist:
    #     #         print("Related words: (Similar context)")
    #     #
    #     #         # Sort dictionary first, to get related context in proper order
    #     #         context_w = sorted(prob_dist[w.lower()], key=prob_dist[w.lower()].get, reverse=True)
    #     #         print("Context length", len(context_w))
    #     #         related_nouns = [word for (word, pos) in nltk.pos_tag(context_w) if pos[:2] == 'NN']
    #     #
    #     #         # for n in context_w:
    #     #         #     print(nltk.pos_tag(context_w))
    #     #
    #     #         print("\n\nRelated noun", len(related_nouns))
    #     #
    #     #         counter = 0
    #     #         # print(related_nouns)
    #     #         for c in related_nouns:
    #     #             print(c, end=' , ')
    #     #             counter += 1
    #     #             if counter % 20 == 0:
    #     #                 print("")
    #     #
    #     #         print("\n\n------------------------------------------------------------------\n\n")
    #     #
    #     #         counter = 0
    #     #         for c in context_w:
    #     #             print(c, end=' , ')
    #     #             counter += 1
    #     #             if counter % 20 == 0:
    #     #                 print("")
    #     #
    #     # else:
    #     #     print("Word not found")


    for index, dist in enumerate(models_a2015):
        print("------------------------------------------------")
        print("Dict Name: ", model_names[index])
        print(dist)