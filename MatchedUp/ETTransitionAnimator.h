//
//  ETTransitionAnimator.h
//  MatchedUp
//
//  Created by Gordon Weakliem on 2/13/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) BOOL presenting;

@end
