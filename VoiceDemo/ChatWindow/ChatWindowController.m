//
//  ChatWindowController.m
//  VoiceDemo
//
//  Created by wyt_M1 on 12/1/23.
//

#import "ChatWindowController.h"
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>
#import "HNPostKeyManager.h"
#import <Carbon/Carbon.h>

@interface ChatWindowController ()

@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;

@property (nonatomic, strong) NSString *transcription;

//tts
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) AVSpeechSynthesisVoice *speechSynthesisVoice;

@end

@implementation ChatWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    //语音输入
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        
    }];
    
    self.audioEngine = [[AVAudioEngine alloc] init];
    
    
    //tts
    
    self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    self.speechSynthesisVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    
    
}
- (IBAction)chat:(id)sender {
    
    if (![self.speechRecognizer isAvailable]) {
        NSLog(@"语音识别不可用");
        return;
    }

    if (!self.audioEngine.isRunning) {
        [self startSpeechRecognition];
    } else {
        [self stopSpeechRecognition];
    }
    
}

- (IBAction)send:(id)sender {
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HNPostKeyManager postEventWithKeycode:0x1b eventFlags:kCGEventFlagMaskCommand];
//    });
    
//    self.transcription = @"缩小画布";
//    if (self.transcription.length == 0) {
//        return;
//    }
//    
//    [self stopSpeechRecognition];
//    [self praseCommand:self.transcription];
    
}

- (void)praseCommand:(NSString *)command {

    NSString *resultStr = @"";
    
    if ([command containsString:@"缩小画布"]) {
        NSLog(@"缩小画布===");
        resultStr = @"缩小画布";
        [HNPostKeyManager postEventWithKeycode:0x1b eventFlags:kCGEventFlagMaskCommand];
    } else if ([self.transcription containsString:@"放大画布"]) {
        NSLog(@"放大画布===");
        resultStr = @"放大画布";
        [HNPostKeyManager postEventWithKeycode:0x1b eventFlags:kCGEventFlagMaskCommand];
    } else if ([self.transcription containsString:@"缩小笔刷"]) {
        NSLog(@"缩小笔刷===");
        resultStr = @"缩小笔刷";
        [HNPostKeyManager postEventWithKeycode:0x1b eventFlags:kCGEventFlagMaskCommand];
    } else if ([self.transcription containsString:@"放大笔刷"]) {
        NSLog(@"放大笔刷===");
        resultStr = @"放大笔刷";
        [HNPostKeyManager postEventWithKeycode:0x1b eventFlags:kCGEventFlagMaskCommand];
    } else if ([self.transcription containsString:@"橡皮"]) {
        NSLog(@"橡皮擦===");
        resultStr = @"橡皮擦";
        [HNPostKeyManager postEventWithKeycode:0x1b eventFlags:kCGEventFlagMaskCommand];
    } else if ([self.transcription containsString:@"笔刷工具"]) {
        NSLog(@"笔刷工具===");
        resultStr = @"笔刷工具";
    } else {
        [self sendRequestPrompt:self.transcription];
    }
    
    if (resultStr.length > 0) {
        
//        self.assistantLabel.stringValue = resultStr;
        
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:resultStr];
        utterance.voice = self.speechSynthesisVoice;
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
        [self.speechSynthesizer speakUtterance:utterance];
       
    }
    
}

- (void)startSpeechRecognition {
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];

    if (!self.recognitionRequest) {
        NSLog(@"创建语音识别请求失败");
        return;
    }

    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    AVAudioFormat *format = [inputNode outputFormatForBus:0];

    __weak typeof(self) wSelf = self;
    [inputNode installTapOnBus:0 bufferSize:1024 format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [wSelf.recognitionRequest appendAudioPCMBuffer:buffer];
    }];

    [self.audioEngine prepare];
    NSError *error;
    [self.audioEngine startAndReturnError:&error];

    if (error) {
        NSLog(@"启动 AVAudioEngine 失败: %@", error);
        return;
    }

    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        
        BOOL isFinal = NO;
        
        if (result) {
            isFinal = result.isFinal;
            
            NSString *transcription = result.bestTranscription.formattedString;
            NSLog(@"识别结果: %@", transcription);
        
            wSelf.transcription = transcription;
            
//            wSelf.userLabel.stringValue = transcription;

            if (error || isFinal) {
//                [self stopSpeechRecognition];
                NSLog(@"isFinal, 识别结果: %@", transcription);

            }

        }
        
        if (error) {
            NSLog(@"语音识别错误: %@", error);
        }
    }];

}

- (void)stopSpeechRecognition {
    [self.audioEngine stop];
    [self.audioEngine.inputNode removeTapOnBus:0];
    self.recognitionRequest = nil;
    [self.recognitionTask finish];
    self.recognitionTask = nil;

}

- (void)sendRequestPrompt:(NSString *)prompt {
 
    NSString *urlStr = @"https://api.openai.com/v1/chat/completions";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *authValue = [NSString stringWithFormat: @"Bearer yourAPIKey"];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    request.HTTPMethod = @"POST";
//    request.timeoutInterval = 10;

    NSDictionary *dic = @{
        @"model": @"gpt-3.5-turbo",
        @"messages": @[
            @{@"role": @"system", @"content": @"假装你是一个photoshop助手，你有如下功能：缩小画布；放大画布；缩小笔刷；放大笔刷；橡皮擦；笔刷工具。你会收到指令，如果用户表述不明确，比如画布，你就要问清楚是缩小画布还是放大画布，如果你判断出了上述指令，你就直接输出这个指令名字，不要输出其他任何内容，我们现在开始。"},
            @{@"role": @"user", @"content": prompt}
        ]
    };
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    [request setHTTPBody:postData];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"responseJson=====%@", json);
            NSLog(@"content====%@", json[@"choices"][0][@"message"][@"content"]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                self.assistantLabel.stringValue = json[@"choices"][0][@"message"][@"content"];
                
//                AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.assistantLabel.stringValue];
//                utterance.voice = self.speechSynthesisVoice;
//                utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
//                [self.speechSynthesizer speakUtterance:utterance];
                [HNPostKeyManager postEventWithKeycode:0x1b eventFlags:kCGEventFlagMaskCommand];

            });

        }
    }];

    [dataTask resume];

}

@end
