//
//  PriorityFilterFetcher.m
//  JiraPal
//
//  Created by Will Ronco on 1/9/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import "EntityFetcher.h"


@implementation EntityFetcher
@synthesize syncStatus, myEntityName, syncedEntities, currentObjectDictionary, currentElement, moc;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context name:(NSString *)eName{
    if (self = [super init]){
        currentObjectDictionary = [[[NSMutableDictionary alloc] initWithCapacity:10] retain];
        syncedEntities = [[[NSMutableArray alloc] init] retain];
        [self setMoc:context];
        [self setSyncStatus:[NSNumber numberWithInt:READY]];
        [self setMyEntityName:eName];
        //[self addObserver:self forKeyPath:@"syncStatus" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}


-(void)startFetch:(id)sender{
    NSLog(@"Starting fetch of %@", myEntityName);
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	NSString *path = [[NSBundle mainBundle] pathForResource:myEntityName ofType: @"txt"];   
    NSString *shell = [NSString stringWithContentsOfFile:path encoding: NSUTF8StringEncoding error: NULL];
    NSString *requestBody = [NSString stringWithFormat:shell, [d valueForKey:@"jiraURL"], [d valueForKey:@"token"]];
    
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rpc/soap/jirasoapservice-v2", [d valueForKey:@"jiraURL"]]]];
	[req setRequestMethod:@"POST"];
	[req addRequestHeader:@"Host" value:[[d valueForKey:@"jiraURL"] substringFromIndex:7]];
	[req addRequestHeader:@"SOAPAction" value:@""];
	[req addRequestHeader:@"Content-Type" value:@"text/xml"];
    [req setShouldStreamPostDataFromDisk:YES];
    [req setPostBody:(NSMutableData *)[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [req setDelegate:self];
    [req startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[request responseData]];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"%@", [[request error] description]); 
    [[[NSApplication sharedApplication] delegate] log:[NSString stringWithFormat:@"Error in login request: %@", [[request error] description]]];
    [self setSyncStatus:[NSNumber numberWithInt:ERROR]];
}


-(NSManagedObject *)findEntityByNid:(NSNumber *)value{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:myEntityName inManagedObjectContext:moc];
    [request setEntity:entity]; 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nid == %d", [value intValue]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *result = [moc executeFetchRequest:request error:&error];
    [request release];
    if ((result != nil) && ([result count] > 0) && (error == nil)){
        NSManagedObject *ret = [result objectAtIndex:0];
        return ret;
    }else {
        if (error){ NSLog(@"Error in findEntity: %@", error); }
        return nil;
    }
}

-(void)deleteEntitiesNotInArray:(NSMutableArray *)objectsToKeep{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:myEntityName inManagedObjectContext:moc];
    [request setEntity:entity]; 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (self IN %@)", objectsToKeep];
//    NSLog(@"%@ to keep:",[self myEntityName]);
//    for(int i=0;i<[objectsToKeep count];i++){
//        NSLog(@"%@", [objectsToKeep objectAtIndex:i]);
//    }
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [moc executeFetchRequest:request error:&error];
    [request release];
    if ((result != nil) && ([result count] > 0) && (error == nil)){
        NSLog(@"Deleting %d %@", [result count], myEntityName);
        for(int i=0;i<[result count]; i++){
            NSManagedObject *ret = [result objectAtIndex:i];
            [moc deleteObject:ret];
        }
        
    }else {
        NSLog(@"Nothing to delete for %@", myEntityName);
        if (error){ NSLog(@"Error in delete entries: %@", error); }
    }
}

#pragma mark XML fetching functions
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    //the parser started this document. what are you going to do?
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if (![elementName isEqualToString:@"multiRef"]){ return; }
    if (![currentObjectDictionary valueForKey:@"id"]){ return; }

    NSManagedObject *pri = [self findEntityByNid:[currentObjectDictionary valueForKey:@"id"]];
    if (!pri){
        pri = [NSEntityDescription insertNewObjectForEntityForName:myEntityName inManagedObjectContext:moc];
    }
    [currentObjectDictionary setValue:[currentObjectDictionary valueForKey:@"id"] forKey:@"nid"];
    [currentObjectDictionary removeObjectForKey:@"id"];
    [pri setValuesForKeysWithDictionary:currentObjectDictionary];
    [syncedEntities addObject:pri];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"multiRef"]) {
        [currentObjectDictionary removeAllObjects];
    }
    [self setCurrentElement:elementName];
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([currentElement isEqualToString:@"faultstring"]){
        [self setSyncStatus:[NSNumber numberWithInt:ERROR]];
    } else {
        if ([currentObjectDictionary valueForKey:currentElement]){
            [currentObjectDictionary setValue:[[currentObjectDictionary valueForKey:currentElement] stringByAppendingString:string] forKey:currentElement];
        }else {
            [currentObjectDictionary setValue:string forKey:currentElement];
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    //NSLog(@"Finished parsing with status %@", syncStatus);
    [self deleteEntitiesNotInArray:syncedEntities];
    [self setSyncStatus:[NSNumber numberWithInt: DONE]];        
}

@end
