# JIRAssic for programmers

![Screenshot](https://s9.postimg.org/ma7lec3in/jirassic4sept.jpg)

Using the browsers to track your work is not human, you have to keep Jira open and switch tabs, you have to remember how much time you’ve spent on tasks, you have to deal with the horrible Jira UI... JIRAssic purpose is to take away all this frustration.
JIRAssic is a Mac app that stays in the status bar and you can access it any time and take notes as you finish tasks. Commiting to Git with our CLI tool called Jit, will log time to JIRAssic as well. Time is calculated and rouded automatically, you just need to insert them in Jira at the end of the month or whenever you wish.

# Features:
- round times to quarters and the whole day to fit 8 hrs
- track automatically the time you’ve spent on tasks
- track lunch break
- track daily scrum meetings
- track Git commits as tasks
- view tasks on iPhone (useful in daily scrum meetings that are done away from the computer)

# Dependencies
- Jit cmd https://github.com/ralcr/Jit Replacement for some git commands
- jirassic-cmd Use Jirassic from the command line, it works directly with the Jirassic database
They both come bundled in the Jirassic app but needs to be installed manually from settings.

# Compile
Xcode8 and swift3 is needed
JIRAssic is free for developers who can compile it themselves, please do not distribute it all over.

# Roadmap
- Launch the app in the store
- Use cloudkit to save the data to server
- Fix the iOS app to use the cloudkit for data
- Launch iOS, and macOS again in the store
