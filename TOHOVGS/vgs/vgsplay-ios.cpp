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
    unsigned char rawBuffers[2][BUFFER_SIZE];
    int latch;
    int loop;
    int infinity;
    bool fadeout;
    void* vgsdec;
};

static struct Context* fs_context;
static pthread_mutex_t fs_mutex = PTHREAD_MUTEX_INITIALIZER;

static void callback(void* context, AudioQueueRef queue, AudioQueueBufferRef buffer)
{
    struct Context* c = (struct Context*)context;
    pthread_mutex_lock(&c->mutex);
    memcpy(buffer->mAudioData, c->rawBuffers[c->latch], BUFFER_SIZE);
    AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    c->latch = 1 - c->latch;
    if (c->vgsdec) {
        vgsdec_execute(c->vgsdec, c->rawBuffers[c->latch], BUFFER_SIZE);
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
        vgsdec_execute(result->vgsdec, result->rawBuffers[0], BUFFER_SIZE); // pre-enqueue
        memcpy(result->buffers[i]->mAudioData, result->rawBuffers[0], BUFFER_SIZE);
        AudioQueueEnqueueBuffer(result->queue, result->buffers[i], 0, NULL);
    }
    vgsdec_execute(result->vgsdec, result->rawBuffers[1], BUFFER_SIZE); // decode next
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

void vgsplay_start(const char* mmlPath, int loop, int infinity, int seek, int numberOfBuffer)
{
    vgsplay_stop();
    pthread_mutex_lock(&fs_mutex);
    fs_context = internal_sound_create(mmlPath, loop, infinity, seek, numberOfBuffer);
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

unsigned int vgsplay_getCurrentTime()
{
    unsigned int result = 0;
    pthread_mutex_lock(&fs_mutex);
    if (fs_context) {
        pthread_mutex_lock(&fs_context->mutex);
        result = (unsigned int)vgsdec_get_value(fs_context->vgsdec, VGSDEC_REG_TIME);
        pthread_mutex_unlock(&fs_context->mutex);
    }
    pthread_mutex_unlock(&fs_mutex);
    return result;
}

void vgsplay_seek(unsigned int time)
{
    pthread_mutex_lock(&fs_mutex);
    if (fs_context) {
        pthread_mutex_lock(&fs_context->mutex);
        vgsdec_set_value(fs_context->vgsdec, VGSDEC_REG_TIME, (int)time);
        pthread_mutex_unlock(&fs_context->mutex);
    }
    pthread_mutex_unlock(&fs_mutex);
}

int vgsplay_isPlaying()
{
    int result = 0;
    pthread_mutex_lock(&fs_mutex);
    if (fs_context && fs_context->vgsdec) {
        pthread_mutex_lock(&fs_context->mutex);
        result = vgsdec_get_value(fs_context->vgsdec, VGSDEC_REG_PLAYING);
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
