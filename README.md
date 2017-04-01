# Jirassic for programmers

Using the browsers to track your work is not human, you have to keep Jira open and switch tabs, you have to remember how much time you’ve spent on tasks, you have to deal with the heavy Jira UI... Jirassic purpose is to take away all this frustration.

Jirassic is a Mac app that stays in the status bar and you can access it any time and take notes as you finish tasks. Commiting to Git with our CLI tool called Jit, will log time to Jirassic as well.
![Screenshot](https://s15.postimg.org/x0s6u8usr/Screen_Shot_2017-04-01_at_17.59.57.png)
![Screenshot](https://s22.postimg.org/yvdycqg5t/Screen_Shot_2017-04-01_at_18.00.43.png)

# Who is this for
- You are forced to use Jira timesheets at work
- You use git from command line, or want to
- You want more, you don't stand for useless workflows, like noting down manually your time.

# How it works
- When you come to work in the morning Jirassic will ask you to start the day
- Tasks are logged when you finish them, not when you start
- Tasks can be logged in multiple ways: manually by clicking + on an existing item in the list; automatically when commiting to git with Jit cli; time spent away from the computer is tracked automatically when you come back; from command line with jirassic cli
- At the end of the day/week/month you can go to reports tab and copy paste the logs to jira timesheets

# Features
- Track automatically the time you’ve spent on tasks based on git commits
- Track automatically lunch break
- Track daily scrum meetings
- Round times in order to report nice numbers

# Shell support
- jit-cmd Use 'jit commit' to commit to git then automatically log the commit message to Jirassic. But it comes with more useful commands https://github.com/ralcr/Jit
- jirassic-cmd Use Jirassic from the command line, you can manipulate the Jirassic database directly from the command line, the app does not have to be open
![Screenshot](https://s1.postimg.org/tq0jtk65b/Screen_Shot_2017-04-01_at_17.45.21.png)

# Compile
Xcode8 and swift3 is needed

Jirassic is free for developers who can compile it themselves, please do not distribute it all over.
