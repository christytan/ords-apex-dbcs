#######################################################################
#                            IMPORT SECTION                           #
#######################################################################
import json
import cx_Oracle as con
import unicodedata
import datetime
import time
from time import mktime
from datetime import datetime
import sys

#######################################################################
#                            MODULE SECTION                           #
#######################################################################

def parseAndLoadJSON(file_name,ip,port,service,user_name,password):
  data = []
  with open(file_name) as f:
      for line in f:
          data.append(json.loads(line))

  #Creating a connection
  dsn = con.makedsn(ip, port, service_name=service)
  cur = con.connect(user_name,password,dsn)

  cursors = cur.cursor()

  for i in data:
    try:

      # Get all the tweet data
      tweet = i["text"]
      tweet = unicodedata.normalize('NFKD', tweet).encode('ascii','ignore')

      #Get the screen name of the tweeter
      username = i["user"]["screen_name"]
      username = unicodedata.normalize('NFKD', username).encode('ascii','ignore')

      #Get tweet_time
      tweet_time = i["created_at"]
      tweet_time = unicodedata.normalize('NFKD', tweet_time).encode('ascii','ignore')
      tweet_time = time.strptime(tweet_time,"%a %b %d %H:%M:%S +0000 %Y")
      tweet_time = datetime.fromtimestamp(mktime(tweet_time))

      #Get Weekday
      tweet_weekday = tweet_time.strftime('%A')

      #Get re-tweets
      retweeted = i['retweeted']
      source = i['source']
      if source!=None:
          source = source.encode('utf-8')
      retweet_count = i['retweet_count']

      #Get Place
      place = i['place']
      if place!=None:
          place = i['place']['full_name']
          if place!=None:
              place = place.encode('utf-8')
          else:
              place = i['place']
      else:
          place = 'None'

      # Get location
      location  = i['user']['location']
      if location!=None:
          location = location.encode('utf-8')
      else:
          location = 'None'

      #Insert the data into the table
      cursors.execute('INSERT INTO TWEETSDATA (TIME, USERNAME, TWEET, TWEET_TIME, RETWEETED, SOURCE, RETWEET_COUNT, \
      PLACE, TWEET_WEEKDAY, LOCATION) VALUES (SYSTIMESTAMP,:2,:3,:4,:5,:6,:7,:8,:9,:10)',{"2":str(username), \
      "3":str(tweet),"4":tweet_time,"5":retweeted,"6":str(source),"7":int(retweet_count),"8":str(place), \
      "9":tweet_weekday,"10":str(location)})

  except BaseException as de:
    print "Error while inserting data into the table: %s" % str(de)

  cur.commit()
  cursors.close()
  cur.close()
  print("Tweets loaded into the database successfully!!!")

def createTable(ip,port,service,user_name,password):
    #Creating a connection
    dsn = con.makedsn(ip, port, service_name=service)
    cur = con.connect(user_name,password,dsn,mode=con.SYSDBA)
    flag1 = ""
    flag2 = ""
    cursors = cur.cursor()

    #Printing the DB version
    print "Database Version : ",cur.version

    #Creating a user for storing tweets in the database
    try:
        cursors.execute('CREATE USER APPSCHEMA IDENTIFIED BY WE#lCome12_34')
        flag2 = "User APPSCHEMA Created"
    except BaseException as de:
        print "User APPSCHEMA already created"
        flag1 = flag1+"User APPSCHEMA already exists"

    #Creating a table for storing tweets in the database
    try:
        cursors.execute('CREATE TABLE APPSCHEMA.TWEETSDATA (tweet_id NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1) PRIMARY KEY, time TIMESTAMP, username VARCHAR2(100), tweet VARCHAR2(300), tweet_time TIMESTAMP, retweeted VARCHAR2(20), source VARCHAR2(1000), retweet_count NUMBER(38), place VARCHAR2(500), tweet_weekday VARCHAR2(15), location VARCHAR2(1000))')
        flag2 = "Table TWEETSDATA Created"
    except BaseException as de:
        print "Table TWEETSData already created"
        flag2 = flag2+"Table TWEETSDATA already exists"
    cur.commit()
    #Closing the connection
    cursors.close()
    cur.close()

    return flag1,flag2


def parseParamFile(file_name):
  config_fp = open(file_name,'r')

  config_par = config_fp.readlines()

  config_params = dict()
  for i in config_par:
      key_value = i.strip('\n').split("=")
      config_params[key_value[0]]=key_value[1]

  jsonfile = config_params['jsonfile']
  ip = config_params['ip']
  port = config_params['port']
  service = config_params['service']
  password = config_params['sys_password']

  return jsonfile,ip,port,service,password

#######################################################################
#                            MAIN SECTION                             #
#######################################################################

if __name__ == "__main__":
  param_file = sys.argv[1]
  jsonfile,ip,port,service,password = parseParamFile(param_file)
  createTable(ip,port,service,'sys',password)
  parseAndLoadJSON(jsonfile,ip,port,service,'APPSCHEMA',password)


                                                                                                                                                18,0-1        Top
