//
//  HNPostKeyManager.h
//  VoiceDemo
//
//  Created by wyt_M1 on 11/30/23.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNPostKeyManager : NSObject

+ (void)postEventWithKeycode:(CGKeyCode)ek eventFlags:(CGEventFlags)flags;

@end

NS_ASSUME_NONNULL_END
