//
//  JiraBuddy_AppDelegate.h
//  JiraBuddy
//
//  Created by Will Ronco on 1/6/10.
//  Copyright Awesome Software 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "IssueFetcher.h"
#import "EntityFetcher.h"
#import "LoginManager.h"
#import "ASINetworkQueue.h"

@interface JiraBuddy_AppDelegate : NSObject <GrowlApplicationBridgeDelegate>
{
    NSWindow *window;
    IBOutlet NSWindow *myPreferences;
    IBOutlet NSPopUpButton *filterSwitcher;
    
    IBOutlet NSProgressIndicator *spinner;
    IBOutlet NSTableView *tableView;
    
    EntityFetcher *myPriorityFetcher;
    EntityFetcher *myFilterFetcher;
    LoginManager *myLoginManager;
    ASINetworkQueue *networkQueue;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    
    IBOutlet NSArrayController *issuesArrayController;
    NSMutableDictionary *issueFetchers;
    int filtersReady;
    int filtersCount;
    NSTimer *nextSync;
    
    IBOutlet NSImageView *statusImage;
    IBOutlet NSTextField *statusMessage;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (nonatomic, retain) NSMutableDictionary *issueFetchers;

@property (nonatomic, retain) EntityFetcher *myPriorityFetcher;
@property (nonatomic, retain) EntityFetcher *myFilterFetcher;

@property (nonatomic, retain) IBOutlet LoginManager *myLoginManager;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property int filtersReady;
@property int filtersCount;

@property (nonatomic, retain) NSTimer *nextSync;

@property (nonatomic, retain) IBOutlet NSImageView *statusImage;
@property (nonatomic, retain) IBOutlet NSTextField *statusMessage;

- (IBAction)saveAction:sender;
- (IBAction)showPreferences:(id)sender;
- (IBAction)savePreferences:(id)sender;
- (IBAction)showLogfile:(id)sender;
- (void) trialPopupDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (void) syncIssues:(id)sender;
- (void) log:(NSString *)message;

@end
