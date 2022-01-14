//
//  sound-ios
//  Sound System for iOS (AudioQueue)
//
//  Created by 鈴木　洋司　 on 2018/02/28.
//  Copyright © 2018年 SUZUKI PLAN. All rights reserved.
//

#ifndef sound_ios_h
#define sound_ios_h
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

void vgsplay_start(const char* mmlPath);
void vgsplay_stop(void);
unsigned int vgsplay_getSongLength(void);
unsigned int vgsplay_getCurrentTime(void);
void vgsplay_seek(unsigned int time);

#ifdef __cplusplus
};
#endif

#endif /* sound_ios_h */
