# Jirassic - Jira Time Tracker for employees

Jirassic is a Mac app that runs in background and tracks automatically the work you do at your workplace. At the end of the day creates a worklog which you can save to Jira Tempo. Its purpose is to replace primitive tracking methods or relying on memory and do everything automatically.

# Features
- Track automatically the time you’ve spent on tasks based on git commits
- Track lunch break
- Track daily scrum meetings
- Track code reviews
- Track time on social media
- Save worklogs to Jira Tempo

![Screenshot](https://image.ibb.co/eAniz7/tasks.png)
![Screenshot](https://image.ibb.co/bBhoXS/settings.png)

# How it works
- When you open your computer in the morning, Jirassic will ask you to start the day
- Tasks are logged automatically or manually when you finish them, not when you start. The premise is that you're always doing something from start to finish, which you do, isn't?
- At the end of the day/week/month you can save the worklogs to Jira Tempo or go to reports tab and see them in more detail.

# Shell support
- jit-CLI Is a wrapper over git which easies the work with jira and branches. Commits made with jit will log tasks to Jirassic Read more at https://github.com/ralcr/Jit
- jirassic-CLI Use Jirassic from the command line, you can manipulate the Jirassic database directly from the command line and the app does not have to be open.

### Install jirassic CLI
You can install it by running this commands in Terminal:

    sudo curl -o /usr/local/bin/jirassic https://raw.githubusercontent.com/ralcr/Jirassic/master/build/jirassic
    sudo chmod +x /usr/local/bin/jirassic

(Note that this precompiled version works with the AppStore app, it won't see the database of the 'Jirassic macOS' target)
![Screenshot](https://s1.postimg.org/tq0jtk65b/Screen_Shot_2017-04-01_at_17.45.21.png)

# Compile
Xcode9 and swift4 is needed. Use the target 'Jirassic macOS' because it is configured to run without signing, that means backup to iCloud will not be available. If you need iCloud you can use the Jirassic AppStore target after you create your own iCloud container and provisioning.

# Licence & contribution
Jirassic is free in the Appstore but with some IAP for some features, for this reason you are not allowed to resell or distribute this software. If you wish to contribute with code note that you will not be paid, we still hope you contribute with creating issues to make it a better software.
