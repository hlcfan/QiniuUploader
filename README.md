QiniuUploader
=============

QiniuUploader for iOS

### Usage:

0. Import header file
`#import "QiniuUploader.h"`

1. Prepare fileInfo before upload.
``` Objective-C
NSDictionary *avatarHash = [QiniuUploader prepareUploadContent: self.avatarInfo filename: @"avatar" format: @"jpg" bucket: QiniuAvatarBucketName imageCompress: nil];
NSMutableArray *uploadArray = [NSMutalbeArray arrayWithObject: avatarHash];
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
