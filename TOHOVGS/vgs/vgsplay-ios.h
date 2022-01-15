/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#ifndef sound_ios_h
#define sound_ios_h
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

void vgsplay_start(const char* mmlPath, int loop, int infinity, int seek, int numberOfBuffer);
void vgsplay_stop(void);
unsigned int vgsplay_getSongLength(void);
unsigned int vgsplay_getCurrentTime(void);
void vgsplay_seek(unsigned int time);
void vgsplay_changeLoopCount(int loop);
int vgsplay_isPlaying(void);
void vgsplay_changeInfinity(int infinity);
void* vgsplay_getDecoder(void);

#ifdef __cplusplus
};
#endif

#endif /* sound_ios_h */
