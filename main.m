//
//  main.m
//  HardMode
//
//  Created by Jeff Kelley on 1/28/11.
//  Copyright 2011 Jeff Kelley. All rights reserved.
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
void appDelegate_dealloc(id self, SEL _cmd);

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
	CFStringRef deallocString = JK_EasyCFString("dealloc");
	
	// Create a class to serve as our application delegate.
	Class appDelegate = objc_allocateClassPair(NSClassFromString((id)NSObjectString), "HardModeAppDelegate", 0);
	
	// Conform to the UIApplciationDelegate protocol.
	Protocol *appDelegateProto = NSProtocolFromString((id)UIApplicationDelegateString);
	class_addProtocol(appDelegate, appDelegateProto);
	
	// Add methods.
	SEL applicationDidFinishLaunchingWithOptions = NSSelectorFromString((id)appDidFinishLaunchingOptionsString);
	class_addMethod(appDelegate,
					applicationDidFinishLaunchingWithOptions,
					(IMP)UIApplicationDelegate_ApplicationDidFinishLaunchingWithOptions,
					"v@:@@");
	
	SEL dealloc = NSSelectorFromString((id)deallocString);
	class_addMethod(appDelegate,
					dealloc,
					(IMP)appDelegate_dealloc,
					"v@:");
	
	// Add an instance variable for the window.
	class_addIvar(appDelegate,
				  "window",
				  sizeof(id),
				  log2(sizeof(id)),
				  "@");

	// Now that we’ve added ivars, we can register the class.
	objc_registerClassPair(appDelegate);

    
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
	CFRelease(deallocString);
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
	CFStringRef UIColorString = JK_EasyCFString("UIColor");
	CFStringRef whiteColorString = JK_EasyCFString("whiteColor");
	CFStringRef setBackgroundColorString = JK_EasyCFString("setBackgroundColor:");
	CFStringRef UILabelString = JK_EasyCFString("UILabel");
	CFStringRef setTextString = JK_EasyCFString("setText:");
	CFStringRef helloWorld = JK_EasyCFString("Hello, world!");
	CFStringRef addSubviewString = JK_EasyCFString("addSubview:");
	
	// First we need to create a window.
	Class windowClass = NSClassFromString((id)UIWindowString);
	id window = class_createInstance(windowClass, 0);
	
	// We want to call -initWithFrame:, but with what frame? Crap, we need a UIScreen…
	Class screenClass = NSClassFromString((id)UIScreenString);
	SEL mainScreen = NSSelectorFromString((id)mainScreenString);
	id screen = objc_msgSend(screenClass, mainScreen);
	
	// Now we need to get the bounds of the main screen. See Greg Parker’s e-mail to me here:
	// http://lists.apple.com/archives/Cocoa-dev/2011/Feb/msg00096.html
	CGRect (*msgSendBounds)(id self, SEL _cmd);
    msgSendBounds = (CGRect(*)(id, SEL))objc_msgSend_stret;
	
	SEL bounds = NSSelectorFromString((id)boundsString);
    CGRect screenBounds = msgSendBounds(screen, bounds);
	
	// Now we can call -initWithFrame. But oh crap, it takes in a CGRect.
	id (*msgSendCGRect)(id self, SEL _cmd, CGRect rect);
	msgSendCGRect = (id(*)(id, SEL, CGRect))objc_msgSend;
	SEL initWithFrame = NSSelectorFromString((id)initWithFrameString);
	window =  msgSendCGRect(window, initWithFrame, screenBounds);
	
	// Set the window as the ivar.
	Ivar windowIvar = class_getInstanceVariable(windowClass, "window");
	object_setIvar(self, windowIvar, window);
	
	// Call -makeKeyAndVisible.
	SEL makeKeyAndVisible = NSSelectorFromString((id)makeKeyAndVisibleString);
	objc_msgSend(window, makeKeyAndVisible);
	
	// Set the background color of the window. First we need a UIColor to pass in.
	Class colorClass = NSClassFromString((id)UIColorString);
	SEL whiteColor = NSSelectorFromString((id)whiteColorString);
	id white = objc_msgSend(colorClass, whiteColor);
	
	// Now call -setBackgroundColor:
	SEL setBackgroundColor = NSSelectorFromString((id)setBackgroundColorString);
	id (*msgSend_id)(id self, SEL _cmd, UIColor *color) = (id(*)(id, SEL, id))objc_msgSend;
	msgSend_id(window, setBackgroundColor, white);
	
	// And for our final trick we’ll create a label.
	id label = class_createInstance(NSClassFromString((id)UILabelString), 0);
	// At least we already have -initWithFrame: defined.
	label = msgSendCGRect(label, initWithFrame, screenBounds);
	
	// Let’s put some text in the label.
	SEL setText = NSSelectorFromString((id)setTextString);
	msgSend_id(label, setText, (id)helloWorld);
	
	// And, finally, add it to the window.
	SEL addSubview = NSSelectorFromString((id)addSubviewString);
	msgSend_id(window, addSubview, label);
	
	// Release the strings we’ve used.
	CFRelease(addSubviewString);
	CFRelease(helloWorld);
	CFRelease(setTextString);
	CFRelease(UILabelString);
	CFRelease(setBackgroundColorString);
	CFRelease(whiteColorString);
	CFRelease(UIColorString);
	CFRelease(makeKeyAndVisibleString);
	CFRelease(initWithFrameString);
	CFRelease(boundsString);
	CFRelease(mainScreenString);
	CFRelease(UIScreenString);
	CFRelease(UIWindowString);
}

void appDelegate_dealloc(id self, SEL _cmd)
{
	CFStringRef releaseString = JK_EasyCFString("release");
	Ivar windowIvar = class_getInstanceVariable(self->isa, "window");
	id window = object_getIvar(self, windowIvar);
	
	SEL release = NSSelectorFromString((id)releaseString);
	
	objc_msgSend(window, release);
	
	CFRelease(releaseString);
	
	
	struct objc_super superClass;
	superClass.receiver = self;
	superClass.super_class = self->isa->isa;
	
	objc_msgSendSuper(&superClass, _cmd);
}

#pragma mark -
