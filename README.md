# Jirassic is for agile developers

Using the browser or paper and pen to track your work is not for the age of artificial intelligence, you have to keep a tab open along the other 100, you have to remember how much time you’ve spent on tasks, you have to deal with the heavy Jira UI. Jirassic purpose is to replace this primitive workflow and track everything automatically.

Jirassic is a Mac app that stays in the status bar and listens for clues that something happened, you either finished a task, a meeting, the lunch...

# Features
- Track automatically the time you’ve spent on tasks based on git commits made through the jirassic shell support
- Track lunch break
- Track daily scrum meetings
- Track code reviews
- Track wasted time (your boss will love this)

![Screenshot](https://s3.postimg.org/txo1juatf/Tasks.png)
![Screenshot](https://s16.postimg.org/u10ss7i85/Sengs.png)

# How it works
- When you come in the office in the morning Jirassic will ask you to start the day
- Tasks are logged when you finish them, not when you start. The premise is that you're always doing something productive, but don't worry you can log wasted time too, just that it will not add to the total worked time
- Tasks can be logged in multiple ways: manually by clicking + on an existing item in the list; automatically when commiting to git with Jit cli; for the time spent away from the computer you'll be asked what did you do; from command line with jirassic cli
- At the end of the day/week/month you can go to reports tab and copy paste the logs to jira timesheets (we are working in doing this step automatic)

# Shell support
- jit-cmd Use 'jit commit' to commit to git then automatically log the commit message to Jirassic. But it comes with much more useful commands https://github.com/ralcr/Jit
- jirassic-cmd Use Jirassic from the command line, you can manipulate the Jirassic database directly from the command line, the app does not have to be open
![Screenshot](https://s1.postimg.org/tq0jtk65b/Screen_Shot_2017-04-01_at_17.45.21.png)

# Compile
Xcode8 and swift3 is needed. Use the target 'Jirassic no cloud' because it is configured to run without signing, but that means backup to iCloud will not be available. If you need iCloud you can use the Jirassic target after you create your own iCloud container and provisioning. The downside is you can't commit to the project with that target modified and pulling changes might have conflicts.

## Installing cmd

jirassic cmd is compiled for AppStore Jirassic and it won't see the database of the non AppStore app. You can install it by running this commands in Terminal to download the executable and to give it permissions

    sudo curl -o /usr/local/bin/jirassic https://raw.githubusercontent.com/ralcr/Jirassic/master/build/jirassic
    sudo chmod +x /usr/local/bin/jirassic

Verify installation in Jirassic/settings/extensions or type into terminal

    jirassic


# Licence & contribution
Jirassic is a paid software in the Appstore, for this reason you are not allowed to resell or distribute this software. It is not recommended to take it from unknown sources either, you don't know what malicious changes someone did to it. If you wish to contribute with code note that you will not be paid, we still hope you contribute with creating issues to make it a better software.
