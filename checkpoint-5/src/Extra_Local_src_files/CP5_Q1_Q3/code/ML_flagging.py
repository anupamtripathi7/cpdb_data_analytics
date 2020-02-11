import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder, normalize
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC

# Global initializations
encoder = LabelEncoder()


def clean_data(df):
    current_year = 2019

    # Replace the null values with mode
    col_with_mode = ['gender', 'birth_year', 'rank', 'race', 'appointed_date']
    for col in col_with_mode:
        df[col].fillna(df[col].mode()[0], inplace=True)

    # Get only the year of the appointed date
    df['appointed_date'] = pd.to_datetime(df['appointed_date'])
    df['appointed_date'] = pd.DatetimeIndex(df['appointed_date']).year

    # Categorize the data
    data_to_encode = ['race', 'rank']
    df[data_to_encode] = df[data_to_encode].apply(lambda col: encoder.fit_transform(col))

    # Convert birth year to actual age
    df['birth_year'] = current_year - df['birth_year']

    return df


def create_features(df, awards, normalize_data=True):
    feature_set = ['race', 'rank', 'birth_year', 'appointed_date', 'awards']

    # Generate the awards column
    new_col = []

    for off_id in df['id']:
        if off_id in awards:
            new_col.append(awards[off_id])
        else:
            new_col.append(0)

    df['awards'] = new_col

    data = df[feature_set].values
    if normalize_data:
        data = normalize(data)

    return data


def calculate_accuracy(predicted, true_labels, threshold=0.7):
    '''

    :param predicted: Predicted values are in terms of probabilities
    :param true_labels: Actual labels 0, 1
    :param threshold:  The threshold to use (0.5, 0.6, 0.7)
    :return:
    '''

    predicted = np.where(predicted >= threshold, 1, 0)

    accuracy = ((true_labels == predicted).sum())/true_labels.shape[0]

    return accuracy


if __name__ == '__main__':
    #%%
    # Load the data
    df_bcb2015 = pd.read_csv('../data/badCopsB2015.csv')
    df_bca2015 = pd.read_csv('../data/badCopsA2015.csv')
    df_gcb2015 = pd.read_csv('../data/goodCopsB2015.csv')
    df_gca2015 = pd.read_csv('../data/goodCopsA2015.csv')
    df_awards = pd.read_csv('../data/offAwards.csv')
    # Convert awards to a dictionary
    awards_dict = dict(zip(df_awards['officer_id'], df_awards['count']))

    # Clean the data
    df_bcb2015 = clean_data(df_bcb2015)
    df_bca2015 = clean_data(df_bca2015)
    df_gcb2015 = clean_data(df_gcb2015)
    df_gca2015 = clean_data(df_gca2015)

    #%%
    # Create the features for training and testing
    # Labels Bad Cops = 1, Good Cops = 0
    X1_train = create_features(df_bcb2015, awards_dict)
    Y1_train = np.ones((X1_train.shape[0], 1))
    X2_train = create_features(df_gcb2015, awards_dict)
    Y2_train = np.zeros((X2_train.shape[0], 1))

    # Join the training sets
    print(X1_train.shape, X2_train.shape)
    print(Y1_train.shape, Y2_train.shape)
    X_train = np.vstack((X1_train, X2_train))
    Y_train = np.vstack((Y1_train, Y2_train))
    Y_train = Y_train.ravel()  # Flatten the array from (n, 1) to (n, )
    print(X_train.shape, Y_train.shape)

    # Do the same thing for test set
    X1_test = create_features(df_bca2015, awards_dict)
    Y1_test = np.ones((X1_test.shape[0], 1))
    X2_test = create_features(df_gca2015, awards_dict)
    Y2_test = np.zeros((X2_test.shape[0], 1))

    # Join the testing sets
    print(X1_test.shape, X2_test.shape)
    print(Y1_test.shape, Y2_test.shape)
    X_test = np.vstack((X1_test, X2_test))
    Y_test = np.vstack((Y1_test, Y2_test))
    Y_test = Y_test.ravel()  # Flatten the array from (n, 1) to (n, )
    print(X_test.shape, Y_test.shape)

    #%%
    # Create Logistic Classifier for training and testing
    clf_log = LogisticRegression(random_state=0)
    clf_log.fit(X_train, Y_train)
    probabilities = clf_log.predict_proba(X_train)
    # print(type(probabilities), probabilities)
    # acc_train = calculate_accuracy(probabilities, Y_train, threshold=0.7)
    # print(acc_train)
    acc_train = clf_log.score(X_train, Y_train)
    print("Train accuracy is: ", acc_train)
    acc_test = clf_log.score(X_test, Y_test)
    print("Test accuracy is: ", acc_test)

    #%%
    clf_svm = SVC(gamma='auto')
    clf_svm.fit(X_train, Y_train)
    print("Train accuracy is: ", clf_svm.score(X_train, Y_train))
    print("Test accuracy is: ", clf_svm.score(X_test, Y_test))
