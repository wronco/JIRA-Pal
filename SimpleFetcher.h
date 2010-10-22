//
//  SimpleFetcher.h
//  JiraPal
//
//  Created by Will Ronco on 1/14/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASIHTTPRequest.h"
#import "Filter.h"

#define READY 0
#define IN_PROGRESS 1
#define ERROR 2
#define DONE 3

@interface SimpleFetcher : NSObject {
    NSNumber *syncStatus;
    NSString *currentElement;
    NSString *requestBody;
    
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
@property (nonatomic, retain) NSString *requestBody;

@property (nonatomic, retain) NSMutableDictionary *currentObjectDictionary;
@property (nonatomic, retain) NSManagedObjectContext *moc;
@property (nonatomic, retain) Filter *currentFilter;
@property (nonatomic, retain) NSData *dataForPostBody;

@property (nonatomic, retain) NSMutableArray *syncedIssues;
@property int newIssues;
@property int updatedIssues;
@property int resolvedIssues;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context andFilter:(Filter *)f;

-(void)startFetch;
@end
