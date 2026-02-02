//
//  AppDelegate.m
//  LookupLeoDict
//
//  Created by vad on 11/6/18.
//  Copyright © 2018 vaddieg. All rights reserved.
//

#import "AppDelegate.h"

static NSString * const kLangDefaultsKey = @"TargetLanguage";

@interface SimpleDictOpener : NSObject
@end

@implementation SimpleDictOpener

+ (NSArray *)optionsList {
    return @[@"🇬🇧 English", @"🇫🇷 Français" ,@"🇧🇬 Русский", @"🇪🇸 Español", @"🇺🇦 Українська"];
}

+ (NSArray *)lleoOptions {
    return @[@"englisch", @"französisch" ,@"russisch", @"spanisch", @"russisch"];
}

+ (NSArray *)gtOptions {
    return @[@"en", @"fr" ,@"ru", @"es", @"uk"];
}

- (void)lookupWord:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
    
    NSArray *classes = [NSArray arrayWithObject:[NSString class]];
    
    if (![pboard canReadObjectForClasses:classes options:@{}]) {
        *error = NSLocalizedString(@"Error: can't lookup.",
                                   @"Pasteboard should give a string");
        return;
    }
    
    NSString *pboardString = [pboard stringForType:NSPasteboardTypeString];
    NSInteger opt = [[NSUserDefaults standardUserDefaults] integerForKey:kLangDefaultsKey];
    
    NSString *lookup = [pboardString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    
    NSString *requestStr = nil;
    if ([pboardString componentsSeparatedByString:@" "].count > 1) {
        // Use google
        requestStr = [NSString stringWithFormat:@"https://translate.google.com/#de/%@/%@", [SimpleDictOpener gtOptions][opt], lookup];
    } else {
        // Use leo
        requestStr = [NSString stringWithFormat:@"https://dict.leo.org/%@-deutsch/%@",[SimpleDictOpener lleoOptions][opt] ,lookup];
    }
    
    if (![[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:requestStr]]) {
        NSLog(@"Can't open URL %@", requestStr);
    }
    [NSApp terminate:nil];
}

@end


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *targetLangPopup;

@end

@implementation AppDelegate

- (IBAction)didChangeLanguage:(NSPopUpButton *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.indexOfSelectedItem forKey:kLangDefaultsKey];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)validatePreferences {
    NSInteger selection = [[NSUserDefaults standardUserDefaults] integerForKey:kLangDefaultsKey];
    if (selection >= [SimpleDictOpener optionsList].count) {
        // reset invalid settings
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLangDefaultsKey];
    }
}

- (void)showSettingsWindow {
    [self.targetLangPopup removeAllItems];
    
    NSInteger selection = [[NSUserDefaults standardUserDefaults] integerForKey:kLangDefaultsKey];
    
    for (NSString *option in [SimpleDictOpener optionsList]) {
        [self.targetLangPopup addItemWithTitle:option];
    }
    
    [self.targetLangPopup selectItemAtIndex:selection];
    [self.window makeKeyAndOrderFront:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self validatePreferences];
    
    SimpleDictOpener *serviceProvider = [SimpleDictOpener new];
    [NSApp setServicesProvider:serviceProvider];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showSettingsWindow];
    });
    
    
}


@end
