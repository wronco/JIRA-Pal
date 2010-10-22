//
//  Filter.h
//  JiraBuddy
//
//  Created by Will Ronco on 1/8/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Issue;

@interface Filter :  NSManagedObject  
{
}

- (NSNumber *)nid;
- (void)setNid:(NSNumber *)value;

- (NSString *)name;
- (void)setName:(NSString *)value;

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

// Access to-many relationship via -[NSObject mutableSetValueForKey:]
- (void)addIssuesObject:(Issue *)value;
- (void)removeIssuesObject:(Issue *)value;

@end
