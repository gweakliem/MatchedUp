//
//  ETTestUser.m
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/18/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import "ETTestUser.h"

@implementation ETTestUser
+(void)saveTestUserToParse
{
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"sign up %@", error);
        if (!error){
            NSDictionary *profile = @{@"age" : @28, @"birthday" : @"11/22/1985", @"firstName" : @"Julie", @"gender" : @"female", @"location" : @"Berlin, Germany", @"name" : @"Julie Adams"};
            [newUser setObject:profile forKey:@"profile"];
            
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                UIImage *profileImage = [UIImage imageNamed:@"cat.jpeg"];
                NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
                
                PFFile *photoFile = [PFFile fileWithData:imageData];
                
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded){
                        PFObject *photo = [PFObject objectWithClassName:kCCPhotoClassKey];
                        [photo setObject:newUser forKey:kCCPhotoUserKey];
                        [photo setObject:photoFile forKey:kCCPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded)  NSLog(@"Photo saved successfully");
                        }];
                    }
                }];
            }];
        }
    }];
}

@end
