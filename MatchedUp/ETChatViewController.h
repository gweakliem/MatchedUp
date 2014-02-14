//
//  ETChatViewController.h
//  MatchedUp
//
//  Created by Gordon Weakliem on 1/21/14.
//  Copyright (c) 2014 Eighty Twenty. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface ETChatViewController : JSMessagesViewController <JSMessagesViewDataSource,JSMessagesViewDelegate>
@property (strong, nonatomic) PFObject *chatRoom;
@end
