//
//  AudioManager.m
//  tattle
//
//  Created by Phillip on 8/2/15.
//  Copyright (c) 2015 Phillip. All rights reserved.
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioManager() <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
- (void)play;
@end

@implementation AudioManager

# pragma mark SharedInstance
+ (instancetype)sharedInstance
{
    static AudioManager *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AudioManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark Playlist
@synthesize playlist = _playlist;

- (void)setPlaylist:(NSArray *)playlist {
    NSMutableArray *playArray = [[NSMutableArray alloc] initWithCapacity:[playlist count]];
    NSError *error;
    
    for (NSURL *audioURL in playlist) {
        [playArray addObject:[[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error]];
        if (error) {
            NSLog(@"error: %@", error);
        }
    }
    
    _player = [playArray objectAtIndexedSubscript:0];
    
    _playlist = [playArray copy];
}

# pragma mark Record
- (void)startRecordingAtURL:(NSURL *)recordingURL
{
    if (_player.playing) {
        [_player stop];
    }
    
    if (!_recorder) {
        NSDictionary *recorderSettingsDictionary =
            [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatAC3],AVFormatIDKey,
                                                    [NSNumber numberWithInt:16000.0],AVSampleRateKey,
                                                    [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                                    nil];
        NSError *error;
        _recorder = [[AVAudioRecorder alloc] initWithURL:recordingURL
                                                settings:recorderSettingsDictionary
                                                   error:&error];
    }
    
    if (_recorder.recording) {
        [_recorder stop];
    }
    
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    [_recorder recordForDuration:30.0];
}

- (void)stopRecording
{
    if (_recorder.recording) [_recorder stop];
}

# pragma mark Playback
- (void)play
{
    if (_player.playing) [_player stop];
    [_player prepareToPlay];
    _player.delegate = self;
    [_player play];
}

- (void)playNext
{
    if (_player.playing) {
        [_player stop];
    }
    int nextIndex = (int)[_playlist indexOfObject:_player] + 1;
    _player = [_playlist objectAtIndexedSubscript:nextIndex];
    [self play];
}

- (void)playSingleFile:(NSURL *)audioURL
{
    if (_player.playing) [_player stop];
    
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
    
    if (!error) {
        [self play];
    } else {
        NSLog(@"error: %@", error);
    }
}

- (void)playPlaylistWithArrayOfURLs:(NSArray *)audioList
{
    [self setPlaylist:audioList];
    [self play];
}

- (void)pausePlay
{
    if (_player.playing) {
        [_player pause];
    } else if(!_player.playing) {
        [_player play];
    }
}

- (void)stopPlaying
{
    if (_player.playing) [_player stop];
}

#pragma mark Delegates
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (!flag) {
        NSLog(@"player finished playing unsuccessfully");
    } else {
        if ([_playlist count] >= 1) {
            [self playNext];
        }
    }
}

@end
