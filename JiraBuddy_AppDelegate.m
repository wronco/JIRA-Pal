//
//  JiraBuddy_AppDelegate.m
//  JiraBuddy
//
//  Created by Will Ronco on 1/6/10.
//  Copyright Awesome Software 2010 . All rights reserved.
//

#import "JiraBuddy_AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "SimpleFetcher.h"
@implementation JiraBuddy_AppDelegate

@synthesize window, myPriorityFetcher, myFilterFetcher, myLoginManager, filtersReady, filtersCount, networkQueue, nextSync, issueFetchers, statusImage, statusMessage;


-(void) applicationDidFinishLaunching:(NSNotification *)notification{
    NSLog(@"USING ASIHTTPREQUEST: %@",ASIHTTPRequestVersion);
    NSLog(@"%@", [[NSApplication sharedApplication] delegate]);
    filtersReady = 0;
    filtersCount = 0;
    [GrowlApplicationBridge setGrowlDelegate:self];

    issueFetchers = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
    myLoginManager = [[[LoginManager alloc] init] retain];
    [myLoginManager addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [myLoginManager login:nil];
    
    [tableView setTarget:self];

    [tableView setDoubleAction:@selector(doubleClick:)];
}


-(IBAction)doubleClick:(id)sender{
    if ([tableView selectedRow] >= 0){
        NSManagedObject *mo = [issuesArrayController selection];
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        NSString *urlToOpen = [NSString stringWithFormat:@"%@/browse/%@",[d valueForKey:@"jiraURL"],[mo valueForKey:@"key"]];
        NSLog(@"Opening ticket at %@", urlToOpen);
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlToOpen]];
    }

    
}
/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "JiraPal" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"JiraPal"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                URL:url 
                                                options:nil 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {
    NSLog(@"SAVING");
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}

