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

@interface ETHomeViewController ()
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
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

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
    
    //self.likeButton.enabled = NO;
    //self.dislikeButton.enabled = NO;
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
            [self queryForCurrentPhotoIndex];
        } else {
            NSLog(@"Error downloading photos and users %@", error);
        }
    }];
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
    }
}

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
}

- (IBAction)settingsBarButtonItem:(UIBarButtonItem *)sender {
}

- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
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
                        //Some other type of activity
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
        }];
    }
}

-(void) updateView
{
    self.firstNameLabel.text = self.photo[kCCPhotoUserKey][kCCUserProfileKey][kCCUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",self.photo[kCCPhotoUserKey][kCCUserProfileKey][kCCUserProfileAgeKey]];
    self.tagLineLabel.text = self.photo[kCCUserProfileKey][kCCUserTagLineKey];
}

-(void)setupNextPhoto
{
    if (self.currentPhotoIndex + 1 <self.photos.count)
    {
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
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
@end
