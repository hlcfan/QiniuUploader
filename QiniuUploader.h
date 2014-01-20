//
//  QiniuSimpleUploader.h
//  QiniuSimpleUploader
//
//  Created by Qiniu Developers 2013
//

#import <Foundation/Foundation.h>
#import "QiniuPutExtra.h"

@interface QiniuUploader : NSObject

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) NSString *accessKey;
@property (nonatomic, strong) NSString *secretKey;

- (id)initWithAccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey;

- (void) uploadFile:(NSArray *)filesInfo progress:(void(^)(float percentage))progressBlock complete:(void(^)(NSMutableDictionary *result)) block;

- (BOOL)startUploadFiles:(NSArray *)uploadArray progress:(void(^)(float percentage))progressBlock complete:(void(^)(NSMutableDictionary *result)) block;

@end
