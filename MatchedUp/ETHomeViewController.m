//
//  ETHomeViewController.m
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/8/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import "ETHomeViewController.h"
#import "ETProfileViewController.h"
#import "ETTestUser.h"
#import "ETMatchViewController.h"
#import "ETTransitionAnimator.h"

@interface ETHomeViewController () <ETMatchViewControllerDelegate, ETProfileViewControllerDelegate, UIViewControllerTransitioningDelegate>

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)settingsBarButtonItem:(UIBarButtonItem *)sender;
- (IBAction)likeButtonPressed:(UIButton *)sender;
- (IBAction)infoButtonPressed:(UIButton *)sender;
- (IBAction)dislikeButtonPressed:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;

@property (strong, nonatomic) NSArray *photos;
@property (nonatomic) int currentPhotoIndex;
@property (strong, nonatomic) PFObject *photo;

@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;
@property (strong, nonatomic) NSMutableArray *activities;

@end

@implementation ETHomeViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //[ETTestUser saveTestUserToParse];
    [self setupViews];
    
}

// called every time this view is displayed on screen
-(void)viewDidAppear:(BOOL)animated {
    self.photoImageView.image = nil;
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    // exclude myself
    [query whereKey:kCCPhotoUserKey notEqualTo:[PFUser currentUser]];
    // Retrieve objects from the foreign key
    [query includeKey:kCCPhotoUserKey];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            
            if ([self allowPhoto] == NO) {
                [self setupNextPhoto];
            }
            else {
                [self queryForCurrentPhotoIndex];
            }
        } else {
            NSLog(@"Error downloading photos and users %@", error);
        }
    }];
}

-(void) setupViews
{
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self addShadowForView:self.buttonContainerView];
    [self addShadowForView:self.labelContainerView];
}

-(void) addShadowForView:(UIView*) view
{
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 4;
    view.layer.shadowRadius = 1;
    view.layer.shadowOffset = CGSizeMake(0,1);
    view.layer.shadowOpacity = 0.25;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"])
    {
        ETProfileViewController *profileVC = segue.destinationViewController;
        profileVC.photo = self.photo;
        profileVC.delegate = self;
    }
}

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
}

- (IBAction)settingsBarButtonItem:(UIBarButtonItem *)sender {
}

- (IBAction)likeButtonPressed:(UIButton *)sender {
    //Mixpanel *mixpanel = [Mixpanel sharedInstance];
    //[mixpanel track:@"Like"];
    //[mixpanel flush];
    [self checkLike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    //Mixpanel *mixpanel = [Mixpanel sharedInstance];
    //[mixpanel track:@"Dislike"];
    //[mixpanel flush];
    [self checkDislike];
}

#pragma mark Helper methods
- (void)queryForCurrentPhotoIndex
{
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kCCPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            } else {
                NSLog(@"Error retrieving photo %@: %@",file, error);
            }
        }];
        
        // query for current likes and dislikes by the current user on this photo
        PFQuery *queryForLike = [PFQuery queryWithClassName:kCCActivityClassKey];
        [queryForLike whereKey:kCCActivityTypeKey equalTo:kCCActivityTypeLikeKey];
        [queryForLike whereKey:kCCActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kCCActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kCCActivityClassKey];
        [queryForDislike whereKey:kCCActivityTypeKey equalTo:kCCActivityTypeDislikeKey];
        [queryForDislike whereKey:kCCActivityPhotoKey equalTo:self.photo];
        [queryForDislike whereKey:kCCActivityToUserKey equalTo:[PFUser currentUser]];
        
        // combine both queries into a union query
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error){
                self.activities = [objects mutableCopy];
                
                // no activities recorded
                if ([self.activities count] == 0) {
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                } else {
                    // we have some kind of like/dislike activity for this user.
                    // set liked/disliked based on previous activity
                    PFObject *activity = self.activities[0];
                    if ([activity[kCCActivityTypeKey] isEqualToString:kCCActivityTypeLikeKey]){
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    }
                    else if ([activity[kCCActivityTypeKey] isEqualToString:kCCActivityTypeDislikeKey]){
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    }
                    else {
                        // Some other type of activity, shouldn't ever happen so log this fact.
                        NSLog(@"Unknown activity found in queryForCurrentPhotoIndex %@",activity);
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            } else {
                NSLog(@"Error querying for likes/dislikes %@",error);
            }
        }];
    }
}

