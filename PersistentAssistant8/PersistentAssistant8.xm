#import <UIKit/UIKit.h>

#pragma mark - Interfaces

@interface AFUISiriViewController : UIViewController
-(void)siriViewDidReceiveStartSpeechRequestAction:(id)arg1;
-(void)dismissSiriRemoteViewController:(id)arg1;
-(BOOL)isListening;
@end

@interface SBAssistantController : NSObject{
	UIViewController* _mainScreenViewController;
}
+(instancetype)sharedInstance;
@end

@interface AFUISpeechSynthesis : NSObject
-(void)speechSynthesizer:(id)arg1 didFinishSpeakingRequest:(id)arg2 successfully:(BOOL)arg3 withError:(id)arg4;
-(BOOL)isSpeaking;
@end

#pragma mark - Variables

static BOOL _enabled=YES;
static BOOL _siriWillDismiss=NO;

#pragma mark - Functions

static void loadSettings(){
	NSDictionary* settings=(NSDictionary *)CFPreferencesCopyMultiple(CFPreferencesCopyKeyList(CFSTR("de.ng.PersistentAssistant8"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost), CFSTR("de.ng.PersistentAssistant8"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	id temp=[settings objectForKey:@"enabled"];
	_enabled=temp ? [temp boolValue] : YES;
	[settings release];
	[temp release];
	LWLog(@"loaded settings: enabled=%i", _enabled);
}

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	loadSettings();
}

#pragma mark - Hooks

%hook AFUISiriViewController

-(void)dismissSiriRemoteViewController:(id)arg1{
	%orig;
	LWLog(@"(%f) -[AFUISiriViewController dismissSiriRemoteViewController:]", CFAbsoluteTimeGetCurrent());
	if(_enabled) _siriWillDismiss=YES;
}

%end

%hook AFUISpeechSynthesis

-(void)speechSynthesizer:(id)arg1 didFinishSpeakingRequest:(id)arg2 successfully:(BOOL)arg3 withError:(id)arg4{
	%orig;
	LWLog(@"(%f) -[AFUISpeechSynthesis didFinishSpeakingRequest:successfully:withError:]", CFAbsoluteTimeGetCurrent());
	if(_enabled){
		//wait for a bit to check if Siri is dismissing
		//the difference is 100 ms between the finished utterance and the actual dismiss on an iPhone 5, the iPad Mini 2's one is about 80 ms. So we're waiting 300 ms just to be sure
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			if(!_siriWillDismiss){
				AFUISiriViewController* siriController=MSHookIvar<AFUISiriViewController*>([%c(SBAssistantController) sharedInstance], "_mainScreenViewController");
				if(![self isSpeaking] && ![siriController isListening]){
					[siriController siriViewDidReceiveStartSpeechRequestAction:nil];
					LWLog(@"Listening again");
				}else{
					LWLog(@"Not listening again: isSpeaking=%i, isListening=%i", [self isSpeaking], [siriController isListening]);
				}
			}else{
				LWLog(@"Siri dismisses, not listening again");
				_siriWillDismiss=NO;
			}
		});
	}
}

%end

#pragma mark - Constructor

%ctor{
	LWLog(@"is in the hood");
	if(dlopen("/System/Library/PrivateFrameworks/AssistantUI.framework/AssistantUI", RTLD_LAZY)){
		LWLog(@"dlopened AssistantUI.framework lazily");
	}
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("de.ng.PersistentAssistant8.settingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadSettings();
}