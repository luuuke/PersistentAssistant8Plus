#line 1 "/Users/ng/Dropbox/PersistentAssistant8/PersistentAssistant8/PersistentAssistant8.xm"
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

#include <logos/logos.h>
#include <substrate.h>
@class SBAssistantController; @class AFUISiriViewController; @class AFUISpeechSynthesis; 
static void (*_logos_orig$_ungrouped$AFUISiriViewController$dismissSiriRemoteViewController$)(AFUISiriViewController*, SEL, id); static void _logos_method$_ungrouped$AFUISiriViewController$dismissSiriRemoteViewController$(AFUISiriViewController*, SEL, id); static void (*_logos_orig$_ungrouped$AFUISpeechSynthesis$speechSynthesizer$didFinishSpeakingRequest$successfully$withError$)(AFUISpeechSynthesis*, SEL, id, id, BOOL, id); static void _logos_method$_ungrouped$AFUISpeechSynthesis$speechSynthesizer$didFinishSpeakingRequest$successfully$withError$(AFUISpeechSynthesis*, SEL, id, id, BOOL, id); 
static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBAssistantController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBAssistantController"); } return _klass; }
#line 44 "/Users/ng/Dropbox/PersistentAssistant8/PersistentAssistant8/PersistentAssistant8.xm"


static void _logos_method$_ungrouped$AFUISiriViewController$dismissSiriRemoteViewController$(AFUISiriViewController* self, SEL _cmd, id arg1){
	_logos_orig$_ungrouped$AFUISiriViewController$dismissSiriRemoteViewController$(self, _cmd, arg1);
	LWLog(@"(%f) -[AFUISiriViewController dismissSiriRemoteViewController:]", CFAbsoluteTimeGetCurrent());
	if(_enabled) _siriWillDismiss=YES;
}





static void _logos_method$_ungrouped$AFUISpeechSynthesis$speechSynthesizer$didFinishSpeakingRequest$successfully$withError$(AFUISpeechSynthesis* self, SEL _cmd, id arg1, id arg2, BOOL arg3, id arg4){
	_logos_orig$_ungrouped$AFUISpeechSynthesis$speechSynthesizer$didFinishSpeakingRequest$successfully$withError$(self, _cmd, arg1, arg2, arg3, arg4);
	LWLog(@"(%f) -[AFUISpeechSynthesis didFinishSpeakingRequest:successfully:withError:]", CFAbsoluteTimeGetCurrent());
	if(_enabled){
		
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			if(!_siriWillDismiss){
				AFUISiriViewController* siriController=MSHookIvar<AFUISiriViewController*>([_logos_static_class_lookup$SBAssistantController() sharedInstance], "_mainScreenViewController");
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



#pragma mark - Constructor

static __attribute__((constructor)) void _logosLocalCtor_edc80979(){
	LWLog(@"is in the hood");
	if(dlopen("/System/Library/PrivateFrameworks/AssistantUI.framework/AssistantUI", RTLD_LAZY)){
		LWLog(@"dlopened AssistantUI.framework lazily");
	}
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("de.ng.PersistentAssistant8.settingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadSettings();
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$AFUISiriViewController = objc_getClass("AFUISiriViewController"); MSHookMessageEx(_logos_class$_ungrouped$AFUISiriViewController, @selector(dismissSiriRemoteViewController:), (IMP)&_logos_method$_ungrouped$AFUISiriViewController$dismissSiriRemoteViewController$, (IMP*)&_logos_orig$_ungrouped$AFUISiriViewController$dismissSiriRemoteViewController$);Class _logos_class$_ungrouped$AFUISpeechSynthesis = objc_getClass("AFUISpeechSynthesis"); MSHookMessageEx(_logos_class$_ungrouped$AFUISpeechSynthesis, @selector(speechSynthesizer:didFinishSpeakingRequest:successfully:withError:), (IMP)&_logos_method$_ungrouped$AFUISpeechSynthesis$speechSynthesizer$didFinishSpeakingRequest$successfully$withError$, (IMP*)&_logos_orig$_ungrouped$AFUISpeechSynthesis$speechSynthesizer$didFinishSpeakingRequest$successfully$withError$);} }
#line 91 "/Users/ng/Dropbox/PersistentAssistant8/PersistentAssistant8/PersistentAssistant8.xm"
