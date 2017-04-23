# Jirassic for programmers

Using the browser to track your work is not for the age of artificial intelligence, you have to keep a tab open along the other 100, you have to remember how much time you’ve spent on tasks, you have to deal with the heavy Jira UI. Jirassic purpose is to replace this primitive workflow.

Jirassic is a Mac app that stays in the status bar and listens for clues that something happened, you either finished a task, a meeting, the lunch...

# Features
- Track automatically the time you’ve spent on tasks based on git commits made through the jirassic shell support
- Track automatically lunch break
- Track daily scrum meetings
- Round times in order to report nice numbers

![Screenshot](https://s15.postimg.org/x0s6u8usr/Screen_Shot_2017-04-01_at_17.59.57.png)
![Screenshot](https://s22.postimg.org/yvdycqg5t/Screen_Shot_2017-04-01_at_18.00.43.png)

# How it works
- When you come in the office in the morning Jirassic will ask you to start the day
- Tasks are logged when you finish them, not when you start. The premise is that you're always doing something that can be logged, but some of the tasks can be logged without counting the time (food, nap)
- Tasks can be logged in multiple ways: manually by clicking + on an existing item in the list; automatically when commiting to git with Jit cli; time spent away from the computer is tracked automatically when you come back; from command line with jirassic cli
- At the end of the day/week/month you can go to reports tab and copy paste the logs to jira timesheets

# Shell support
- jit-cmd Use 'jit commit' to commit to git then automatically log the commit message to Jirassic. But it comes with much more useful commands https://github.com/ralcr/Jit
- jirassic-cmd Use Jirassic from the command line, you can manipulate the Jirassic database directly from the command line, the app does not have to be open
![Screenshot](https://s1.postimg.org/tq0jtk65b/Screen_Shot_2017-04-01_at_17.45.21.png)

# Compile
Xcode8 and swift3 is needed
