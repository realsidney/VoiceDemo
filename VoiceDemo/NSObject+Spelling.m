//
//  NSObject+Spelling.m
//  VoiceDemo
//
//  Created by wyt_M1 on 12/1/23.
//

#import "NSObject+Spelling.h"

@implementation NSString (Spelling)

- (NSString *)spelling
{
    if (self.length) {
        NSMutableString *copy = [self mutableCopy];
        CFStringTransform((__bridge CFMutableStringRef)copy, NULL, kCFStringTransformMandarinLatin, NO); // 得到带音调的拼音
        CFStringTransform((__bridge CFMutableStringRef)copy, NULL, kCFStringTransformStripDiacritics, NO); // 过滤掉音调 每个汉字之间会用空格分开
        [copy replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, copy.length)]; // 过滤掉空格
        return copy;
    }
    else {
        return nil;
    }
}


@end
