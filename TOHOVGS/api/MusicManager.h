//
//  MusicManager.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/13.
//

#import <Foundation/Foundation.h>
#import "../model/Album.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicManager : NSObject
@property (nonatomic, readonly) NSArray<Album*>* albums;
@property (nonatomic, readonly) NSArray<Song*>* allUnlockedSongs;
@end

NS_ASSUME_NONNULL_END
