QiniuUploader
=============

QiniuUploader for iOS with AFNetworking 2.0 - single image or multi images supported

### Prepare

install AFNetworking 2.0

`pod "AFNetworking", "~> 2.0"`

### Usage:

0. Import header file
`#import "QiniuUploader.h"`

1. Prepare fileInfo before upload.
``` Objective-C
NSDictionary *avatarHash = [QiniuUploader prepareUploadContent: self.avatarInfo filename: @"avatar" format: @"jpg" bucket: QiniuAvatarBucketName imageCompress: nil];
NSDictionary *avatar2Hash = ...
NSMutableArray *uploadArray = [NSMutalbeArray arrayWithObjects: avatarHash, ..., nil];
```

2. Upload!
``` Objective-C
QiniuUploader *uploader = [[QiniuUploader alloc] initWithAccessKey: QiniuAccessKey secretKey: QiniuSecretKey];
  [uploader startUploadFiles:uploadArray progress:^(float percentage) {
    NSLog(@"===Percent:%f", percentage);
  } complete:^(NSMutableDictionary *result) {
      if([[result objectForKey:@"success"] boolValue]){
        NSLog(@"===upload success");
      }else{
        NSLog(@"===upload fail");
      }
  }];
```

### Compress upload image

``` Objective-C
NSDictionary *avatar2Hash = [QiniuUploader prepareUploadContent:self.bannerInfo filename:@"avatar" format:@"jpg" bucket: QiniuAvatarBucketName imageCompress:^UIImage *(UIImage *image) {
    CGSize newSize = CGSizeMake(100.0f, 100.0f);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}];

```

