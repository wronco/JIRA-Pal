// 
//  Filter.m
//  JiraBuddy
//
//  Created by Will Ronco on 1/8/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import "Filter.h"

#import "Issue.h"

@implementation Filter 

- (NSNumber *)nid 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"nid"];
    tmpValue = [self primitiveValueForKey:@"nid"];
    [self didAccessValueForKey:@"nid"];
    
    return tmpValue;
}

- (void)setNid:(NSNumber *)value 
{
    [self willChangeValueForKey:@"nid"];
    [self setPrimitiveValue:value forKey:@"nid"];
    [self didChangeValueForKey:@"nid"];
}

- (NSString *)name 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"name"];
    tmpValue = [self primitiveValueForKey:@"name"];
    [self didAccessValueForKey:@"name"];
    
    return tmpValue;
}

- (void)setName:(NSString *)value 
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveValue:value forKey:@"name"];
    [self didChangeValueForKey:@"name"];
}


- (void)addIssuesObject:(Issue *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"issues" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"issues"] addObject:value];
    [self didChangeValueForKey:@"issues" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeIssuesObject:(Issue *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"issues" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"issues"] removeObject:value];
    [self didChangeValueForKey:@"issues" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues{
    //NSLog(@"Updating filter from dictionary: %@", keyedValues);
    for (id key in keyedValues) {
        if ([key isEqual:@"nid"]) {
            [self setNid:[NSNumber numberWithInt:[[keyedValues valueForKey:key] intValue]]];
        }
        else if([key isEqual:@"name"]){
            [self setName:[keyedValues valueForKey:key]];                
        }
    }
}
@end
