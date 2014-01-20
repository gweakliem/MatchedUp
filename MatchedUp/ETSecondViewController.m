//
//  ETSecondViewController.m
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/1/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import "ETSecondViewController.h"

@interface ETSecondViewController ()

@end

@implementation ETSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects){
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kCCPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
