//
//  Issue.h
//  JiraBuddy
//
//  Created by Will Ronco on 1/7/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ASIHTTPRequest.h"

@interface Issue :  NSManagedObject  
{
}

- (NSNumber *)nid;
- (void)setNid:(NSNumber *)value;

- (NSString *)description;
- (void)setDescription:(NSString *)value;

- (NSDate *)updated;
- (void)setUpdated:(NSDate *)value;

- (NSString *)project;
- (void)setProject:(NSString *)value;

- (NSString *)assignee;
- (void)setAssignee:(NSString *)value;

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
- (Priority *)priority;
- (void)setPriority:(NSManagedObject *)value;

@end
