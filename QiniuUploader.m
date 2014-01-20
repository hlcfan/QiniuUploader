// QiniuUploader by @hlcfan

#import "QiniuConfig.h"
#import "QiniuUploader.h"
#import "GTMBase64/GTMBase64.h"
#import "JSONKit/JSONKit.h"
#import <AFNetworking.h>
#import "QiniuPutPolicy.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define kQiniuUserAgent  @"qiniu-ios-sdk"


@interface QiniuUploader ()
@property (nonatomic, strong) AFURLSessionManager *manager;
@end

@implementation QiniuUploader

- (id)initWithAccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey {
    if (self = [super init]) {
        self.accessKey = accessKey;
        self.secretKey = secretKey;
    }
    return self;
}

- (NSString *)tokenWithScope:(NSString *)scope {
    QiniuPutPolicy *policy = [QiniuPutPolicy new];
    policy.scope = scope;
    
    return [policy makeToken:self.accessKey secretKey:self.secretKey];
}

- (void) uploadFile:(NSArray *)filesInfo progress:(void(^)(float percentage))progressBlock complete:(void(^)(NSMutableDictionary *result)) block {
    NSMutableArray *mutableOperations = [NSMutableArray array];
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    for (NSDictionary *fileData in filesInfo) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:[fileData objectForKey:@"token"] forKey:@"token"];
        
        if (![[fileData objectForKey:@"key"] isEqualToString:kQiniuUndefinedKey]) {
            [params setObject:[fileData objectForKey:@"key"] forKey:@"key"];
        }
        NSString *mimeType = nil;
        QiniuPutExtra *extra = (QiniuPutExtra*)[fileData objectForKey:@"extra"];
        if (extra) {
            mimeType = extra.mimeType;
            if (extra.checkCrc == 1) {
                [params setObject: [NSString stringWithFormat:@"%ld", extra.crc32] forKey:@"crc32"];
            }
            for (NSString *key in extra.params) {
                [params setObject:[extra.params objectForKey:key] forKey:key];
            }
        }

        NSString *filePath = [fileData objectForKey:@"filepath"];
        NSURL *fileURL = [NSURL fileURLWithPath: filePath];
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:kQiniuUpHost parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (mimeType != nil) {
                [formData appendPartWithFileURL:fileURL name:@"file" fileName:filePath mimeType:mimeType error:nil];
            } else {
                [formData appendPartWithFileURL:fileURL name:@"file" error:nil];
            }
        }];
        [request setValue:kQiniuUserAgent forHTTPHeaderField:@"User-Agent"];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [mutableOperations addObject:operation];
    }
    __block BOOL all_success = YES;
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        if(progressBlock) progressBlock((float)numberOfFinishedOperations / totalNumberOfOperations);
//        NSLog(@"%d of %d complete", numberOfFinishedOperations, totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        [ret setObject:operations forKey:@"operations"];
        for (AFHTTPRequestOperation *op in operations) {
            if ([[op response] statusCode] != 200 || op == nil) {
                all_success = NO;
                break;
            }
        }
        [ret setObject:[NSNumber numberWithBool:all_success] forKey:@"success"];
        if (block) block(ret);
    }];
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

+ (NSDictionary *)prepareUploadContent:(NSDictionary *)theInfo filename:(NSString *)filename format:(NSString*)format bucket: (NSString *)bucket imageCompress:(UIImage*(^)(UIImage *image)) block {
    //extracting image from the picker and saving it
    NSString *mediaType = [theInfo objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage] || [mediaType isEqualToString:(NSString *)ALAssetTypePhoto]) {
        NSString *key = [NSString stringWithFormat:@"%@%@", filename, format];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:key];
        NSLog(@"Upload Path: %@", filePath);
        UIImage *newImage;
        if(block) {
            newImage = block([theInfo objectForKey:UIImagePickerControllerOriginalImage]);
        }else{
            newImage = [theInfo objectForKey:UIImagePickerControllerOriginalImage];
        }
//        UIImage *ori_image = [theInfo objectForKey:UIImagePickerControllerOriginalImage];
//        CGSize newSize = CGSizeMake(100.0f, 100.0f);
//        UIGraphicsBeginImageContext(newSize);
//        [ori_image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
        NSData *webData = UIImageJPEGRepresentation(newImage, 1);
        [webData writeToFile:filePath atomically:YES];
        NSDictionary *upload_data = [NSDictionary dictionaryWithObjectsAndKeys: @YES, @"success", filePath, @"filepath", bucket, @"bucket", key, @"key", nil];
        return upload_data;
    }else {
        return @{@"success": @NO};
    }
}

- (BOOL)startUploadFiles:(NSArray *)uploadArray progress:(void(^)(float percentage))progressBlock complete:(void(^)(NSMutableDictionary *result)) block {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *item in uploadArray) {
        NSLog(@"===Item:%@", [item objectForKey:@"filepath"]);
        if ([manager fileExistsAtPath:[item objectForKey:@"filepath"]]) {
            NSLog(@"Scope:%@", [NSString stringWithFormat:@"%@:%@", [item objectForKey:@"bucket"], [item objectForKey:@"key"]]);
            NSDictionary *uploadData = [NSDictionary dictionaryWithObjectsAndKeys: [item objectForKey:@"filepath"], @"filepath", [self tokenWithScope:[NSString stringWithFormat:@"%@:%@", [item objectForKey:@"bucket"], [item objectForKey:@"key"]]], @"token", [item objectForKey:@"key"], @"key", nil];
            [array addObject:uploadData];
        }
    }
    [self uploadFile:array progress:^(float percentage) {
        if(progressBlock) progressBlock(percentage);
    } complete:^(NSMutableDictionary *result) {
        if(block) block(result);
    }];
    return YES;
}

@end
