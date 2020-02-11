import psycopg2
import pandas as pd
# Read the data from jdbc server
from aws import host as ahost, port as aport, user as auser, password as apassword, database as adatabase


class LoadDataSet:

    def __init__(self, ahost, aport, auser, apassword, adatabase):
        self.connection = psycopg2.connect(host=ahost,
                                      port=aport,
                                      user=auser,
                                      password=apassword,
                                      dbname=adatabase)

        self.cursor = self.connection.cursor()

    def read_try(self, sql):
        try:
            df = pd.read_sql(sql, con=self.connection)
            return pd.DataFrame() if df.empty else df
        except Exception as e:
            print("READ ERROR", e)
            return pd.DataFrame()

    # get all the users from the users table
    def read_document_tags_table_from_db(self):
        sql = 'SELECT * FROM document_tags'
        return self.read_try(sql)

    def run_query(self, query):
        return self.read_try(query)


if __name__ == '__main__':

    # Example usage
    ld = LoadDataSet(ahost, aport, auser, apassword, adatabase)
    # df = ld.read_document_tags_table_from_db()
    # print(df.head())
    df = ld.run_query('select * from data_officer')
    print(df.head())