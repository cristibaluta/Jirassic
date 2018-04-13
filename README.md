# Jirassic - Jira Time Tracker

Jirassic is a Mac app that stays in the status bar and listens for clues that something happened, you either finished a task, a meeting, the lunch... At the end of the day creates a worklog which you can save to Jira Tempo. Its purpose is to replace primitive tracking methods or relying on memory and do everything automatically.

# Features
- Track automatically the time you’ve spent on tasks based on git commits
- Track lunch break
- Track daily scrum meetings
- Track code reviews
- Track wasted time (your boss will love this)
- Save worklogs to Jira Tempo

![Screenshot](https://s3.postimg.org/txo1juatf/Tasks.png)
![Screenshot](https://s16.postimg.org/u10ss7i85/Sengs.png)

# How it works
- When you come in the office in the morning Jirassic will ask you to start the day
- Tasks are logged when you finish them, not when you start. The premise is that you're always doing something, but don't worry you can log wasted time too, just that it will not add to the total worked time
- Tasks can be logged in multiple ways: manually by clicking + on an existing item in the list; automatically when commiting to git; for the time spent away from the computer you'll be asked what did you do and presented with some suggestions; from command line with jirassic cli
- At the end of the day/week/month you can save the worklogs to Jira Tempo or go to reports tab and see them in more detail.

# Shell support
- jit-cmd Use 'jit commit' to commit to git then automatically log the commit message to Jirassic. But it comes with much more useful commands https://github.com/ralcr/Jit
- jirassic-cmd Use Jirassic from the command line, you can manipulate the Jirassic database directly from the command line, the app does not have to be open.

### Install jirassic cmd
You can install it by running this commands in Terminal:

    sudo curl -o /usr/local/bin/jirassic https://raw.githubusercontent.com/ralcr/Jirassic/master/build/jirassic
    sudo chmod +x /usr/local/bin/jirassic

(Note that this precompiled version works with the AppStore app, it won't see the database of the non-AppStore app compiled by yourself)
![Screenshot](https://s1.postimg.org/tq0jtk65b/Screen_Shot_2017-04-01_at_17.45.21.png)

# Compile
Xcode9 and swift4 is needed. Use the target 'Jirassic macOS' because it is configured to run without signing, that means backup to iCloud will not be available. If you need iCloud you can use the Jirassic AppStore target after you create your own iCloud container and provisioning.

# Licence & contribution
Jirassic is free in the Appstore but with some IAP for some features, for this reason you are not allowed to resell or distribute this software. If you wish to contribute with code note that you will not be paid, we still hope you contribute with creating issues to make it a better software.
