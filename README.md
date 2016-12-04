# JIRAssic for programmers

![Screenshot](https://s9.postimg.org/ma7lec3in/jirassic4sept.jpg)

Using the browsers to track your work is not human, you have to keep Jira open and switch tabs, you have to remember how much time you’ve spent on tasks, you have to deal with the horrible Jira UI... JIRAssic purpose is to take away all this frustration.
JIRAssic is a Mac app that stays in the status bar and you can access it any time and take notes as you finish tasks. Commiting to Git with our CLI tool called Jit, will log time to JIRAssic as well. Time is calculated and rounded automatically to 8hrs, you just need to insert them in Jira at the end of the day/week/month or whenever you wish.

# Who is this for
- You are forced to use Jira timesheets at work
- You use git from command line, or want to
- You are a perfectionist

# Features
- Track automatically the time you’ve spent on tasks based on git commits
- Track automatically lunch break
- Track daily scrum meetings
- Round times to quarters and the whole day to fit 8 hrs

# Dependencies
- Jit cmd https://github.com/ralcr/Jit Replacement for some git commands but you need only one command
- jirassic-cmd Use Jirassic from the command line, you can manipulate the Jirassic database directly from the command line

They both come bundled in the Jirassic app but needs to be installed manually from settings.

# Compile
Xcode8 and swift3 is needed
JIRAssic is free for developers who can compile it themselves, please do not distribute it all over.

# Prepared for the future
- Use cloudkit to save the data to server
- Launch iOS app with readonly functionality, for remembering in the scrum meeting what you've done yesterday
