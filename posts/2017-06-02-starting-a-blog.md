---
layout: post
title:  "Starting a Blog"
date:   2017-06-02 18:50:45 -0700
categories: jekyll 
---
I wanted to write about SmartOS and just put it up somewhere but I really didn't want to waste a lot of time tinkering with site design or sign up for yet another service and do everything in the browser. But then, one thing led to another... and I ended up spending 2 days figuring out what workflow would be the least painful.

I started with [Jekyll](https://jekyllrb.com/). Github already supported it with Github Pages, it seemed like most other static site generators were based off of it so it was a natural first choice. Actually, I had tried Jekyll years earlier but for one reason or another, I didn't have much success. Maybe because I didn't know Ruby or how rvm worked. Or maybe it was the idea of a generator dropping random files around for me. Don't get me wrong, I love automation... but only when I know exactly what's going where and why.

So I went exploring. I think the first hit on google, led me to [ruhoh](https://github.com/ruhoh/ruhoh.rb) it seemed like it had a little more documentation and although the project looked abandoned (with the most recent commit being 3 years old), I decided to give it a shot anyway. By this time, I had a slightly better understanding of rvm and the role that Gemfile played so it didn't take too much effort to get ruhoh up and running. What I liked about it was that I could swap in and out different themes and that was completely separate from the data of my blog. ruhoh had these commands that can automagically create stub posts although they didn't seem to work exactly as advertised as it kept thinking that I was trying to create a new blog each time. I realized that I was using an older version of ruhoh since I had just copy-pasted their instructions from the website, so I fixed up the Gemfile and upgraded myself from 2.1 to 2.6. Didn't make a difference though, still didn't work. Also not working was the github plugin which apparently does some acrobatics to get things showing up in Github Pages which was my ultimate goal. Sometime later, I realized that other users had forked the plugin to make it compatible with 2.6 (unfortunately, also not mentioned in the main site). The new plugin didn't work either and though after some work, I could make my site compile and upload it manually to my repo to show up on Github Pages, I decided to give another option a chance.

There was wordpress.org but that was overkill. I really wanted to just type in vi and just get my ideas across. OK, getting images in would take a little more work but nothing that couldn't be solved with some scripting. Same thing with medium.com. I must've created and destroyed my account about 3 or 4 times. All I wanted was a white empty page to type in, hit publish and let that be the end of it but instead there were all these social aspects that they tried to get me customize my profile with. When I'm bitten by the writing bug, I'm not in the mindset to read something that might spark my interest. I'm already interested. Just let me write.

Finally we came upon [nanoc](https://nanoc.ws). This time, I was smarter and made sure, right from the start, that it was actively being developed and used. Looked promising. Even companies used it. Installing it was a cinch but it seemed to lack that familiar step where a local httpd server could be started up and "watch" for changes and display them in real time in your browser. No matter. `brew install nginx` would take care of it. But I wasn't too familiar with getting services restarted in MacOS. Rather than googling, I chose to use more familiar tools instead. After getting docker installed, I created a small Dockerfile that could serve the output of the generated site. Got it to work but it was just way too much hassle. I still hadn't written a single word for the actual blog.

In the end, I ditched nanoc and came back to Jekyll. After experiencing all the automation, I came to appreciate the wisdom of a program doing one small thing and doing it right. No bells, no whistles and all the guts exposed. I guess, that's what I was really looking for after all. There aren't pages and pages of documentation for Jekyll not because it is lacking but because there just isn't whole lot to document. Sure the other solutions had "features" to auto generate filenames when you create a post and auto-add "front matter" but these are things I can easily script myself too and I'd have an easier time adapting it to my own workflow.

Because Jekyll doesn't do everything for you, once you cross the rvm hurdle to get things installed, there isn't much left to get in your way. It lets you do what you intended all along. Writing. Well at least that's how this got started.