# Building a Real-time Sentiment Pipeline for Live Tweets using Python, R, & Azure

## Requirements
* Twitter Account + Twitter App setup (https://apps.twitter.com/)
* Anaconda 3.5 or Python 3.5 Installed
* Azure subscription or free trial account
	* [30 day free trial](https://azure.microsoft.com/en-us/pricing/free-trial/)
	* Azure Machine Learning Studio workspace
* Text Editor, I'll be using Sublime Text 3
* Github.com account (to receive code)
* PowerBI.com account (for Dashboard portion)
* .NET up to date + windows (for testing portion)

## Cloning the Repo for Code & Materials
```
git clone https://www.github.com/datasciencedojo/meetup.git
```
Folder: Building a Real-time Sentiment Pipeline for Live Tweets using Python, R, & Azure

## The Predictive Model

### Supervised Twitter Dataset
* Azure ML Reader Module:
	* Data source: Azure Blob Storage
	* Authentication type: PublicOrSAS
	* URI: http://azuremlsampleexperiments.blob.core.windows.net/datasets/Sentiment140.tenPercent.sample.tweets.tsv
	* File format: TSV
	* URI has header row: Checked
* Import and save dataset

### Preprocessing & Cleaning
* Azure ML Metadata Editor: Cast categorical sentiment_label
* Azure ML Group Categorical Values: Casting '0' as Negative, '4' as positive

### Text Processing
* Filtering using R
	* Removing stop words (Stop words list)
	* Removing special characters
	* Replace numbers
	* Globally conform to lower case
	* Stemming and lemmatization
	[Example of Cleansing Stop Words](http://demos.datasciencedojo.com/demo/stopwords/)
* Create a term frequency matrix for English words
	* Azure ML's [Feature Hashing Module](https://msdn.microsoft.com/library/azure/c9a82660-2d9c-411d-8122-4d9e0b3ce92a)
* Drop the tweet_text column, since it is no longer needed
	* Azure ML's Project Columns module
* Feature Selection & Filtering
	* Pick only the most X relevant columns/words to train on. 
	* Using Azure ML's [Filter based Selection](https://msdn.microsoft.com/library/azure/818b356b-045c-412b-aa12-94a1d2dad90f) module, set to Pearson's correlation to select the top 5000 most correlated columns
* Normalize the Term Frequency Matrix
	* Text processing best practice, but does not matter too much for Tweets
	* Normalize Data Module: Min/Max for all numeric columns

### Algorithm Selection
* [Algorithm Cheat Sheet](https://azure.microsoft.com/en-us/documentation/articles/machine-learning-algorithm-cheat-sheet/)
* [Beginer's Guide to Choosing Algorithms](https://azure.microsoft.com/en-us/documentation/articles/machine-learning-algorithm-choice/)
* [Azure ML's Support Vector Machines](https://msdn.microsoft.com/en-us/library/azure/dn905835.aspx)
* [Support Vector Machines in General](https://en.wikipedia.org/wiki/Support_vector_machine)

### Model Building
* Train the model
* Score the trained model against a validation set
* Evaluate the performance, maximaxing accuracy in this case

### Twitter App
* [Creating a Twitter Account] (https://www.hashtags.org/platforms/twitter/how-to-create-a-twitter-account/)
* [Creating a Twitter App](http://www.ning.com/help/?p=4955)
* Get your [Twitter app's](https://apps.twitter.com/) OAuth keys and tokens.

### Twitter API with Python
* [Twitter API for all languages](https://dev.twitter.com/overview/api/twitter-libraries)
* [Tweepy Python Package](https://github.com/tweepy/tweepy)
* [Streaming with Tweepy](http://tweepy.readthedocs.org/en/v3.2.0/streaming_how_to.html?highlight=stream)

### Azure Event Hub
* Create an Service Bus Namespace
* Create an Azure Event Hub
	* Create a send key (to push data to)
	* Create a manage key (stream processor)
	* Create a listen key (to subscribe to)
* [Pushing to Azure Event Hub](http://azure-sdk-for-python.readthedocs.org/en/latest/servicebus.html)
* [Viewing inside of an Azure Event Hub](https://azure.microsoft.com/en-us/documentation/articles/event-hubs-csharp-ephcs-getstarted/)

Deploy the Model
Hook up Stream Processors