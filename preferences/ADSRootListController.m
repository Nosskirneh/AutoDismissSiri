#import <Preferences/Preferences.h>

@interface ADSRootListController : PSListController
@end

#define prefPath [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"se.nosskirneh.autodismisssiri.plist"]
#define kTwitterID @"aNosskirneh"
#define kPresentedFollowAlert @"presented_follow"

@implementation ADSRootListController

- (void)setCellForRowAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled {
    UITableViewCell *cell = [self tableView:self.table cellForRowAtIndexPath:indexPath];
    if (cell) {
        cell.userInteractionEnabled = enabled;
        cell.textLabel.enabled = enabled;
        cell.detailTextLabel.enabled = enabled;
        
        if ([cell isKindOfClass:[PSControlTableCell class]]) {
            PSControlTableCell *controlCell = (PSControlTableCell *)cell;
            if (controlCell.control)
                controlCell.control.enabled = enabled;
        }
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:prefPath];

    NSString *key = [specifier propertyForKey:@"key"];
    if (!preferences[key])
        return specifier.properties[@"default"];
    
    if ([key isEqualToString:@"enabled"]) {
        BOOL enableCell = [[preferences objectForKey:key] boolValue];
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] enabled:enableCell];
    }

    return preferences[key];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];
    NSString *key = [specifier propertyForKey:@"key"];
    
    if ([key isEqualToString:@"enabled"])
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] enabled:[value boolValue]];

    [preferences setObject:value forKey:key];
    [preferences writeToFile:prefPath atomically:YES];
    CFStringRef post = (CFStringRef)CFBridgingRetain(specifier.properties[@"PostNotification"]);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), post, NULL, NULL, YES);
}

- (NSArray *)specifiers {
	if (!_specifiers)
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];

	return _specifiers;
}

- (void)loadView {
    [super loadView];
    [self presentFollowAlert];
}

- (void)presentFollowAlert {
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];

    if ([preferences[kPresentedFollowAlert] boolValue])
        return;

    if (!preferences)
        preferences = [NSMutableDictionary new];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hi"
                                                                   message:@"Thanks for installing! Would you like to follow me on Twitter to stay updated with my current and upcoming tweaks?"
                                                             preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Sure"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                        preferences[kPresentedFollowAlert] = @(YES);
                                        [preferences writeToFile:prefPath atomically:YES];

                                        [self openTwitter];
                                   }];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openTwitter {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:kTwitterID]]];
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:kTwitterID]]];
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:kTwitterID]]];
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:kTwitterID]]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"http://twitter.com/" stringByAppendingString:kTwitterID]]];
}

- (void)donate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/nosskirneh"]];
}

- (void)sendEmail {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:andreaskhenriksson@gmail.com?subject=AutoDismissSiri"]];
}

- (void)sourceCode {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Nosskirneh/AutoDismissSiri"]];
}

@end

@interface ADSHeaderCell : PSTableCell
@end

@implementation ADSHeaderCell {
    UILabel *_headerLabel;
    UILabel *_subheaderLabel;
}

- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
        
        _headerLabel = [[UILabel alloc] init];
        [_headerLabel setText:@"AutoDismissSiri"];
        [_headerLabel setTextColor:[UIColor blackColor]];
        [_headerLabel setFont:font];
        
        _subheaderLabel = [[UILabel alloc] init];
        [_subheaderLabel setText:@"by Andreas Henriksson"];
        _subheaderLabel.adjustsFontSizeToFitWidth = YES;
        _subheaderLabel.numberOfLines = 0;
        [_subheaderLabel setTextColor:[UIColor grayColor]];
        [_subheaderLabel setFont:[font fontWithSize:17]];
        
        [self addSubview:_headerLabel];
        [self addSubview:_subheaderLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_headerLabel sizeToFit];
    [_subheaderLabel sizeToFit];
    
    CGRect frame = _headerLabel.frame;
    frame.origin.y = 20;
    frame.origin.x = self.frame.size.width / 2 - _headerLabel.frame.size.width / 2;
    _headerLabel.frame = frame;
    
    frame.origin.y += _headerLabel.frame.size.height;
    frame.origin.x = self.frame.size.width / 2 - _subheaderLabel.frame.size.width / 2;
    _subheaderLabel.frame = frame;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    // Return a custom cell height.
    return 80;
}

@end

// Colorful UISwitches
@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface ADSSwitchTableCell : PSSwitchTableCell
@end

@implementation ADSSwitchTableCell

- (id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self)
        [((UISwitch *)[self control]) setOnTintColor:[UIColor colorWithRed:0.00 green:0.48 blue:1.00 alpha:1.0]];
    return self;
}

@end
