//
//  ImageStore.m
//  zhxq
//
//  Created by Seven on 13-9-22.
//
//

#import "ImageStore.h"

@implementation ImageStore
+ (ImageStore *)Instance
{
    static ImageStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:NULL] init];
    }
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self Instance];
}

- (id)init
{
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] init];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)setImage:(UIImage *)i forKey:(NSString *)s
{
    [dictionary setObject:i forKey:s];
    
    NSString *imagePath = [self imagePathForKey:s];
    NSData *d = UIImageJPEGRepresentation(i, 0.5);
    [d writeToFile:imagePath atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)s
{
    //return [dictionary objectForKey:s];
    UIImage *result = [dictionary objectForKey:s];
    if (!result)
    {
        result = [UIImage imageWithContentsOfFile:[self imagePathForKey:s]];
        if (result)
        {
            [dictionary setObject:result forKey:s];
        }
        else
        {
            NSLog(@"Error: unable to find %@", [self imagePathForKey:s]);
        }
    }
    return result;
}

- (void)deleteImageForKey:(NSString *)s
{
    if (!s)
    {
        return;
    }
    [dictionary removeObjectForKey:s];
    
    NSString *imagePath = [self imagePathForKey:s];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:NULL];
}

- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (void)clearCache:(NSNotification *)note
{
    NSLog(@"flushing %d images out of the cache", [dictionary count]);
    [dictionary removeAllObjects];
}

@end
