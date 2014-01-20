//
//  ETFBConstants.h
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/7/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETFBConstants : NSObject

#pragma mark user class
extern NSString *const kCCUserProfileKey;
extern NSString *const kCCUserProfileNameKey;
extern NSString *const kCCUserProfileFirstNameKey;
extern NSString *const kCCUserProfileLocation;
extern NSString *const kCCUserProfileGender;
extern NSString *const kCCUserProfileBirthday;
extern NSString *const kCCUserProfileInterestedIn;
extern NSString *const kCCUserProfilePictureURL;

#pragma mark - Photo Class

extern NSString *const kCCPhotoClassKey;
extern NSString *const kCCPhotoUserKey;
extern NSString *const kCCPhotoPictureKey;

extern NSString *const kCCUserProfileRelationshipStatusKey;
extern NSString *const kCCUserProfileAgeKey;

#pragma - mark User

extern NSString *const kCCUserTagLineKey;

#pragma - mark Activity

extern NSString *const kCCActivityClassKey;
extern NSString *const kCCActivityTypeKey;
extern NSString *const kCCActivityFromUserKey;
extern NSString *const kCCActivityToUserKey;
extern NSString *const kCCActivityPhotoKey;
extern NSString *const kCCActivityTypeLikeKey;
extern NSString *const kCCActivityTypeDislikeKey;

#pragma mark - Settings

extern NSString *const kCCMenEnabledKey;
extern NSString *const kCCWomenEnabledKey;
extern NSString *const kCCSingleEnabledKey;
extern NSString *const kCCAgeMaxKey;

@end
