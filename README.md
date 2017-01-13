- UITabBarController based application
  * Tab #1: users can see all the people they are following posts
    * UITableView with custom UITableviewcell layout
  * Tab #2: users can search for other users by their username
    * UITableview with custom UITableviewcell layout
  * Tab #3: users can share a photo (either using the camera or choosing one from the photo library)
    * The camera and the photo library are being accessed using a third party swift library (Fusuma)
    * The photo is being cropped and a custom view for applying a filter is being presented (using a category for UIImage and Core Image API)
  * Tab #4: users can see all their posts and some profile-specific information (like the people they are following)
    * A custom view for user's profile photo, number of posts, people that are following them, people they are following
    * UICollectionView for user's posts
    
- Consumes Kinvey's backend services (through their iOS API)
    * User entity
    * Post entity
    * Relation entity
    * Photo data
  
- Core Data to cache posts after they are being retrieved from the server
    * Post entity
  
- NSSstring and UIImage categories (Font Awesome)
    * Font Awesome predefined icons

- UISwipeGestureRecognizer
    * Swiping right on any non top level UIViewController will pop it out of its UINavigationController's stack
