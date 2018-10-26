#define prefPath [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(),@"se.nosskirneh.autodismisssiri.plist"]

static BOOL enabled;
static long long duration;
static long long lockscreenDuration;

static void reloadPrefs() {
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:prefPath];
    enabled = defaults[@"enabled"] ? [defaults[@"enabled"] boolValue] : YES;
    duration = defaults[@"duration"] ? [defaults[@"duration"] integerValue] : 5;
    lockscreenDuration = defaults[@"lockscreenDuration"] ? [defaults[@"lockscreenDuration"] integerValue] : 5;
}

void updateSettings(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    reloadPrefs();
}


@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isUILocked;
@end

@interface ACSpringBoardPluginController : NSObject
- (void)_requestDismissal;
@end

%group Assistant
%hook ACSpringBoardPluginController

- (void)siriViewController:(id)arg1 siriIdleAndQuietStatusDidChange:(BOOL)idle {
    %orig;

    if (!enabled)
        return;

    static NSTimer *timer;
    if (idle) {
        SBLockScreenManager *lockscreenManager = [%c(SBLockScreenManager) sharedInstance];
        float d = lockscreenManager.isUILocked ? lockscreenDuration : duration;
        if (d == 0)
            return;

        timer = [NSTimer scheduledTimerWithTimeInterval:d
                                                 target:self
                                               selector:@selector(dismiss:)
                                               userInfo:nil
                                                repeats:NO];
    }
    else if (timer)
        [timer invalidate];

}

%new
- (void)dismiss:(NSTimer *)timer {
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
