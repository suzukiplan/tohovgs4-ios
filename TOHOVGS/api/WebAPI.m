/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import "WebAPI.h"
#import "../ServerSettings.h"
#import "../model/SongList.h"
#include <CommonCrypto/CommonDigest.h>
#include <pthread.h>

#define REQUEST_TIMEDOUT_SECONDS 5

@interface WebAPI() <NSURLSessionDelegate>
@property (nonatomic) NSURLSession* session;
@end

@implementation WebAPI

- (instancetype)init
{
    if (self = [super init]) {
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = REQUEST_TIMEDOUT_SECONDS;
        config.timeoutIntervalForResource = 20;
        _session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:nil
                                            delegateQueue:nil];
    }
    return self;
}

- (void)checkUpdateWithCurrentSHA1:(NSString *)sha1
                              done:(void(^)(NSError * _Nullable, BOOL))done
{
    [self _httpGet:@"songlist.sha1" done:^(NSError* error, NSString* response) {
        if (error || !response) {
            NSLog(@"checkUpdateWithCurrentSHA1 failed: %@", error);
            done(error, NO);
        } else {
            NSLog(@"client SHA1: %@", sha1);
            NSLog(@"server SHA1: %@", response);
            done(nil, 0 != strncasecmp(sha1.UTF8String, response.UTF8String, CC_SHA1_DIGEST_LENGTH * 2));
        }
    }];
}

- (void)acquireSongList:(void(^)(NSError* _Nullable, SongList* _Nullable))done
{
    [self _httpGet:@"songlist.json" done:^(NSError* error, NSString* response) {
        if (error || !response) {
            NSLog(@"acquireSongList failed: %@", error);
            done(error, nil);
        } else {
            done(nil, [SongList fromJsonString:response]);
        }
    }];
}

- (void)acquireMmlWithSong:(Song*)song
                      done:(void(^)(NSError* _Nullable, NSString* _Nullable))done
{
    NSString* mml = [NSString stringWithFormat:@"%@.mml", song.mml];
    [self _httpGet:mml done:^(NSError* error, NSString* response) {
        if (error || !response) {
            NSLog(@"acquireSongList failed: %@", error);
            done(error, nil);
        } else {
            NSLog(@"download mml succeed: %ld bytes", response.length);
            done(nil, response);
        }
    }];
}

- (void)_httpGet:(NSString*)path
            done:(void(^)(NSError* _Nullable error, NSString* _Nullable response))done
{
    NSLog(@"get %@", path);
    __weak WebAPI* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* urlString = [NSString stringWithFormat:@"%@%@", API_SERVER_BASE_URL, path];
        NSURL* url = [NSURL URLWithString:urlString];
        NSURLRequest* request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                             timeoutInterval:REQUEST_TIMEDOUT_SECONDS];
        NSURLSessionDataTask* task;
        task = [weakSelf.session dataTaskWithRequest:request
                                   completionHandler:^(NSData* _Nullable data,
                                                       NSURLResponse* _Nullable response,
                                                       NSError* _Nullable error) {
            if (error || !data || !response || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                    done([NSError errorWithDomain:NSNetServicesErrorDomain
                                             code:httpResponse.statusCode
                                         userInfo:nil], nil);
                } else {
                    done(error, nil);
                }
                return;
            }
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            if (200 != httpResponse.statusCode) {
                done([NSError errorWithDomain:NSNetServicesErrorDomain
                                         code:httpResponse.statusCode
                                     userInfo:nil], nil);
            } else {
                done(nil, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }];
        [task resume];
    });
}

@end
