//
//  ETProfileViewController.h
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/10/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ETProfileViewControllerDelegate <NSObject>
-(void)didPressLike;
-(void)didPressDislike;
@end

@interface ETProfileViewController : UIViewController
@property (strong, nonatomic) PFObject *photo;
@property (weak, nonatomic) id <ETProfileViewControllerDelegate> delegate;
@end
