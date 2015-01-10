//
//  AppDelegate.m
//  LauncherApp
//
//  Created by Philip Schneider on 1/10/15.
//  Copyright (c) 2015 Code From Above, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "LauncherViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet LauncherViewController *launcherViewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.launcherViewController = [[LauncherViewController alloc] initWithNibName:@"LauncherViewController"
                                                                           bundle:nil];

    [self.window.contentView addSubview:self.launcherViewController.view];
    self.launcherViewController.view.frame = ((NSView*)self.window.contentView).bounds;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)testButton:(id)sender {
}
@end
