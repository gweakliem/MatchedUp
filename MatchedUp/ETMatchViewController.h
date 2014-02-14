//
//  ETMatchViewController.h
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/20/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ETMatchViewControllerDelegate <NSObject>
-(void)presentMatchesViewController;
@end

@interface ETMatchViewController : UIViewController
@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak, nonatomic) id <ETMatchViewControllerDelegate> delegate;
@end
