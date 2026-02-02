//
//  AppDelegate.m
//  LookupLeoDict
//
//  Created by vad on 11/6/18.
//  Copyright © 2018 vaddieg. All rights reserved.
//

#import "AppDelegate.h"

static NSString * const kTargetLangDefaultsKey = @"TargetLanguage";
static NSString * const kSourceLangDefaultsKey = @"SourceLanguage";
static NSString * const kEngineDefaultsKey = @"SentenceTraslationEngine";

@interface SimpleDictOpener : NSObject
@end

@implementation SimpleDictOpener

+ (NSArray *)optionsList {
    return @[@"🇬🇧 English",@"🇩🇪 Deutsch", @"🇫🇷 Français" ,@"🇧🇬 Русский", @"🇪🇸 Español", @"🇺🇦 Українська"];
}

+ (NSArray *)enginesList {
    return @[@"DeepL", @"Google"];
}

+ (NSArray *)lleoOptions {
    return @[@"englisch", @"deutsch", @"französisch" ,@"russisch", @"spanisch", @"russisch"];
}

+ (NSArray *)gtOptions {
    return @[@"en", @"de", @"fr" ,@"ru", @"es", @"uk"];
}

- (void)lookupWord:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
    
    NSArray *classes = [NSArray arrayWithObject:[NSString class]];
    
    if (![pboard canReadObjectForClasses:classes options:@{}]) {
        *error = NSLocalizedString(@"Error: can't lookup.",
                                   @"Pasteboard should give a string");
        return;
    }
    
    NSString *pboardString = [pboard stringForType:NSPasteboardTypeString];
    NSInteger srcOpt = [[NSUserDefaults standardUserDefaults] integerForKey:kSourceLangDefaultsKey];
    NSInteger targOpt = [[NSUserDefaults standardUserDefaults] integerForKey:kTargetLangDefaultsKey];
    NSInteger engine = [[NSUserDefaults standardUserDefaults] integerForKey:kEngineDefaultsKey];
    
    NSString *lookup = [pboardString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    
    NSString *requestStr = nil;
    if ([pboardString componentsSeparatedByString:@" "].count > 2) {
        
        // Looks like a sentence, use google or deepL
        NSString *fmt = @[@"https://www.deepl.com/translator#%@/%@/%@",
                          @"https://translate.google.com/#%@/%@/%@"][engine];
        
        
        requestStr = [NSString stringWithFormat:fmt, [SimpleDictOpener gtOptions][srcOpt], [SimpleDictOpener gtOptions][targOpt], lookup];
    } else {
        // Use leo (it handles 2 words sometimes)
        requestStr = [NSString stringWithFormat:@"https://dict.leo.org/%@-%@/%@",[SimpleDictOpener lleoOptions][srcOpt], [SimpleDictOpener lleoOptions][targOpt] ,lookup];
    }
    
    if (![[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:requestStr]]) {
        NSLog(@"Can't open URL %@", requestStr);
    }
    [NSApp terminate:nil];
}

@end


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *sourceLangPopup;
@property (weak) IBOutlet NSPopUpButton *targetLangPopup;
@property (weak) IBOutlet NSPopUpButton *enginePopup;

@end

@implementation AppDelegate

- (IBAction)didChangeSourceLanguage:(NSPopUpButton *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.indexOfSelectedItem forKey:kSourceLangDefaultsKey];
}


- (IBAction)didChangeTargetLanguage:(NSPopUpButton *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.indexOfSelectedItem forKey:kTargetLangDefaultsKey];
}

- (IBAction)didChangeEngine:(NSPopUpButton *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.indexOfSelectedItem forKey:kEngineDefaultsKey];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)validatePreferences {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    //translate from DE by default
    if (![defs objectForKey:kSourceLangDefaultsKey]) {
        [defs setInteger:1 forKey:kSourceLangDefaultsKey];
    }
    
    
    NSInteger targSelection = [defs integerForKey:kTargetLangDefaultsKey];
    if (targSelection >= [SimpleDictOpener optionsList].count) {
        // reset invalid settings
        [defs removeObjectForKey:kTargetLangDefaultsKey];
    }
    
    NSInteger srcSelection = [defs integerForKey:kSourceLangDefaultsKey];
    if (srcSelection >= [SimpleDictOpener optionsList].count) {
        // reset invalid settings
        [defs removeObjectForKey:kSourceLangDefaultsKey];
    }
}

- (void)showSettingsWindow {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    
    [self.sourceLangPopup removeAllItems];
    NSInteger srcSelection = [defs integerForKey:kSourceLangDefaultsKey];
    
    for (NSString *option in [SimpleDictOpener optionsList]) {
        [self.sourceLangPopup addItemWithTitle:option];
    }
    [self.sourceLangPopup selectItemAtIndex:srcSelection];
    
    
    [self.targetLangPopup removeAllItems];
    NSInteger targSelection = [defs integerForKey:kTargetLangDefaultsKey];
    
    for (NSString *option in [SimpleDictOpener optionsList]) {
        [self.targetLangPopup addItemWithTitle:option];
    }
    [self.targetLangPopup selectItemAtIndex:targSelection];
    
    [self.enginePopup removeAllItems];
    NSInteger engSelection = [defs integerForKey:kEngineDefaultsKey];
    
    for (NSString *option in [SimpleDictOpener enginesList]) {
        [self.enginePopup addItemWithTitle:option];
    }
    [self.enginePopup selectItemAtIndex:engSelection];
    
    [self.window makeKeyAndOrderFront:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self validatePreferences];
    
    SimpleDictOpener *serviceProvider = [SimpleDictOpener new];
    [NSApp setServicesProvider:serviceProvider];
    
    // Settings should be shown only w/ standalone launch
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showSettingsWindow];
    });
    
    
}


@end