-(void) log:(NSString *)message{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *filepath = [[self applicationSupportDirectory] stringByAppendingPathComponent:@"log.txt"];
    if ( ![fileManager fileExistsAtPath:filepath isDirectory:NO] ) {
		[fileManager createFileAtPath:filepath contents:[@"JIRA Pal Logfile\n" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
    [fh seekToEndOfFile];
    [fh writeData:[[NSString stringWithFormat:@"%@: %@\n", [NSDate date], message] dataUsingEncoding:NSUTF8StringEncoding]];
    [fh closeFile];
}
#pragma mark User Prefs

- (IBAction)showPreferences: (id) sender{
    if (nextSync) {
        [nextSync invalidate];   
        nextSync = nil;
    }
    [myLoginManager setStatus:NOT_LOGGED];
    [NSApp beginSheet:myPreferences 
       modalForWindow:[self window] 
        modalDelegate:nil
       didEndSelector:NULL 
          contextInfo:NULL];
}
-(IBAction)savePreferences:(id)sender{
	[NSApp endSheet:myPreferences];
    
	[myPreferences orderOut:sender];
    [myLoginManager login:nil];
}


-(IBAction)showLogfile:(id)sender{
    NSString *filepath = [[self applicationSupportDirectory] stringByAppendingPathComponent:@"log.txt"];

    [[NSWorkspace sharedWorkspace] openFile:filepath];
}
#pragma mark KVO 
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        NSLog(@"Login manager status did update");
        if ([[myLoginManager status] isEqualToNumber:[NSNumber numberWithInt:LOGGED_IN]]) {
            [self.statusImage setImage:[NSImage imageNamed:@"success.png"]];
            [self.statusMessage setStringValue:@"Logged in successfully"];
            [spinner startAnimation:nil];
            myPriorityFetcher = [[[EntityFetcher alloc] initWithManagedObjectContext:[self managedObjectContext] name:@"Priority"] retain];
            [myPriorityFetcher addObserver:self forKeyPath:@"syncStatus" options:NSKeyValueObservingOptionNew context:nil];
            
            myFilterFetcher = [[[EntityFetcher alloc] initWithManagedObjectContext:[self managedObjectContext] name:@"Filter"] retain];
            [myFilterFetcher addObserver:self forKeyPath:@"syncStatus" options:NSKeyValueObservingOptionNew context:nil];
            
            [myFilterFetcher startFetch:nil];
            [myPriorityFetcher startFetch:nil];
            
        }else if ([[myLoginManager status] isEqualToNumber:[NSNumber numberWithInt:LOGIN_ERROR]]) {
            [self.statusImage setImage:[NSImage imageNamed:@"error.png"]];
            [self.statusMessage setStringValue:@"Could not log in with that username and password"];
            [self showPreferences:nil];
        }
    }
    else if ([keyPath isEqualToString:@"syncStatus"] && [object isKindOfClass:[IssueFetcher class]]){
        NSLog(@"Issue Fetcher updated status");
        if ([[object syncStatus] isEqualToNumber:[NSNumber numberWithInt:DONE]] || 
            [[object syncStatus] isEqualToNumber:[NSNumber numberWithInt:ERROR]]) {

            if ([[object syncStatus] isEqualToNumber:[NSNumber numberWithInt:ERROR]]){
                NSLog(@"Login error in issue fetch");
                [myLoginManager setStatus:NOT_LOGGED];
                [self.statusImage setImage:[NSImage imageNamed:@"error.png"]];
                [self.statusMessage setStringValue:@"Login token expired, reauthenticating."];
            }
            

            filtersReady++;
            NSLog(@"%d of %d filters DONE", filtersReady, filtersCount);

            [object removeObserver:self forKeyPath:@"syncStatus"];
            [issueFetchers removeObjectForKey:[[object currentFilter] nid]];
            //[object release];
            if (filtersReady == filtersCount) {
                [spinner stopAnimation:nil];
                NSLog(@"Scheduling timer");
                [self saveAction:nil];
                if ([[myLoginManager status] isEqualToNumber:[NSNumber numberWithInt:ERROR]]) {
                    [myLoginManager login:nil];
                    [self.statusImage setImage:[NSImage imageNamed:@"error.png"]];
                    [self.statusMessage setStringValue:@"Login token expired, reauthenticating."];
                }else {
                    nextSync = [NSTimer scheduledTimerWithTimeInterval:120.0 target:self selector:@selector(syncIssues:) userInfo:nil repeats:NO];
                    [self.statusImage setImage:[NSImage imageNamed:@"success.png"]];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
                    [formatter setDateStyle:NSDateFormatterNoStyle];
                    [formatter setTimeStyle:NSDateFormatterShortStyle];
                    [self.statusMessage setStringValue:[NSString stringWithFormat:@"Last sync: %@", [formatter stringForObjectValue:[NSDate date]]]];
                    [formatter release];
                }
                filtersReady = 0;
            }
        }
        
    }else if ([keyPath isEqualToString:@"syncStatus"] && 
              ([object isEqual:myFilterFetcher] || [object isEqual:myPriorityFetcher])){
        NSLog(@"Priority Fetcher (%@) and Filter Fetcher (%@)", [myPriorityFetcher syncStatus], [myFilterFetcher syncStatus]);
        if ([[myFilterFetcher syncStatus] isEqualToNumber:[NSNumber numberWithInt:DONE]] && 
            [[myPriorityFetcher syncStatus] isEqualToNumber:[NSNumber numberWithInt:DONE]]) {
            NSLog(@"Priority Fetcher (%@) and Filter Fetcher (%@) ready", [myPriorityFetcher syncStatus], [myFilterFetcher syncStatus]);
            NSLog(@"Starting FIRST issue sync");
            [myPriorityFetcher removeObserver:self forKeyPath:@"syncStatus"];
            [myFilterFetcher removeObserver:self forKeyPath:@"syncStatus"];
            [myPriorityFetcher release];
            [myFilterFetcher release];
            [self saveAction:nil];
            [self syncIssues:nil];
        }
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSLog(@"request finished");
}
- (void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"%@", [[request error] description]); 
    
}
-(void) syncIssues:(id)sender{

    [spinner startAnimation:nil]; 
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Filter" inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];        
    NSError *error = nil;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:&error];
    NSLog(@"SYNCING ISSUES FROM %d FILTERS", [result count]);
    filtersCount = [result count];
    if (filtersCount == 0){
        NSAlert *noFilters = [NSAlert alertWithMessageText:@"No filters!"   defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"JIRA Pal can only fetch issues that are associated with filters.  Please create a filter in JIRA before continuing."];
        [noFilters beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
    }else{
        for(int i=0;i<filtersCount;i++){            
            NSLog(@"Creating issue fetcher # %d of %d", i+1, filtersCount);
            IssueFetcher *currIssueFetcher = [[IssueFetcher alloc] initWithManagedObjectContext:[self managedObjectContext] andFilter:[result objectAtIndex:i]];
            [currIssueFetcher addObserver:self forKeyPath:@"syncStatus" options:NSKeyValueObservingOptionNew context:nil];
            [currIssueFetcher fetchIssues];
            [issueFetchers setObject:currIssueFetcher forKey:[[result objectAtIndex:i] nid]];
        }
        NSLog(@"Initialized %d issue fetchers",[result count]);
    }
    [request release];
    NSLog(@"Checking filterscount: %d", filtersCount);
}
/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
    [super dealloc];
}


@end