-(void) updateView
{
    self.firstNameLabel.text = self.photo[kCCPhotoUserKey][kCCUserProfileKey][kCCUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",self.photo[kCCPhotoUserKey][kCCUserProfileKey][kCCUserProfileAgeKey]];
}

-(void)setupNextPhoto
{
    if (self.currentPhotoIndex + 1 <self.photos.count)
    {
        self.currentPhotoIndex ++;
        
        if ([self allowPhoto] == NO) {
            // photo was rejected, recursive call.
            // TODO: rewrite as loop.
            [self setupNextPhoto];
        }
        else {
            [self queryForCurrentPhotoIndex];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users to View" message:@"Check Back Later for more People!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)saveLike {
    PFObject *likeActivity = [PFObject objectWithClassName:kCCActivityClassKey];
    [likeActivity setObject:kCCActivityTypeLikeKey forKey:kCCActivityTypeKey];
    // set up foreign key links to the from & to users
    [likeActivity setObject:[PFUser currentUser] forKey:kCCActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kCCPhotoUserKey] forKey:kCCActivityToUserKey];
    // store the photo that was (dis)liked.
    [likeActivity setObject:self.photo forKey:kCCActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         self.isLikedByCurrentUser = YES;
         self.isDislikedByCurrentUser = NO;
         [self.activities addObject: likeActivity];
         [self checkForPhotoUserLikes];
         // dismiss the current photo/profile and move to the next one.
         [self setupNextPhoto];
     }];
}

- (void)saveDislike
{
    PFObject *dislikeActivity = [PFObject objectWithClassName:kCCActivityClassKey];
    [dislikeActivity setObject:kCCActivityTypeDislikeKey forKey:kCCActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kCCActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kCCPhotoUserKey] forKey:kCCActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kCCActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject: dislikeActivity];
        [self setupNextPhoto];
    }];
}

- (void)checkLike
{
    if (self.isLikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }
    else if (self.isDislikedByCurrentUser){
        // delete the past dislike
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else [self saveLike];
}

- (void)checkDislike
{
    if (self.isDislikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser){
        // delete the past like
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
}

- (void)checkForPhotoUserLikes
{
    PFQuery *query = [PFQuery queryWithClassName:kCCActivityClassKey];
    // query for likes between myself and this user where the
    [query whereKey:kCCActivityFromUserKey equalTo:self.photo[kCCPhotoUserKey]];
    [query whereKey:kCCActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kCCActivityTypeKey equalTo:kCCActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0){
            [self createChatRoom];
            }
    }];
}

- (void)createChatRoom
{
    NSLog(@"createChatRoom called");
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kCCChatClassKey];
    [queryForChatRoom whereKey:kCCChatRoomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kCCChatRoomUser2Key equalTo:self.photo[kCCPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:kCCChatClassKey];
    [queryForChatRoomInverse whereKey:kCCChatRoomUser1Key equalTo:self.photo[kCCPhotoUserKey]];
    [queryForChatRoomInverse whereKey:kCCChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    // find a chatroom where this pair of users is involved
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"createChatRoom query for chat room failed: %@",error);
        }
        if ([objects count] == 0) {
            PFObject *chatroom = [PFObject objectWithClassName:kCCChatClassKey];
            [chatroom setObject:[PFUser currentUser] forKey:kCCChatRoomUser1Key];
            [chatroom setObject:self.photo[kCCPhotoUserKey] forKey:kCCChatRoomUser2Key];
            [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    UIStoryboard *myStoryboard = self.storyboard;
                    ETMatchViewController *matchViewController = [myStoryboard instantiateViewControllerWithIdentifier:@"matchVC"];
                    matchViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0  blue:0/25.0 alpha:.75];
                    matchViewController.transitioningDelegate = self;
                    matchViewController.matchedUserImage = self.photoImageView.image;
                    matchViewController.delegate = self;
                    matchViewController.modalPresentationStyle = UIModalPresentationCustom;
                    [self presentViewController:matchViewController animated:YES completion:nil];
                    
                } else {
                    NSLog(@"query to create chat room failed: %@",error);
                }
                
            }];
        } else {
            NSLog(@"Existing chat room found: %@", objects);
        }
    }];
}

- (BOOL)allowPhoto
{
    int maxAge = [[NSUserDefaults standardUserDefaults] integerForKey:kCCAgeMaxKey];
    BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kCCMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kCCWomenEnabledKey];
    BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kCCSingleEnabledKey];
    
    // get the photo for the current match candidate
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kCCPhotoUserKey];
    
    // get the age, gender, and relationship status
    int userAge = [user[kCCUserProfileKey][kCCUserProfileAgeKey] intValue];
    NSString *gender = user[kCCUserProfileKey][kCCUserProfileGender];
    NSString *relationshipStatus = user[kCCUserProfileKey][kCCUserProfileRelationshipStatusKey];
    
    // filter based on criteria, reject if they don't meet our filter.
    if (userAge >= maxAge){
        return NO;
    } else if (men == NO && [gender isEqualToString:@"male"]){
        return NO;
    } else if (women == NO && [gender isEqualToString:@"female"]){
        return NO;
    } else if (single == NO && ([relationshipStatus isEqualToString:@"single"] || [relationshipStatus isEqualToString:nil])) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark ETMatchViewControllerDelegate
-(void) presentMatchesViewController
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
    }];
}

#pragma  mark ETProfileViewControllerDelegate methods
-(void)didPressLike
{
    [self.navigationController popViewControllerAnimated:NO];
    [self checkLike];
}

-(void)didPressDislike
{
    [self.navigationController popViewControllerAnimated:NO];
    [self checkDislike];
}

#pragma marke UIViewControllerTransitioningDelegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    ETTransitionAnimator *animator = [[ETTransitionAnimator alloc] init];
    animator.presenting = YES;
    return animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    ETTransitionAnimator *animator = [[ETTransitionAnimator alloc] init];
    return animator;
}
@end
