//
//  ETEditProfileViewController.m
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/8/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import "ETEditProfileViewController.h"

@interface ETEditProfileViewController ()
@property (strong, nonatomic) IBOutlet UITextView *tagLineTextView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)saveButtonBarItemPressed:(UIBarButtonItem *)sender;

@end

@implementation ETEditProfileViewController

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
    
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kCCPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
    self.tagLineTextView.text = [[PFUser currentUser] objectForKey:kCCUserTagLineKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonBarItemPressed:(UIBarButtonItem *)sender
{
    [[PFUser currentUser] setObject:self.tagLineTextView.text forKey:kCCUserTagLineKey];
    [[PFUser currentUser] saveInBackground];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
