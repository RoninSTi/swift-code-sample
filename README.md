# swift-code-sample
## Swift 3.1 code sample

### Intro
Enclosed in this repository are the classes used to create the main feed in a yet to be released version of the app Airhoot.  Very simply: Airhoot is twitter, but anonymous.  

*  The main feed `AHMainFeedViewController` is constructed from a `UIViewController` containing a `UITableView`.  Airhoot has the ability to display different kinds of data feeds (popular, near me, my posts).  In order to re-use the main feed controller, `AHFeedManager` was implemented to determine which data to display.
*  There are three different types of data that can be displayed: text, photo, and photo & text combined.  Each data type is correlated to it's own cell which are all subclassed from a basic cell `AHFeedBasicCell`.  All the heavy lifting is done inside the basic cell, and the subclasses are mainly to accommodate the different display layouts.
*  I've also included the main data model `Hoot` which is constructed from a JSON response from our API.  A hoot is similar to a tweet or facebook post and shares many similar properties.
*  Inside the `Hoot` file is an extension to the API controller.  I like extending the api controller into the data model, especially during development, to lump all of the calls pertaining to that model together.

### 3rd Party libraries

*  PromiseKit: Cleanly handle asynchronous requests and also help simplify error handling.  I feel it makes the code more readable as well.
*  SDWebImage: Handle the image processing and caching.
*  Cartography:  You may notice there are no storyboards or xib files.  I like to layout views in code, and cartography is a great tool to simply the Autolayout framework and also make the layouts legibile.  Cartography is invoked by the `constrain` method in all the provided views
*  SwiftyJSON:  Makes working with JSON objects simple

### Image of the view this code creates
![Feed Screenshot](/screenshot.png)
