//
//  ETLoginViewController.m
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/1/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import "ETLoginViewController.h"

@interface ETLoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)loginButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation ETLoginViewController

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
    self.activityIndicator.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation];
        NSLog(@"the user is already signed in ");
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBactions
- (IBAction)loginButtonPressed:(UIButton *)sender {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    NSArray *permissionsArray = @[@"user_about_me",@"user_interests", @"user_relationships",@"user_birthday",@"user_location",@"user_relationship_details"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        if (!user ) {
            if (!error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"The Facebook Login was Cancelled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil  cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
        } else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
        }
        NSLog(@"%@",user);
    } ];
}

#pragma mark helper methods
-(void)updateUserInformation
{
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            
            // Parse the data received
            NSDictionary *userDictionary = (NSDictionary *)result;
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:7];

            // create FB image URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
            if (userDictionary[@"name"]) {
                userProfile[kCCUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]) {
                userProfile[kCCUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]) {
                userProfile[kCCUserProfileLocation] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]) {
                userProfile[kCCUserProfileGender] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]) {
                userProfile[kCCUserProfileBirthday] = userDictionary[@"birthday"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate: date];
                int age = seconds / 31536000;
                userProfile[kCCUserProfileAgeKey] = @(age);
            }
            
            if (userDictionary[@"interested_in"]) {
                userProfile[kCCUserProfileInterestedIn] = userDictionary[@"interested_in"];
            }
            if (userDictionary[@"relationship_status"]) {
                userProfile[kCCUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[kCCUserProfilePictureURL] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kCCUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            [self requestImage];
        }
        else {
            NSLog(@"Error in Facebook Request %@", error);
        }
    }];
}

- (void)uploadPFFileToParse:(UIImage *)image
{
    NSLog(@"upload called");
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if (!imageData) {
        NSLog(@"Image data was not fourd");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            PFObject *photo = [PFObject objectWithClassName:kCCPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kCCPhotoUserKey];
            [photo setObject:photoFile forKey:kCCPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            }];
        }
    }];
}

- (void)requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    // Use count instead
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0){
            PFUser *user = [PFUser currentUser];
            // if user doesn't have photo saved yet, download and save it.
            self.imageData = [[NSMutableData alloc] init];
            NSURL *profilePictureURL = [NSURL URLWithString:user[kCCUserProfileKey][kCCUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            
            // Run network request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection) {
                NSLog(@"Failed to download picture");
            }
        }
    }];
}

#pragma mark NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // All data has been downloaded, now we can set the image in the header image view
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}

@end
