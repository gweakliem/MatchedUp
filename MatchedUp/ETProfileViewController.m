//
//  ETProfileViewController.m
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/10/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import "ETProfileViewController.h"

@interface ETProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *taglineLabel;
@end

@implementation ETProfileViewController

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
    PFFile *pictureFile = self.photo[kCCPhotoPictureKey];
    
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.profilePictureImageView.image = [UIImage imageWithData:data];
        }
    }];
    
    PFUser *user = self.photo[kCCPhotoUserKey];
    self.locationLabel.text = user[kCCUserProfileKey][kCCUserProfileLocation];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kCCUserProfileKey][kCCUserProfileAgeKey]];
    self.statusLabel.text = user[kCCUserProfileKey][kCCUserProfileRelationshipStatusKey];
    self.taglineLabel.text = user[kCCUserTagLineKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
