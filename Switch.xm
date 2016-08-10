#import <Flipswitch/FSSwitchDataSource.h>
#import <Flipswitch/FSSwitchPanel.h>
#import "../PS.h"

@interface BBSettingsGateway : NSObject
- (void)setBehaviorOverridesEffectiveWhileUnlocked:(BOOL)value;
- (void)getBehaviorOverridesEffectiveWhileUnlockedWithCompletion:(void (^)(int, int, int))completion;
@end

@interface QuietHoursStateController : NSObject
+ (QuietHoursStateController *)sharedController;
@property(nonatomic) BOOL isEffectiveWhileUnlocked;
- (BBSettingsGateway *)bbGateway;
@end

@interface DNDSOSwitch : NSObject <FSSwitchDataSource>
@end

@implementation DNDSOSwitch

- (NSBundle *)settingsBundle
{
	if (isiOS9Up)
		return [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/PreferencesUI.framework"];
	if (isiOS8Up)
		return [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/NotificationSettings.bundle"];
	return [NSBundle bundleWithPath:@"/Applications/Preferences.app"];
}

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier
{
	NSString *string = [self.settingsBundle localizedStringForKey:@"SILENCE" value:@"" table:isiOS9Up ? @"DoNotDisturb" : @"WYWAAppDetail"];
	NSString *title = [string substringToIndex:string.length - 1];
	return title;
}

- (NSString *)descriptionOfState:(FSSwitchState)state forSwitchIdentifier:(NSString *)switchIdentifier
{
	NSString *key = state == FSSwitchStateOn ? @"ALWAYS" : @"ONLY_LOCKED";
	if (state != FSSwitchStateOn)
		key = [UIDevice modelSpecificLocalizedStringKeyForKey:key];
	NSString *description = [self.settingsBundle localizedStringForKey:key value:@"" table:isiOS9Up ? @"DoNotDisturb" : @"WYWAAppDetail"];
	return description;
}

- (NSString *)plistPath
{
	return @"/var/mobile/Library/BulletinBoard/BehaviorOverrides.plist";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:self.plistPath];
	BOOL value = [plist[@"effectiveWhileUnlocked"] boolValue];
	return value ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
	if (newState == FSSwitchStateIndeterminate)
		return;
	BOOL value = newState == FSSwitchStateOn;
	QuietHoursStateController *qhs = QuietHoursStateController.sharedController;
	BBSettingsGateway *gateway = qhs.bbGateway;
	[gateway setBehaviorOverridesEffectiveWhileUnlocked:value];
	qhs.isEffectiveWhileUnlocked = value;
	NSMutableDictionary *plist = [NSMutableDictionary dictionary];
	[plist addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:self.plistPath]];
	if (plist) {
		plist[@"effectiveWhileUnlocked"] = @(value);
		[plist writeToFile:self.plistPath atomically:YES];
	}
}

@end