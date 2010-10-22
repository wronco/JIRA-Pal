//
//  LoginManager.h
//  JiraBuddy
//
//  Created by Will Ronco on 1/7/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASIFormDataRequest.h"

#define NOT_LOGGED 0
#define LOGGING_IN 1
#define LOGIN_ERROR 2
#define LOGGED_IN 3

@interface LoginManager : NSObject {
    NSNumber *status;
    NSString *currentElement;

}
@property (nonatomic, retain) NSNumber *status;
@property (nonatomic, retain) NSString *currentElement;


-(IBAction)login:(id)sender;

@end
