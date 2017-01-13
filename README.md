#Minstagram

- <h3>UITabBarController based application<h3>
  * Tab #1: users can see all the people they are following posts
    * UITableView with custom UITableviewcell layout
  * Tab #2: users can search for other users by their username
    * UITableView with custom UITableviewcell layout
  * Tab #3: users can share a photo (either using the camera or choosing one from the photo library)
    * The camera and the photo library are being accessed using a third party swift library (Fusuma)
    * The photo is being cropped and a custom view for applying a filter is being presented (using a category for UIImage and Core Image API)
  * Tab #4: users can see all their posts and some profile-specific information (like the people they are following)
    * A custom view for user's profile photo, number of posts, people that are following them, people they are following
    * UICollectionView for user's posts
    
- <h3>Consumes Kinvey's backend services (through their iOS API)<h3>
    * User entity
    * Post entity
    * Relation entity
    * Photo data
  
- <h3>Core Data to cache posts after they are being retrieved from the server<h3>
    * Post entity
  
- <h3>NSSstring and UIImage categories (Font Awesome)<h3>
    * Font Awesome predefined icons

- <h3>UISwipeGestureRecognizer<h3>
    * Swiping right on any non top level UIViewController will pop it out of its UINavigationController's stack
