# nurture

Shopping Application for Plants.
- app state management with Provider, InheritedWidget
- learnt imp concepts like ChangeNotifier, AnimatedList, Dialogs, Drawers, Firebase, CustomClippers, etc.
- creating custom streams for values
- learnt how to use StreamBuilder and StreamProvider
- made use of various packages to improve functionality
- tried UI concepts like Neumorphism
- Drawer Navigation
- implemented various animations to make actions look less jarring
- 'My Plants' section helps users water their plants on time
- 'Home' section lists all the plants available for purchase
- 'Favourites'- user can remove and view all their favourites here
- 'Profile'- user can change their display name and profile picture here
- How the app is meant to be used:
  - User can sign in with google email id or as a guest. As a guest, your actions are saved and your data can be transfered when you opt to sign in to your google account* in the       'Cart' page. However, if you sign out as an anonymous user, your data will be deleted.
  - Only 2 plants of one type allowed in one session.
  - Clicking any image in 'Home' page directs you to its main page, which contains its description (drag up); to add items to cart select the number and then click on the black      'Cart' button.
  - Clicking in the 'Favorites' page will also direct you to the plant's main page. To remove from favorites, long press on the tile and drag it to the 'blue bin icon'
  - The 'Cart' page can also direct user to the plant's main page. To delete an item from cart, swipe right on the image and then press the 'red cross icon'
  - To place your order, long press on the 'outlined place order icon' and then leave when the 'green progress indicator appears'. *An anonymous user will be prompted to sign in       here.
  - After placing the order your plants will appear in the 'My Plants' section. If they are already watered, the circle will be filled with only 'light blue'. If you need to water     them you will be prompted to do so with the appearance of a 'red exclamation' and a hollow circle. If they plants are left unwatered for a long period of time, they will die       and the tile will turn grey. 
