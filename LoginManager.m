//
//  LoginManager.m
//  JiraBuddy
//
//  Created by Will Ronco on 1/7/10.
//  Copyright 2010 Awesome Software. All rights reserved.
//

#import "LoginManager.h"


@implementation LoginManager
@synthesize currentElement, status;

-(id)init{
    if ((self = [super init])){
        status = [[NSNumber  numberWithInt:NOT_LOGGED] retain];
    }
    return self;
}

-(IBAction)login:(id)sender{
    NSLog(@"Logging in");
    [self setStatus:[NSNumber numberWithInt:LOGGING_IN]];

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];    
	NSString *path = [[NSBundle mainBundle] pathForResource: @"login" ofType: @"txt"];   
    NSString *shell = [NSString stringWithContentsOfFile:path encoding: NSUTF8StringEncoding error: NULL];
    NSString *body = [NSString stringWithFormat:shell, [d valueForKey:@"jiraURL"], [d valueForKey:@"username"], [d valueForKey:@"password"]];
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rpc/soap/jirasoapservice-v2", [d valueForKey:@"jiraURL"]]]];
	[req setRequestMethod: @"POST"];
	[req addRequestHeader:@"Host" value:[[d valueForKey:@"jiraURL"] substringFromIndex:7]];
	[req addRequestHeader:@"SOAPAction" value:@""];
	[req addRequestHeader:@"Content-Type" value:@"text/xml"];
    [req setValidatesSecureCertificate:NO];
    [req setUsername:[d valueForKey:@"username"]];
    [req setPassword:[d valueForKey:@"password"]];
    [req setPostBody:(NSMutableData *)[body dataUsingEncoding:NSUTF8StringEncoding]];
    [req startSynchronous];
    NSError *error = [req error];
    if (!error) {
        NSLog(@"%@", [req responseString]);
        NSXMLParser * parser = [[NSXMLParser alloc] initWithData:[req responseData]];
        [parser setDelegate:self];
        [parser parse];
        [parser release];
    }    
    else {
        NSLog(@"%@", [error description]);
        [[[NSApplication sharedApplication] delegate] log:[NSString stringWithFormat:@"Error in login request: %@", [error description]]];
    }      
}


#pragma mark XML parsing methods
- (void)parserDidStartDocument:(NSXMLParser *)parser {
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    [self setCurrentElement:elementName];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //the parser found some characters inbetween an opening and closing tag
    if ([currentElement isEqualToString:@"faultstring"]){
        [[[NSApplication sharedApplication] delegate] log:[NSString stringWithFormat:@"JIRA Server rejected login with current username and password"]];
        [self setStatus:[NSNumber numberWithInt:LOGIN_ERROR]];
        NSLog(@"Login failure");

    }
    else if ([currentElement isEqualToString:@"loginReturn"]){
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setValue:string forKey:@"token"];
        [d setValue:[NSDate date] forKey:@"tokenUpdated"];
        [self setStatus:[NSNumber numberWithInt:LOGGED_IN]];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

@end
