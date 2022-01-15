/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#include "vgsplay-ios.h"
#include "vgsdec.h"
#include "vgsmml.h"
#include <AudioToolbox/AudioQueue.h>
#include <CoreAudio/CoreAudioTypes.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define NUM_CHANNELS 1
#define BUFFER_SIZE 4096
#define SAMPLE_TYPE short
#define MAX_NUMBER 32767
#define SAMPLE_RATE 22050
#define MAX_BUFFER_NUM 16

struct Context {
    pthread_mutex_t mutex;
    AudioStreamBasicDescription format;
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[MAX_BUFFER_NUM];
    int numberOfBuffer;
    int emptyEnqueueCounter;
    unsigned char emptyBuffer[BUFFER_SIZE];
    unsigned char rawBuffers[2][BUFFER_SIZE];
    int latch;
    int loop;
    int infinity;
    int timeLog[MAX_BUFFER_NUM];
    int timeLogIndex;
    bool fadeout;
    void* vgsdec;
};

static struct Context* fs_context;
static pthread_mutex_t fs_mutex = PTHREAD_MUTEX_INITIALIZER;

static void executeDecode(Context* c, void* buffer)
{
    vgsdec_execute(c->vgsdec, buffer, BUFFER_SIZE);
    c->timeLog[c->timeLogIndex++] = vgsdec_get_value(c->vgsdec, VGSDEC_REG_TIME);
    c->timeLogIndex &= 0x0F;
}

static void callback(void* context, AudioQueueRef queue, AudioQueueBufferRef buffer)
{
    struct Context* c = (struct Context*)context;
    pthread_mutex_lock(&c->mutex);
    if (vgsdec_get_value(c->vgsdec, VGSDEC_REG_PLAYING)) {
        memcpy(buffer->mAudioData, c->rawBuffers[c->latch], BUFFER_SIZE);
    } else {
        memcpy(buffer->mAudioData, c->emptyBuffer, BUFFER_SIZE);
        c->emptyEnqueueCounter++;
    }
    AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    c->latch = 1 - c->latch;
    if (c->vgsdec) {
        executeDecode(c, c->rawBuffers[c->latch]);
        if (c->loop && !c->fadeout) {
            if (!c->infinity && c->loop <= vgsdec_get_value(c->vgsdec, VGSDEC_REG_LOOP_COUNT)) {
                vgsdec_set_value(c->vgsdec, VGSDEC_REG_FADEOUT, 1);
                c->fadeout = true;
            }
        }
    } else {
        memset(c->rawBuffers[c->latch], 0, BUFFER_SIZE);
    }
    pthread_mutex_unlock(&c->mutex);
}

static struct Context* internal_sound_create(const char* mmlPath, int loop, int infinity, int seek, int numberOfBuffer)
{
    struct Context* result = (struct Context*)malloc(sizeof(struct Context));
    if (!result) return NULL;
    memset(result, 0, sizeof(struct Context));
    pthread_mutex_init(&result->mutex, NULL);
    result->format.mSampleRate = SAMPLE_RATE;
    result->format.mFormatID = kAudioFormatLinearPCM;
    result->format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    result->format.mBitsPerChannel = 8 * sizeof(SAMPLE_TYPE);
    result->format.mChannelsPerFrame = NUM_CHANNELS;
    result->format.mBytesPerFrame = sizeof(SAMPLE_TYPE) * NUM_CHANNELS;
    result->format.mFramesPerPacket = 1;
    result->format.mBytesPerPacket = result->format.mBytesPerFrame * result->format.mFramesPerPacket;
    result->format.mReserved = 0;
    AudioQueueNewOutput(&result->format, callback, result, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &result->queue);
    result->loop = loop;
    result->infinity = infinity;
    result->fadeout = false;
    result->vgsdec = vgsdec_create_context();
    VgsMmlErrorInfo err;
    VgsBgmData* bgm = vgsmml_compile_from_file(mmlPath, &err);
    if (bgm) {
        vgsdec_load_bgm_from_memory(result->vgsdec, bgm->data, bgm->size);
        vgsmml_free_bgm_data(bgm);
    }
    if (seek) {
        vgsdec_set_value(result->vgsdec, VGSDEC_REG_TIME, seek);
    }
    for (int i = 0; i < numberOfBuffer; i++) {
        AudioQueueAllocateBuffer(result->queue, BUFFER_SIZE, &result->buffers[i]);
        result->buffers[i]->mAudioDataByteSize = BUFFER_SIZE;
        executeDecode(result, result->rawBuffers[0]); // pre-enqueue
        memcpy(result->buffers[i]->mAudioData, result->rawBuffers[0], BUFFER_SIZE);
        AudioQueueEnqueueBuffer(result->queue, result->buffers[i], 0, NULL);
    }
    executeDecode(result, result->rawBuffers[1]); // decode next
    result->latch = 1;
    AudioQueueStart(result->queue, NULL);
    return result;
}

