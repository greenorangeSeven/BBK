//
//  ImageStore.h
//  zhxq
//
//  Created by Seven on 13-9-22.
//
//

#import <Foundation/Foundation.h>

@interface ImageStore : NSObject
{
    NSMutableDictionary *dictionary;
}
+ (ImageStore *)Instance;

- (void)setImage:(UIImage *)i forKey:(NSString *)s;
- (UIImage *)imageForKey:(NSString *)s;
- (void)deleteImageForKey:(NSString *)s;
- (NSString *)imagePathForKey:(NSString *)key;
@end
