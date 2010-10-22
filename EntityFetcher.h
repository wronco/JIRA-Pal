//
//  PriorityFilterFetcher.h
//  JiraPal
//
//  Created by Will Ronco on 1/9/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASIFormDataRequest.h"

#define READY 0
#define IN_PROGRESS 1
#define ERROR 2
#define DONE 3

@interface EntityFetcher : NSObject {
    NSNumber *syncStatus;

    NSString *myEntityName;
    NSMutableArray *syncedEntities;

    NSMutableDictionary *currentObjectDictionary;
    NSString *currentElement;
    NSManagedObjectContext *moc;

//    NSMutableArray *foundObjects;
    
}
@property (nonatomic, retain) NSMutableArray *syncedEntities;
@property (nonatomic, retain) NSString *myEntityName;
@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSNumber *syncStatus;
@property (nonatomic, retain) NSMutableDictionary *currentObjectDictionary;
@property (nonatomic, retain) NSManagedObjectContext *moc;

- (void)startFetch:(id)sender;
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context name:(NSString *)eName;
@end