static void internal_sound_destroy(void* context)
{
    struct Context* c = (struct Context*)context;
    AudioQueueStop(c->queue, true);
    AudioQueueDispose(c->queue, true);
    pthread_mutex_lock(&c->mutex);
    vgsdec_release_context(c->vgsdec);
    c->vgsdec = NULL;
    pthread_mutex_unlock(&c->mutex);
    pthread_mutex_destroy(&c->mutex);
    free(c);
}

struct CurrentPlayingData {
    char mmlPath[4096];
    int loop;
    int infinity;
    int seek;
    int numberOfBuffer;
};
static struct CurrentPlayingData _currentPlayingData;

void vgsplay_start(const char* mmlPath, int loop, int infinity, int seek, int numberOfBuffer)
{
    vgsplay_stop();
    pthread_mutex_lock(&fs_mutex);
    fs_context = internal_sound_create(mmlPath, loop, infinity, seek, numberOfBuffer);
    strcpy(_currentPlayingData.mmlPath, mmlPath);
    _currentPlayingData.loop = loop;
    _currentPlayingData.infinity = infinity;
    _currentPlayingData.seek = seek;
    _currentPlayingData.numberOfBuffer = numberOfBuffer;
    pthread_mutex_unlock(&fs_mutex);
}

void vgsplay_stop()
{
    pthread_mutex_lock(&fs_mutex);
    if (fs_context) {
        internal_sound_destroy(fs_context);
        fs_context = NULL;
    }
    pthread_mutex_unlock(&fs_mutex);
}

void vgsplay_changeLoopCount(int loop)
{
    pthread_mutex_lock(&fs_mutex);
    if (fs_context) {
        pthread_mutex_lock(&fs_context->mutex);
        fs_context->loop = loop;
        pthread_mutex_unlock(&fs_context->mutex);
    }
    pthread_mutex_unlock(&fs_mutex);
}

unsigned int vgsplay_getSongLength()
{
    unsigned int result = 0;
    pthread_mutex_lock(&fs_mutex);
    if (fs_context) {
        pthread_mutex_lock(&fs_context->mutex);
        result = (unsigned int)vgsdec_get_value(fs_context->vgsdec, VGSDEC_REG_TIME_LENGTH);
        pthread_mutex_unlock(&fs_context->mutex);
    }
    pthread_mutex_unlock(&fs_mutex);
    return result;
}

unsigned int vgsplay_getCurrentTime(void)
{
    unsigned int result = 0;
    pthread_mutex_lock(&fs_mutex);
    if (fs_context) {
        pthread_mutex_lock(&fs_context->mutex);
        result = fs_context->timeLog[(fs_context->timeLogIndex + 1) & 0x0F];
        pthread_mutex_unlock(&fs_context->mutex);
    }
    pthread_mutex_unlock(&fs_mutex);
    return result;
}

void vgsplay_seek(unsigned int time)
{
    if (fs_context) {
        vgsplay_stop();
        _currentPlayingData.seek = time;
        vgsplay_start(_currentPlayingData.mmlPath,
                      _currentPlayingData.loop,
                      _currentPlayingData.infinity,
                      _currentPlayingData.seek,
                      _currentPlayingData.numberOfBuffer);
    }
}

int vgsplay_isPlaying()
{
    int result = 0;
    pthread_mutex_lock(&fs_mutex);
    if (fs_context && fs_context->vgsdec) {
        pthread_mutex_lock(&fs_context->mutex);
        result = vgsdec_get_value(fs_context->vgsdec, VGSDEC_REG_PLAYING);
        if (!result) {
            result = fs_context->emptyEnqueueCounter < MAX_BUFFER_NUM ? 1 : 0;
        }
        pthread_mutex_unlock(&fs_context->mutex);
    }
    pthread_mutex_unlock(&fs_mutex);
    return result;
}

void vgsplay_changeInfinity(int infinity)
{
    pthread_mutex_lock(&fs_mutex);
    if (fs_context) {
        pthread_mutex_lock(&fs_context->mutex);
        fs_context->infinity = infinity;
        _currentPlayingData.infinity = infinity;
        pthread_mutex_unlock(&fs_context->mutex);
    }
    pthread_mutex_unlock(&fs_mutex);
}

void* vgsplay_getDecoder(void)
{
    void* result = NULL;
    pthread_mutex_lock(&fs_mutex);
    if (fs_context) {
        pthread_mutex_lock(&fs_context->mutex);
        result = fs_context->vgsdec;
        pthread_mutex_unlock(&fs_context->mutex);
    }
    pthread_mutex_unlock(&fs_mutex);
    return result;
}
