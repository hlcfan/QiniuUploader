// QiniuUploader by @hlcfan

#import <Foundation/Foundation.h>
#import "QiniuPutExtra.h"

@interface QiniuUploader : NSObject

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) NSString *accessKey;

@property (nonatomic, strong) NSString *secretKey;

+ (NSDictionary *)prepareUploadContent:(NSDictionary *)theInfo filename:(NSString *)filename format:(NSString*)format bucket: (NSString *)bucket imageCompress:(UIImage*(^)(UIImage *image)) block;

- (id)initWithAccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey;

- (void)startUploadFiles:(NSArray *)uploadArray progress:(void(^)(float percentage))progressBlock complete:(void(^)(NSMutableDictionary *result)) block;

@end
