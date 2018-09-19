#define prefPath [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(),@"se.nosskirneh.autodismisssiri.plist"]

static BOOL enabled;
static long long duration;

static void reloadPrefs() {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefPath]];
    enabled = defaults[@"enabled"] ? [defaults[@"enabled"] boolValue] : YES;
    duration = defaults[@"duration"] ? [defaults[@"duration"] integerValue] : 5;
}

void updateSettings(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    reloadPrefs();
}


@interface ACSpringBoardPluginController : NSObject
- (void)_requestDismissal;
@end

%group Assistant
%hook ACSpringBoardPluginController

- (void)siriViewController:(id)arg1 siriIdleAndQuietStatusDidChange:(BOOL)idle {
    %log;
    %orig;

    if (!enabled)
        return;

    static NSTimer *timer;
    if (idle)
        timer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                 target:self
                                               selector:@selector(dismiss:)
                                               userInfo:nil
                                                repeats:NO];
    else if (timer)
        [timer invalidate];

}

%new
- (void)dismiss:(NSTimer *)timer {
    %log;
    [timer invalidate];
    [self _requestDismissal];
}

%end
%end

%hook SBAssistantController
- (void)_loadPlugin {
    %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        %init(Assistant);
    });
}
%end


%ctor {
    reloadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &updateSettings, CFSTR("se.nosskirneh.autodismisssiri/preferencesChanged"), NULL, 0);

    %init;
}
