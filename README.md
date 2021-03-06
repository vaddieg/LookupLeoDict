# LEO Dictionary lookup macOS service
LookupLeoDict.service is a trivial (and mostly useless) tool that allows you to quickly translate any selected word in German to the preffered language by pressing a shortcut (default is Cmd-\\) using the https://www.leo.org website (which is IMO the best one, but doesn't allow text translation). Reverse translation is also possible. If you select a sentence (3 and more words) the service will route you to the Google translate or deepL page. 

## Installation
1. Download the release binary https://github.com/vaddieg/LookupLeoDict/releases/download/2.0/LookupLeoDict.service.app.zip or build the Xcode project.
1. Copy LookupLeoDict.service to /Applications or ~/Library/Services

## Setup
Launch the LookupLeoDict.service by double-clicking it to show the settings panel. Default translation direction is German<->English.
Also check the macOS system settings -> Keyboard -> Shortcuts -> Services to customize the keyboard shortcut.

## Usage
Default shortcut (Cmd-\\) should work in most macOS application where you can select the text. Alternatively you can use the menu <App>->Services->Lookup at dict.leo.org option. Service will open a new web page in your default web browser. 

dict.leo.org, deepL.com and translate.google.com sites belong to their owners.
