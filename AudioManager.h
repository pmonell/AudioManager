//
//  AudioManager.h
//  tattle
//
//  Created by Phillip on 8/2/15.
//  Copyright (c) 2015 Phillip. All rights reserved.
//

#import <Foundation/Foundation.h>

//  AudioManager is a singleton to be used for managing
//  all audio (recording and playback) processes in the
//  application.
@interface AudioManager : NSObject

//  playlist controls current playlist to be played by
//  AudioManager and can be set before calling play.
//  May not be necessary anymore, use
//  playPlaylistWithArrayOfURLs:
@property (nonatomic, strong, readonly) NSArray *playlist;
@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, readonly) BOOL isRecording;

//  singleton, call to grab global instance
+ (instancetype)sharedInstance;

//  plays an array of audio URLs
- (void)playPlaylistWithArrayOfURLs:(NSArray *)audioList;
//  plays next audio URL in playlist, use only with above
- (void)playNext;

//  plays a single audio URL
- (void)playSingleFile:(NSURL *)audioURL;

//  pauses playback when playing, and plays when paused
- (void)pausePlay;

//  stops playback
- (void)stopPlaying;

//  starts recording at file specified in recordingURL,
//  stops playback if playback is happening
- (void)startRecordingAtURL:(NSURL *)recordingURL;

//  stops recording
- (void)stopRecording;

@end
