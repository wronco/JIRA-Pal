//
//  Issue.h
//  JiraPal
//
//  Created by Will Ronco on 1/9/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ASIHTTPRequest.h"

@class Filter;
@class Priority;

@interface Issue :  NSManagedObject  
{
}

- (NSString *)description;
- (void)setDescription:(NSString *)value;

- (NSDate *)updated;
- (void)setUpdated:(NSDate *)value;

- (NSString *)project;
- (void)setProject:(NSString *)value;

- (NSString *)assignee;
- (void)setAssignee:(NSString *)value;

- (NSNumber *)nid;
- (void)setNid:(NSNumber *)value;

- (NSNumber *)type;
- (void)setType:(NSNumber *)value;

- (NSString *)key;
- (void)setKey:(NSString *)value;

- (NSString *)summary;
- (void)setSummary:(NSString *)value;

- (NSDate *)created;
- (void)setCreated:(NSDate *)value;

- (NSString *)reporter;
- (void)setReporter:(NSString *)value;

- (NSString *)resolution;
- (void)setResolution:(NSString *)value;

- (NSNumber *)status;
- (void)setStatus:(NSNumber *)value;

- (NSNumber *)votes;
- (void)setVotes:(NSNumber *)value;

- (NSImage *)priorityIcon;

// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addFiltersObject:(Filter *)value;
- (void)removeFiltersObject:(Filter *)value;

- (Priority *)priority;
- (void)setPriority:(Priority *)value;

@end
