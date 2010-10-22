// 
//  Issue.m
//  JiraBuddy
//
//  Created by Will Ronco on 1/7/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import "Issue.h"


@implementation Issue 

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

- (NSDate *)updated 
{
    NSDate * tmpValue;
    
    [self willAccessValueForKey:@"updated"];
    tmpValue = [self primitiveValueForKey:@"updated"];
    [self didAccessValueForKey:@"updated"];
    
    return tmpValue;
}

- (void)setUpdated:(NSDate *)value 
{
    [self willChangeValueForKey:@"updated"];
    [self setPrimitiveValue:value forKey:@"updated"];
    [self didChangeValueForKey:@"updated"];
}

- (NSString *)project 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"project"];
    tmpValue = [self primitiveValueForKey:@"project"];
    [self didAccessValueForKey:@"project"];
    
    return tmpValue;
}

- (void)setProject:(NSString *)value 
{
    [self willChangeValueForKey:@"project"];
    [self setPrimitiveValue:value forKey:@"project"];
    [self didChangeValueForKey:@"project"];
}

- (NSString *)assignee 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"assignee"];
    tmpValue = [self primitiveValueForKey:@"assignee"];
    [self didAccessValueForKey:@"assignee"];
    
    return tmpValue;
}

- (void)setAssignee:(NSString *)value 
{
    [self willChangeValueForKey:@"assignee"];
    [self setPrimitiveValue:value forKey:@"assignee"];
    [self didChangeValueForKey:@"assignee"];
}

- (NSNumber *)type 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"type"];
    tmpValue = [self primitiveValueForKey:@"type"];
    [self didAccessValueForKey:@"type"];
    
    return tmpValue;
}

- (void)setType:(NSNumber *)value 
{
    [self willChangeValueForKey:@"type"];
    [self setPrimitiveValue:value forKey:@"type"];
    [self didChangeValueForKey:@"type"];
}

- (NSString *)key 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"key"];
    tmpValue = [self primitiveValueForKey:@"key"];
    [self didAccessValueForKey:@"key"];
    
    return tmpValue;
}

- (void)setKey:(NSString *)value 
{
    [self willChangeValueForKey:@"key"];
    [self setPrimitiveValue:value forKey:@"key"];
    [self didChangeValueForKey:@"key"];
}

- (NSString *)summary 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"summary"];
    tmpValue = [self primitiveValueForKey:@"summary"];
    [self didAccessValueForKey:@"summary"];
    
    return tmpValue;
}

- (void)setSummary:(NSString *)value 
{
    [self willChangeValueForKey:@"summary"];
    [self setPrimitiveValue:value forKey:@"summary"];
    [self didChangeValueForKey:@"summary"];
}

- (NSDate *)created 
{
    NSDate * tmpValue;
    
    [self willAccessValueForKey:@"created"];
    tmpValue = [self primitiveValueForKey:@"created"];
    [self didAccessValueForKey:@"created"];
    
    return tmpValue;
}

- (void)setCreated:(NSDate *)value 
{
    [self willChangeValueForKey:@"created"];
    [self setPrimitiveValue:value forKey:@"created"];
    [self didChangeValueForKey:@"created"];
}

- (NSString *)reporter 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"reporter"];
    tmpValue = [self primitiveValueForKey:@"reporter"];
    [self didAccessValueForKey:@"reporter"];
    
    return tmpValue;
}

- (void)setReporter:(NSString *)value 
{
    [self willChangeValueForKey:@"reporter"];
    [self setPrimitiveValue:value forKey:@"reporter"];
    [self didChangeValueForKey:@"reporter"];
}

- (NSString *)resolution 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"resolution"];
    tmpValue = [self primitiveValueForKey:@"resolution"];
    [self didAccessValueForKey:@"resolution"];
    
    return tmpValue;
}

- (void)setResolution:(NSString *)value 
{
    [self willChangeValueForKey:@"resolution"];
    [self setPrimitiveValue:value forKey:@"resolution"];
    [self didChangeValueForKey:@"resolution"];
}

- (NSNumber *)status 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"status"];
    tmpValue = [self primitiveValueForKey:@"status"];
    [self didAccessValueForKey:@"status"];
    
    return tmpValue;
}

- (void)setStatus:(NSNumber *)value 
{
    [self willChangeValueForKey:@"status"];
    [self setPrimitiveValue:value forKey:@"status"];
    [self didChangeValueForKey:@"status"];
}

- (NSNumber *)votes 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"votes"];
    tmpValue = [self primitiveValueForKey:@"votes"];
    [self didAccessValueForKey:@"votes"];
    
    return tmpValue;
}

- (void)setVotes:(NSNumber *)value 
{
    [self willChangeValueForKey:@"votes"];
    [self setPrimitiveValue:value forKey:@"votes"];
    [self didChangeValueForKey:@"votes"];
}


- (NSImage *)priorityIcon{
    NSLog(@"ICON");
    NSString *iconURL = [[self priority] icon];
    NSArray *urlParts = [iconURL componentsSeparatedByString:@"/"];
    NSString *filename = [urlParts objectAtIndex:[urlParts count] - 1];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString *applicationSupportDirectory = [basePath stringByAppendingPathComponent:@"JiraBuddy"];
    NSString *filepath = [applicationSupportDirectory stringByAppendingPathComponent:filename];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        NSLog(@"Fetching file %@", filename);
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:iconURL]];
        [request startSynchronous];
        NSError *error = [request error];
        if (!error) {
            NSData *receivedData = [request responseData];
            [receivedData writeToFile:filepath atomically:YES];
        }else {
            NSLog(@"Could not get file from %@ (%@)", filepath, iconURL);
        }
    }else {
        NSLog(@"Using image at %@", filepath);
    }

    return [[NSImage alloc] initWithContentsOfFile:filepath]; 
}

- (NSManagedObject *)priority 
{
    id tmpObject;
    
    [self willAccessValueForKey:@"priority"];
    tmpObject = [self primitiveValueForKey:@"priority"];
    [self didAccessValueForKey:@"priority"];
    
    return tmpObject;
}

- (void)setPriority:(NSManagedObject *)value 
{
    [self willChangeValueForKey:@"priority"];
    [self setPrimitiveValue:value forKey:@"priority"];
    [self didChangeValueForKey:@"priority"];
}

@end
