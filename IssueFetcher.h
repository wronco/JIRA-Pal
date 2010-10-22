//
//  untitled.h
//  JiraBuddy
//
//  Created by Will Ronco on 1/7/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

#import "ASIHTTPRequest.h"
#import "Filter.h"
#import "Issue.h"
//#import "ASINetworkQueue.h"

#define READY 0
#define IN_PROGRESS 1
#define ERROR 2
#define DONE 3

@interface IssueFetcher : NSObject {
    NSNumber *syncStatus;
    NSString *currentElement;
    ASIHTTPRequest *req;
    
    NSMutableDictionary *currentObjectDictionary;
    NSManagedObjectContext *moc;
    Filter *currentFilter;
    NSData *dataForPostBody;
    NSMutableArray *syncedIssues;
    int newIssues;
    int updatedIssues;
    int resolvedIssues;
}
@property (nonatomic, retain) NSNumber *syncStatus;
@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) ASIHTTPRequest *req;

@property (nonatomic, retain) NSMutableDictionary *currentObjectDictionary;
@property (nonatomic, retain) NSManagedObjectContext *moc;
@property (nonatomic, retain) Filter *currentFilter;
@property (nonatomic, retain) NSData *dataForPostBody;

@property (nonatomic, retain) NSMutableArray *syncedIssues;
@property int newIssues;
@property int updatedIssues;
@property int resolvedIssues;


- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context andFilter:(Filter *)f;
- (void)fetchIssues;

@end
