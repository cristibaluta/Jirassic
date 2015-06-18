# JIRAssic

![Screenshot](http://ralcr.com/jira-logger/osx.jpg)
![Screenshot](http://ralcr.com/jira-logger/ios.jpg)

Using the browsers to track your work is just horrible, you have to switch tabs, you have to remember how much time you’ve spent on issues... Unless you have horse memory and remember what you’ve worked the whole day, this tool is gold.
JIRAssic is a Mac app that stays in the status bar and you can access it any time and take notes as you finish tasks. Time tracking is done automatically.

# Features:
- track automatically the time you’ve spent on issues
- track lunch break
- track scrum meetings
- view finished tasks on iPhone in the scrum meetings

# Compile
As it is the app won't compile, the app uses Parse as a datastore and the credentials are hidden. 
- First thing you need to do is to create a project at http://parse.com
- Then get the keys and create a separate file with whatever name you wish and add this lines and fill them:
let parseApplicationId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
let parseClientId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
