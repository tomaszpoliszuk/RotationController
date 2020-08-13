NSString *domainString = @"com.tomaszpoliszuk.rotationcontroller";

NSMutableDictionary *tweakSettings;

static BOOL enableTweak;

static long long homeScreenRotationStyle;

void SettingsChanged() {
	NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];

	enableTweak = [( [tweakSettings objectForKey:@"enableTweak"] ?: @(YES) ) boolValue];

	homeScreenRotationStyle = [( [tweakSettings valueForKey:@"homeScreenRotationStyle"] ?: @(999) ) integerValue];
}

%hook SpringBoard
-(long long)homeScreenRotationStyle {
//	0 = iPhone (no rotation)
//	1 = iPad (rotate icons and dock)
//	2 = iPhone + (rotate icons, dock stays in place)
	long long origValue = %orig;
	if ( enableTweak && homeScreenRotationStyle != 999 ) {
		return homeScreenRotationStyle;
	} else {
		return origValue;
	}
}
- (bool)homeScreenSupportsRotation {
	bool origValue = %orig;
	if ( enableTweak && homeScreenRotationStyle != 0 ) {
		return YES;
	} else if ( enableTweak && homeScreenRotationStyle == 0 ) {
		return NO;
	} else {
		return origValue;
	}
}
%end

%ctor {
	SettingsChanged();
	CFNotificationCenterAddObserver( CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)SettingsChanged, CFSTR("com.tomaszpoliszuk.rotationcontroller.settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately );
	%init;
}
