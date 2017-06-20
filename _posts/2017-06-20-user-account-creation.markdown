---
layout: post
title:  "user account creation"
date:   2017-06-20 14:52:45 -0700
categories: strongdm
---

Managing user accounts is not very glamorous. Sure, whatever fleeting semblance of power from being able to create or delete accounts is quickly tarnished by the sheer mind numbingly repetitiveness of the task. Thankfully, devops has an answer for this and that's to automate. From onboarding a new employee to disabling the accounts of a terminated employee, this task of creating accounts and disabling accounts must be done in an auditable, consistent fashion. However, with the myriad of services, not all of which have an api to call to manage users, what can we really do?

Here's my first attempt, done a few years ago, while I was working at a previous company. (really automating myself out of a job)

[employee_termination](https://github.com/borgified/employee_termination)

I remember writing this for the poor helpdesk support guy that sat in the next cube over. I was a linux sysadmin back then and was relegated to all things datacenter so managing user accounts (since we were using Active Directory) ended up being handled by helpdesk. I wanted to help out but I hated clicking. That's when I decided to help out via automation. The script you see above ended up saving many hours every day from the poor guy. I was proud that I was able to help out but I'm prouder still that the automation itself ended up inspiring the helpdesk guy to pick up scripting himself to extend its functionality.

Cut to the next gig. 

Here we are again creating user accounts. Unfortunately, the code I'd written for account termination previously doesn't immediately address the current needs so we had to start from scratch... the services we use are just way too different. This time it was a combination of hand crafted useradds on linux and everyone sharing a handful of "service" mysql accounts. While the existing system worked, trying to figure out who was running what was next to impossible. There was no concept of tiered access either which made it hard to limit access without affecting others. I was dreading the idea of writing all that custom logic.

One of our clients shared a positive experience solving this problem with a commercial product: StrongDM. It’s like single sign-on for databases.  

Initially users were pretty skeptical. Some users struggled to be fully converted because they've been taught to setup their MySQL Workbench a certain way (ie. with ssh proxy, etc.) and it was hard to break out of that habit. Others embraced it quickly, recognizing the simplicity of being able to connect to localhost:3306 and have instant access to production data. All in all, almost a year into using StrongDM, I would say it was a huge win not just for the users but for us as well. Creating accounts and assigning permissions is now just a drag and drop... and along with the simple install, it gave us the confidence to outsource the entire process to helpdesk instead. The entire task of onboarding and offboarding is off my plate.

Built-in, StrongDM also has an auditable history of the commands run by each user and although what they can do is limited by the mysql user defined in the datasource connection, you get to see exactly what's being run and be able to pinpoint any odd queries without having to go into the database and run show process list.

In comparing my own implementation of user account management vs a commercially available one like StrongDM, I learned an important lesson:

If you’re going to script this yourself, don’t underestimate the importance of ease of use. This makes or breaks the project. If the users don't get a vast improvement in user experience, it's really hard to move them off of something that "already works". In my case, I wrapped my scripts around a simple web cgi-bin interface (works everywhere) that lets the user terminate accounts in multiple services with a single click and since the original manual process was so painful and time consuming, I was pretty certain that my scripts would be used.  

If you need functionality beyond useradds, like fine grained permission or audit logs, check out strongDM.
