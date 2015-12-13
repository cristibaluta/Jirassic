# JIRAssic

![Screenshot](http://s23.postimg.org/69zhb4f17/jirassic.jpg)

Using the browsers to track your work is just horrible, you have to keep open and switch tabs, you have to remember how much time you’ve spent on issues, you have to deal with the ugly Jira UI... Unless you have horse memory and remember what you’ve worked the whole day, this tool will take away all the frustration.
JIRAssic is a Mac app that stays in the status bar and you can access it any time and take notes as you finish tasks. Time is calculated automatically.

# Features:
- track automatically the time you’ve spent on issues
- track lunch break
- track scrum meetings
- track Git commits as tasks when you do the commits with jit https://github.com/ralcr/Jit
- view finished tasks on iPhone in the scrum meetings

# Compile
Before compiling for the first time you need to setup the Parse database and credentials.
- Create a project at http://parse.com
- Get the keys from Parse and create a new file at External/Parse/ParseCredentials.swift and add this lines and fill them:

	let parseApplicationId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	let parseClientId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
