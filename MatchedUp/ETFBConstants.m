//
//  ETFBConstants.m
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/7/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import "ETFBConstants.h"

@implementation ETFBConstants

NSString *const kCCUserProfileKey = @"profile";
NSString *const kCCUserProfileNameKey = @"name";
NSString *const kCCUserProfileFirstNameKey = @"firstName";
NSString *const kCCUserProfileLocation = @"location";
NSString *const kCCUserProfileGender = @"gender";
NSString *const kCCUserProfileBirthday = @"birthday";
NSString *const kCCUserProfileInterestedIn = @"interestedIn";
NSString *const kCCUserProfilePictureURL = @"pictureURL";

#pragma mark - Photo Class

NSString *const kCCPhotoClassKey = @"Photo";
NSString *const kCCPhotoUserKey = @"user";
NSString *const kCCPhotoPictureKey = @"image";

NSString *const kCCUserProfileRelationshipStatusKey = @"relationshipStatus";
NSString *const kCCUserProfileAgeKey = @"age";

#pragma - mark User

NSString *const kCCUserTagLineKey = @"tagLine";

#pragma - mark Activity

NSString *const kCCActivityClassKey      = @"Activity";
NSString *const kCCActivityTypeKey       = @"type";
NSString *const kCCActivityFromUserKey   = @"fromUser";
NSString *const kCCActivityToUserKey     = @"toUser";
NSString *const kCCActivityPhotoKey      = @"photo";
NSString *const kCCActivityTypeLikeKey   = @"like";
NSString *const kCCActivityTypeDislikeKey = @"dislike";

#pragma mark - Settings

NSString *const kCCMenEnabledKey                = @"men";
NSString *const kCCWomenEnabledKey              = @"women";
NSString *const kCCSingleEnabledKey             = @"single";
NSString *const kCCAgeMaxKey                    = @"ageMax";
@end
