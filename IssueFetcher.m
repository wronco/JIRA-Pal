//
//  untitled.m
//  JiraBuddy
//
//  Created by Will Ronco on 1/7/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import "IssueFetcher.h"
#import "JiraBuddy_AppDelegate.h"

@implementation IssueFetcher
@synthesize syncStatus, currentElement, currentObjectDictionary, moc, currentFilter, syncedIssues, dataForPostBody, newIssues, updatedIssues, resolvedIssues, req;


- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context andFilter:(Filter *)f{
    if (self = [super init]){
        currentObjectDictionary = [[[NSMutableDictionary alloc] initWithCapacity:10] retain];
        syncedIssues = [[[NSMutableArray alloc] init] retain];
        newIssues = 0;
        updatedIssues = 0;
        resolvedIssues = 0;  
        [self setMoc:context];
        [self setCurrentFilter:f];
        [self setSyncStatus:[NSNumber numberWithInt:READY]];
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        
        NSString *path = [[NSBundle mainBundle] pathForResource: @"getIssues" ofType: @"txt"];   
        NSString *shell = [NSString stringWithContentsOfFile:path encoding: NSUTF8StringEncoding error: NULL];
        NSString *postBody = [NSString stringWithFormat:shell, [d valueForKey:@"jiraURL"], [d valueForKey:@"token"], [[self currentFilter] nid]];
        req = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rpc/soap/jirasoapservice-v2", [d valueForKey:@"jiraURL"]]]];
        [req retain];
        [req setRequestMethod:@"POST"];
        [req addRequestHeader:@"Host" value:[[d valueForKey:@"jiraURL"] substringFromIndex:7]];
        [req addRequestHeader:@"SOAPAction" value:@""];
        [req addRequestHeader:@"Content-Type" value:@"text/xml"];
        //POSSIBLE BUGFIX
        [req setValidatesSecureCertificate:NO];
        [req setShouldStreamPostDataFromDisk:YES];
        [req appendPostData:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
        [req setDelegate:self];
        
    }
    return self;
}

-(void) fetchIssues{
    NSLog(@"Fetching filter with nid %@", [[self currentFilter] nid]);
    JiraBuddy_AppDelegate *del = [[NSApplication sharedApplication] delegate] ;
    [del log:[NSString stringWithFormat:@"Fetching filter with nid %@", [[self currentFilter] nid]]];
    [req startAsynchronous];
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSLog(@"--Request finished successfully for filter %@ with IF %@", [[self currentFilter] nid], self);
    JiraBuddy_AppDelegate *del = [[NSApplication sharedApplication] delegate] ;
    [del log:[NSString stringWithFormat:@"Filter fetch succeeded for filter %@", [[self currentFilter] nid]]];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[request responseData]];
    [parser setDelegate:self];
    [parser parse];
    [parser release];
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    NSLog(@"Error in request for filter %@: %@", [currentFilter nid], [error description]);
    JiraBuddy_AppDelegate *del = [[NSApplication sharedApplication] delegate] ;
    [del log:[NSString stringWithFormat:@"Error in request for filter %@: %@", [currentFilter nid], [error description]]];
    [self setSyncStatus:[NSNumber numberWithInt:ERROR]];
}


-(void)deleteEntitiesNotInArray:(NSMutableArray *)objectsToKeep{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Issue" inManagedObjectContext:moc];
    [request setEntity:entity]; 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((self in %@) AND NOT (self IN %@))", [currentFilter valueForKey:@"issues"],objectsToKeep];
    [request setPredicate:predicate];

    NSError *error = nil;
    NSArray *result = [moc executeFetchRequest:request error:&error];
    if ((result != nil) && ([result count] > 0) && (error == nil)){
        NSLog(@"Deleting %d issues", [result count]);
        resolvedIssues = [result count];    
        for(int i=0;i<[result count]; i++){
            NSManagedObject *ret = [result objectAtIndex:i];
            [moc deleteObject:ret];
        }
        
    }else {
        NSLog(@"Nothing to delete for Issue");
        if (error){ NSLog(@"Error in delete entries: %@", error); }
    }
    [request release];
}

#pragma mark Core Data 
-(NSManagedObject *)findEntity:(NSString *)entityName byNid:(NSNumber *)value{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    [request setEntity:entity]; 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nid == %d", [value intValue]];
    //NSLog(@"Predicate: %@", predicate);
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


#pragma mark XML parsing methods
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    //the parser started this document. what are you going to do?
    NSLog(@"Started parsing");
}


