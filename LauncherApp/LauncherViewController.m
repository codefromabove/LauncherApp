//
//  LauncherViewController.m
//  LauncherApp
//
//  Created by Philip Schneider on 1/10/15.
//  Copyright (c) 2015 Code From Above, LLC. All rights reserved.
//

#import "LauncherViewController.h"

@interface LauncherViewController ()
@property (weak) IBOutlet NSTextField *appOutlet;

@end

@implementation LauncherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
}


- (IBAction)browseAction:(id)sender
{
    NSOpenPanel *openDialog = [NSOpenPanel openPanel];

    [openDialog setCanChooseFiles:YES];
    [openDialog setCanChooseDirectories:NO];
    [openDialog setAllowsMultipleSelection:NO];
    [openDialog setDirectoryURL:[NSURL URLWithString:@"/Applications"]];
    [openDialog setAllowedFileTypes:[NSArray arrayWithObjects:@"app", nil]];

    if ([openDialog runModal] == NSOKButton)
    {
        NSArray  *urls           = [openDialog URLs];
        NSString *path           = [urls objectAtIndex:0];
        NSArray  *pathComponents = [path pathComponents];
        NSString *appName        = [pathComponents lastObject];

        [[self appOutlet] setStringValue:[appName stringByDeletingPathExtension]];
    }
}

- (void)launchApp:(NSString *)app
{
    if (app)
    {
        NSString *scriptCode  = [NSString stringWithFormat:@"tell application \\\"%@\\\" to run", app];
        NSString *commandLine = [NSString stringWithFormat:@"osascript -e \"%@\"", scriptCode];

        int result = system([commandLine UTF8String]);

        scriptCode  = [NSString stringWithFormat:@"tell application \\\"%@\\\" to activate", app];
        commandLine = [NSString stringWithFormat:@"osascript -e \"%@\"", scriptCode];

        result = system([commandLine UTF8String]);
    }
}

- (IBAction)launchAction:(id)sender
{
    [self launchApp:[[self appOutlet] stringValue]];
}

@end
