// 
//  Priority.m
//  JiraBuddy
//
//  Created by Will Ronco on 1/8/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import "Priority.h"

#import "Issue.h"

@implementation Priority 

- (NSString *)icon 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"icon"];
    tmpValue = [self primitiveValueForKey:@"icon"];
    [self didAccessValueForKey:@"icon"];
    
    return tmpValue;
}

- (void)setIcon:(NSString *)value 
{
    [self willChangeValueForKey:@"icon"];
    [self setPrimitiveValue:value forKey:@"icon"];
    [self didChangeValueForKey:@"icon"];
}

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

- (NSString *)description 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"description"];
    tmpValue = [self primitiveValueForKey:@"description"];
    [self didAccessValueForKey:@"description"];
    
    return tmpValue;
}

- (void)setDescription:(NSString *)value 
{
    [self willChangeValueForKey:@"description"];
    [self setPrimitiveValue:value forKey:@"description"];
    [self didChangeValueForKey:@"description"];
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

- (NSString *)color 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"color"];
    tmpValue = [self primitiveValueForKey:@"color"];
    [self didAccessValueForKey:@"color"];
    
    return tmpValue;
}

- (void)setColor:(NSString *)value 
{
    [self willChangeValueForKey:@"color"];
    [self setPrimitiveValue:value forKey:@"color"];
    [self didChangeValueForKey:@"color"];
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
    //NSLog(@"Updating priority from %@", keyedValues);
    for (id key in keyedValues){
        if ([key isEqual:@"nid"]){
            [self setNid:[NSNumber numberWithInt:[[keyedValues objectForKey:key] intValue]]];            
        }else if ([key isEqual:@"name"]){
            [self setName:[keyedValues valueForKey:key]];            
        }else if ([key isEqual:@"color"]){
            [self setColor:[keyedValues valueForKey:key]];
        }else if ([key isEqual:@"icon"]){
            [self setIcon:[keyedValues valueForKey:key]];
        }
    }

}

@end
