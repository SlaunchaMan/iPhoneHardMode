//
//  main.m
//  HardMode
//
//  Created by Jeff Kelley on 1/28/11.
//  Copyright 2011 Vectorform. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark -
#pragma mark Convenience Macros

#define JK_EasyCFString(X)	(CFStringCreateWithCString(kCFAllocatorDefault, (X), kCFStringEncodingASCII))

#pragma mark -
#pragma mark Function Declarations

void UIApplicationDelegate_ApplicationDidFinishLaunchingWithOptions(id self,
																	SEL _cmd,
																	UIApplication *application,
																	NSDictionary *launchOptions);

#pragma mark -

int main(int argc, char *argv[])
{
	// Some strings we’re going to need later. Don’t forget to release!
	CFStringRef NSObjectString = JK_EasyCFString("NSObject");
	CFStringRef UIApplicationDelegateString = JK_EasyCFString("UIApplicationDelegate");
	CFStringRef appDidFinishLaunchingOptionsString = JK_EasyCFString("application:didFinishLaunchingWithOptions:");
	CFStringRef hardModeAppDelegateString = JK_EasyCFString("HardModeAppDelegate");
	CFStringRef NSAutoreleasePoolString = JK_EasyCFString("NSAutoreleasePool");
	CFStringRef initString = JK_EasyCFString("init");
	CFStringRef drainString = JK_EasyCFString("drain");
	
	// Create a class to serve as our application delegate.
	Class appDelegate = objc_allocateClassPair(NSClassFromString((id)NSObjectString), "HardModeAppDelegate", 0);
	objc_registerClassPair(appDelegate);
	
	// Conform to the UIApplciationDelegate protocol.
	Protocol *appDelegateProto = NSProtocolFromString((id)UIApplicationDelegateString);
	class_addProtocol(appDelegate, appDelegateProto);
	
	// Add methods.
	SEL applicationDidFinishLaunchingWithOptions = NSSelectorFromString((id)appDidFinishLaunchingOptionsString);
	class_addMethod(appDelegate,
					applicationDidFinishLaunchingWithOptions,
					(IMP)UIApplicationDelegate_ApplicationDidFinishLaunchingWithOptions,
					"v@:@@");
    
	// Create our autorelease pool.
	Class autoreleasePool = NSClassFromString((id)NSAutoreleasePoolString);
	id pool = class_createInstance(autoreleasePool, 0);
	
	// Now we need to signal ‘init’
	SEL init = NSSelectorFromString((id)initString);
	pool = objc_msgSend(pool, init);
	
	// Run the app!
    int retVal = UIApplicationMain(argc, argv, nil, (id)hardModeAppDelegateString);

	// Now we need to drain the pool.
	SEL drain = NSSelectorFromString((id)drainString);
	objc_msgSend(pool, drain);
	
	// Cleaning up those strings we made earlier.
	CFRelease(drainString);
	CFRelease(initString);
	CFRelease(NSAutoreleasePoolString);
	CFRelease(hardModeAppDelegateString);
	CFRelease(appDidFinishLaunchingOptionsString);
	CFRelease(UIApplicationDelegateString);
	CFRelease(NSObjectString);
	
    return retVal;
}

#pragma mark -
#pragma mark UIApplicationDelegate Method Implementations

void UIApplicationDelegate_ApplicationDidFinishLaunchingWithOptions(id self,
																	SEL _cmd,
																	UIApplication *application,
																	NSDictionary *launchOptions)
{
	// Create strings we’ll use in this function.
	CFStringRef UIWindowString = JK_EasyCFString("UIWindow");
	CFStringRef UIScreenString = JK_EasyCFString("UIScreen");
	CFStringRef mainScreenString = JK_EasyCFString("mainScreen");
	CFStringRef boundsString = JK_EasyCFString("bounds");
	CFStringRef initWithFrameString = JK_EasyCFString("initWithFrame:");
	CFStringRef makeKeyAndVisibleString = JK_EasyCFString("makeKeyAndVisible");
	
	// First we need to create a window.
	id window = class_createInstance(NSClassFromString((id)UIWindowString), 0);
	
	// We want to call -initWithFrame:, but with what frame? Crap, we need a UIScreen…
	Class screenClass = NSClassFromString((id)UIScreenString);
	SEL mainScreen = NSSelectorFromString((id)mainScreenString);
	id screen = objc_msgSend(screenClass, mainScreen);
	
	// Now we need to get the bounds of the main screen.
	SEL bounds = NSSelectorFromString((id)boundsString);
	CGRect screenBounds;
	objc_msgSend_stret((void *)&screenBounds, (id)screen, bounds);
	
	// Now we can call -initWithFrame. But oh crap, it takes in a CGRect.
	id (*msgSendCGRect)(id self, SEL _cmd, CGRect rect) = (id *)objc_msgSend;
	SEL initWithFrame = NSSelectorFromString((id)initWithFrameString);
	window =  msgSendCGRect(window, initWithFrame, screenBounds);
	
	//UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window makeKeyAndVisible];
	
	
	// Release the strings we’ve used.
	CFRelease(makeKeyAndVisibleString);
	CFRelease(initWithFrameString);
	CFRelease(boundsString);
	CFRelease(mainScreenString);
	CFRelease(UIScreenString);
	CFRelease(UIWindowString);
}

#pragma mark -
