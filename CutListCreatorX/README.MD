# CutListCreatorX

## ViewController
The main viewController.

## ViewControllerUpload
The viewController for the upload/save dialog.

## GraphView
Class that defines the graphView to show the cuts in either green (video) and red (advertisements and everything that is cut out).

## TableView
Functions for the tableView Container used to show the cut-times and cut-framenumbers.

## CutListTools
Here, the class "Cutlist" is defined that contains functions to load&parse or save a cutlist.

## SniplistParser
Here, the class Sniplist is defined that can be used to interact with the sniplist website (http://cutlist.at), e.g. for uploading a cutlist.

## VideoTools
Everything related to the actual video file, such as obtaining video informations like frameRate, duration etc. e.g. by using FFProbe.

## FileSystemOperations
Helper functions for file system operations, such as loading a file with a NSOpenPanel

## RegexTools
Helper functions used to parse a cutlist file, such as returning a matching regex-string.



