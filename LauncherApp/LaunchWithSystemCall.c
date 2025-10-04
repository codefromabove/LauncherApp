//
//  LaunchWithSystemCall.cpp
//  LauncherApp
//
//  Created by Philip Schneider on 1/10/15.
//  Copyright (c) 2015 Code From Above, LLC. All rights reserved.
//

#include "LaunchWithSystemCall.h"
#include <stdlib.h>

void launchWithSystemCall(const char * const app)
{
    if (!app)
        return;

    char scriptCode[256];
    sprintf(scriptCode, "tell application \\\"%s\\\" to run\n\
                         tell application \\\"%s\\\" to activate",
            app, app);

    char commandLine[256];
    sprintf(commandLine, "osascript -e \"%s\"", scriptCode);

    int result = system(commandLine);
    printf("result: %d", result);
}
