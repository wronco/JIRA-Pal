//
//  SimpleFetcher.m
//  JiraPal
//
//  Created by Will Ronco on 1/14/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import "SimpleFetcher.h"


@implementation SimpleFetcher
@synthesize syncStatus, currentElement, currentObjectDictionary, moc, currentFilter, syncedIssues, dataForPostBody, newIssues, updatedIssues, resolvedIssues, requestBody;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context andFilter:(Filter *)f{
    if (self = [super init]) {
//        currentObjectDictionary = [[[NSMutableDictionary alloc] initWithCapacity:10] retain];
//        syncedIssues = [[[NSMutableArray alloc] init] retain];
//        newIssues = 0;
//        updatedIssues = 0;
//        resolvedIssues = 0;  
        [self setMoc:context];
        [self setCurrentFilter:f];
       // [self setSyncStatus:[NSNumber numberWithInt:0]];
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        
        NSString *path = [[NSBundle mainBundle] pathForResource: @"getIssues" ofType: @"txt"];   
        NSError *err = nil;
        NSString *shell = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        NSLog(@"MOC: %@",[self moc]);
        if (err){
            NSLog(@"Error: %@",[err description]);
        }else {
            
        }
        NSLog(@"%@",[NSString stringWithFormat:shell, [d valueForKey:@"jiraURL"], [d valueForKey:@"token"], [[self currentFilter] nid]]);
        [self setRequestBody:[NSString stringWithFormat:shell, [d valueForKey:@"jiraURL"], [d valueForKey:@"token"], [[self currentFilter] nid]]];

    }
    return self;
}

-(void)startFetch{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[d valueForKey:@"jiraURL"]]];
    //POSSIBLE BUGFIX
    [req setValidatesSecureCertificate:NO];
    [req setRequestMethod:@"POST"];
	[req addRequestHeader:@"Host" value:[[d valueForKey:@"jiraURL"] substringFromIndex:7]];
	[req addRequestHeader:@"SOAPAction" value:@""];
	[req addRequestHeader:@"Content-Type" value:@"text/xml"];
    [req setPostBody:(NSMutableData *)[[self requestBody] dataUsingEncoding:NSUTF8StringEncoding]];

    [req setDelegate:self];
    NSLog(@"--Starting asynchronous request for filter %@", [[self currentFilter] nid]);

    [req startSynchronous];
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSLog(@"--Simple Fetcher finished successfully");

}

- (void)requestFailed:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    NSLog(@"Simple Fetcher failed: %@", [error description]);

}
@end
