//
//  HNPostKeyManager.m
//  VoiceDemo
//
//  Created by wyt_M1 on 11/30/23.
//

#import "HNPostKeyManager.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation HNPostKeyManager

void PostKeyEvent(CGKeyCode key, CGEventFlags flags)
{
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventRef keyDown = CGEventCreateKeyboardEvent(source, key, true);
    CGEventSetFlags(keyDown, flags);
    CGEventRef keyUp = CGEventCreateKeyboardEvent(source, key, false);
    CGEventSetFlags(keyUp, flags);
    
    CGEventPost(kCGHIDEventTap, keyDown);
    CGEventPost(kCGHIDEventTap, keyUp);

    CFRelease(keyUp);
    CFRelease(keyDown);
    CFRelease(source);
}

void PostKeyEventWithoutFlags(CGKeyCode key) {
    
    CGEventSourceRef eventSrc = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGEventRef keyDown = CGEventCreateKeyboardEvent(eventSrc, key, YES);
    CGEventRef keyUp = CGEventCreateKeyboardEvent(eventSrc, key, NO);
    CGEventPost(kCGHIDEventTap, keyDown);
    CGEventPost(kCGHIDEventTap, keyUp);
    
    CFRelease(keyUp);
    CFRelease(keyDown);
    CFRelease(eventSrc);
    
    NSLog(@"PostKeyEventWithoutFlags");
   
}

+ (void)postEventWithKeycode:(CGKeyCode)ek eventFlags:(CGEventFlags)flags {
    if (flags) {
        PostKeyEvent(ek, flags);
    } else {
        PostKeyEventWithoutFlags(ek);
    }
}

@end
