//
//  ViewController.m
//  VoiceDemo
//
//  Created by wyt_M1 on 11/28/23.
//

#import "ViewController.h"
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>
#import "HNPostKeyManager.h"
#import <Carbon/Carbon.h>
#import "ChatWindowController.h"
#import "NSObject+Spelling.h"

@interface ViewController ()

@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;

@property (nonatomic, strong) NSString *transcription;

@property (weak) IBOutlet NSTextField *assistantLabel;
@property (weak) IBOutlet NSTextField *userLabel;

//tts
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) AVSpeechSynthesisVoice *speechSynthesisVoice;

@property (nonatomic, strong) ChatWindowController *chatWindowController;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    //语音输入
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        
    }];
    
    self.audioEngine = [[AVAudioEngine alloc] init];
    
    
    //tts
    
    self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    self.speechSynthesisVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
        
    self.assistantLabel.maximumNumberOfLines = 0;
    self.userLabel.maximumNumberOfLines = 0;
    
}

- (void)viewDidAppear {
    [super viewDidAppear];
    self.view.window.movable = YES;
    self.view.window.movableByWindowBackground = YES;
 
}

- (IBAction)handleRecognize:(id)sender {
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
  
    if (self.transcription.length == 0) {
        return;
    }
    
    [self stopSpeechRecognition];
    [self praseCommand:self.transcription isAssitant:NO];
    
//    if (!_chatWindowController) {
//        _chatWindowController = [[ChatWindowController alloc] initWithWindowNibName:@"ChatWindowController"];
//        [_chatWindowController.window orderFront:nil];
//        _chatWindowController.window.level = NSFloatingWindowLevel;
//        [_chatWindowController.window center];
////        CGPoint mouseLoc = [NSEvent mouseLocation];
////        CGRect rect = CGRectMake(mouseLoc.x - 195, mouseLoc.y - 75, 390, 150);
////        _radialMenuWindowController.tabletCfg = tabletConfig;
////        [_radialMenuWindowController.window setFrame:rect display:YES];
//    }
    
}

- (void)praseCommand:(NSString *)command isAssitant:(BOOL)isAssitant {

    NSString *resultStr = @"";
    
    if ([command isEqualTo:@"画笔工具"] || [command.spelling containsString:@"笔工具".spelling]) {
        resultStr = @"画笔工具";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_B eventFlags:0];
        
    } else if ([command isEqualTo:@"橡皮擦工具"] || [command.spelling containsString:@"橡皮".spelling]) {
        resultStr = @"橡皮擦工具";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_E eventFlags:0];
        
    } else if ([command isEqualTo:@"套索工具"] || [command.spelling containsString:@"套s".spelling]) {
        resultStr = @"套索工具";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_L eventFlags:0];
        
    } else if ([command isEqualTo:@"吸管工具"] || [command.spelling containsString:@"吸g".spelling]) {
        resultStr = @"吸管工具";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_I eventFlags:0];
        
    } else if ([command isEqualTo:@"笔刷放大"] || [command.spelling containsString:@"笔刷放大".spelling]) {
        resultStr = @"笔刷放大";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_RightBracket eventFlags:0];
        
    } else if ([command isEqualTo:@"笔刷缩小"] || [command.spelling containsString:@"笔刷缩小".spelling]) {
        resultStr = @"笔刷缩小";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_LeftBracket eventFlags:0];
        
    } else if ([command isEqualTo:@"画布放大"] || [command.spelling containsString:@"画布放大".spelling]) {
        resultStr = @"画布放大";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_Equal eventFlags:kCGEventFlagMaskCommand];
        
    } else if ([command isEqualTo:@"画布缩小"] || [command.spelling containsString:@"画布缩小".spelling]) {
        resultStr = @"画布缩小";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_Minus eventFlags:kCGEventFlagMaskCommand];
        
    } else if ([command isEqualTo:@"还原"] || [command.spelling containsString:@"还原".spelling]) {
        resultStr = @"还原";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_Z eventFlags:kCGEventFlagMaskCommand];

    } else if ([command isEqualTo:@"重做"] || [command.spelling containsString:@"重做".spelling]) {
        resultStr = @"重做";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_Z eventFlags:kCGEventFlagMaskCommand | kCGEventFlagMaskShift];

    } else if ([command isEqualTo:@"保存"] || [command.spelling containsString:@"保存".spelling]) {
        resultStr = @"保存";
        [HNPostKeyManager postEventWithKeycode:kVK_ANSI_S eventFlags:kCGEventFlagMaskCommand];

    } else {
        if (!isAssitant) {
            [self sendRequestPrompt:self.transcription];
        }
    }
    
    if (resultStr.length > 0) {
        
        self.assistantLabel.stringValue = resultStr;
        
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
            wSelf.userLabel.stringValue = transcription;

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
            @{@"role": @"system", @"content": @"假装你是一个photoshop助手，你有如下功能：画笔工具；橡皮擦工具；套索工具；吸管工具；笔刷放大；笔刷缩小；画布放大；画布缩小；还原；重做；保存。你会收到指令，如果用户表述不明确，比如画布，你就要问清楚是缩小画布还是放大画布，如果你判断出了上述指令，你就直接输出这个指令名字，不要输出其他任何内容，我们现在开始。"},
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
                self.assistantLabel.stringValue = json[@"choices"][0][@"message"][@"content"];
                
                AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.assistantLabel.stringValue];
                utterance.voice = self.speechSynthesisVoice;
                utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
                [self.speechSynthesizer speakUtterance:utterance];
                [self praseCommand:self.transcription isAssitant:YES];
            });

        }
    }];

    [dataTask resume];

}

@end