-(void) updateIssue:(Issue *)o fromDictionary:(NSDictionary *)dict{
    for (id key in dict) {
        if ([key isEqual:@"priority"]) {
            Priority *newPriority = (Priority *)[self findEntity:@"Priority" byNid:[dict valueForKey:key]];
            //NSLog(@"Assigning priority %@ from nid %@", newPriority, [dict valueForKey:key]);
            [o setPriority:newPriority];
        }
        else if ([key isEqual:@"id"]){
            [o setValue:[NSNumber numberWithInt:[[dict objectForKey:key] intValue]] forKey:@"nid"];
        }else if([key isEqual:@"status"] || [key isEqual:@"type"] || [key isEqual:@"votes"]) {
            [o setValue:[NSNumber numberWithInt:[[dict objectForKey:key] intValue]] forKey:key];
            
        }else if ([key isEqual:@"updated"] || [key isEqual:@"created"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
            NSDate *curr = [formatter dateFromString:[dict objectForKey:key]];
            [formatter release];
            if ([key isEqual:@"updated"]) {
                if ([o updated] && ![curr isEqual:[o updated]]) {
                    updatedIssues++;
                }
            }
            [o setValue:curr forKey:key];
        }
        else if ([key isEqual:@"summary"] || [key isEqual:@"assignee"] || [key isEqual:@"key"]){
            [o setValue:[dict objectForKey:key] forKey:key];                
        }
    }   
    [o addFiltersObject:currentFilter];
    
    [syncedIssues addObject:o];
}



- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"faultstring"]){
        [self setSyncStatus:[NSNumber numberWithInt:ERROR]];
        NSLog(@"ERROR: %@", [currentObjectDictionary valueForKey:@"faultstring"]);
        JiraBuddy_AppDelegate *del = [[NSApplication sharedApplication] delegate] ;
        [del log:[NSString stringWithFormat:@"ERROR: %@", [currentObjectDictionary valueForKey:@"faultstring"]]];
    }
    if (![elementName isEqualToString:@"multiRef"]){ return; }
    if (![currentObjectDictionary valueForKey:@"id"]){ return; }
    if ([currentObjectDictionary count] < 4 ){ return; }
    Issue *resultingIssue = (Issue *)[self findEntity:@"Issue" byNid:[currentObjectDictionary valueForKey:@"id"]];
    if (!resultingIssue){
        newIssues++;
        resultingIssue = [NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:moc];
    }
    [self updateIssue:resultingIssue fromDictionary:currentObjectDictionary];
    
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    //the parser found an XML tag and is giving you some information about it
    //what are you going to do?
    if ([elementName isEqualToString:@"multiRef"]) {
        [currentObjectDictionary removeAllObjects];
    }

    [self setCurrentElement:elementName];
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //the parser found some characters inbetween an opening and closing tag
    //what are you going to do?

    if ([currentObjectDictionary valueForKey:currentElement]){
        [currentObjectDictionary setValue:[[currentObjectDictionary valueForKey:currentElement] stringByAppendingString:string] forKey:currentElement];
    }else {
        [currentObjectDictionary setValue:string forKey:currentElement];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Finished parsing filter with id %@", [currentFilter nid]);
    if ([[self syncStatus] isEqualToNumber:[NSNumber numberWithInt:ERROR]]){
        
    }else{
        NSLog(@"Deleting obsoleted issues for filter %@", [currentFilter nid]);
        [self deleteEntitiesNotInArray:syncedIssues];
        if (resolvedIssues > 0 || newIssues > 0 || updatedIssues > 0) {
            NSMutableArray *notificationStrings = [[NSMutableArray alloc] init];
            if (newIssues > 0){
                [notificationStrings addObject:[NSString stringWithFormat:@"%d new", newIssues]];
            }
            if (updatedIssues > 0) {
                [notificationStrings addObject:[NSString stringWithFormat:@"%d updated", updatedIssues]];
            }
            if (resolvedIssues > 0) {
                [notificationStrings addObject:[NSString stringWithFormat:@"%d resolved", resolvedIssues]];
            }
            NSString *descriptionString;
            if ([notificationStrings count] == 1) {
                descriptionString = [notificationStrings objectAtIndex:0];
            }
            else if ([notificationStrings count] == 2) {
                descriptionString = [notificationStrings componentsJoinedByString:@" and "];
            }else if ([notificationStrings count] == 3){
                [notificationStrings replaceObjectAtIndex:2 withObject:[@"and " stringByAppendingString:[notificationStrings objectAtIndex:2]]];
                descriptionString = [notificationStrings componentsJoinedByString:@", "];
            }
            descriptionString = [descriptionString stringByAppendingString:@" issues."];
            [GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"%@ Updated", [currentFilter name]]
                                        description:descriptionString
                                   notificationName:@"Example"
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil];
            [notificationStrings release];
        }
        [self setSyncStatus:[NSNumber numberWithInt: DONE]];  
    }
}

-(void)dealloc{
    [syncedIssues release];
    [currentElement release];
    [super dealloc];
}

@end
