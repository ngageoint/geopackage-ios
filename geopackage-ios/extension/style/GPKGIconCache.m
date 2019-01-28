//
//  GPKGIconCache.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGIconCache.h"
#import "LruCache.h"

@interface GPKGIconCache ()

/**
 * Icon image cache
 */
@property (nonatomic, strong) LruCache *iconCache;

@end

@implementation GPKGIconCache

-(instancetype) init{
    self = [self initWithSize:DEFAULT_ICON_CACHE_SIZE];
    return self;
}

-(instancetype) initWithSize: (int) size{
    self = [super init];
    if(self != nil){
        self.iconCache = [[LruCache alloc] initWithMaxSize:size];
    }
    return self;
}

-(UIImage *) imageForRow: (GPKGIconRow *) iconRow{
    return [self imageForId:[iconRow id]];
}

-(UIImage *) imageForId: (int) iconRowId{
    return [self.iconCache get:[self idKey:iconRowId]];
}

-(UIImage *) putImage: (UIImage *) image forRow: (GPKGIconRow *) iconRow{
    return [self.iconCache put:[self rowKey:iconRow] value:image];
}

-(UIImage *) putImage: (UIImage *) image forId: (int) iconRowId{
    return [self.iconCache put:[self idKey:iconRowId] value:image];
}

-(UIImage *) removeForRow: (GPKGIconRow *) iconRow{
    return [self.iconCache remove:[self rowKey:iconRow]];
}

-(UIImage *) removeForId: (int) iconRowId{
    return [self.iconCache remove:[self idKey:iconRowId]];
}

-(void) clear{
    [self.iconCache evictAll];
}

-(void) resizeWithSize: (int) maxSize{
    [self.iconCache resize:maxSize];
}

-(UIImage *) createIconForRow: (GPKGIconRow *) icon{
    return [self createIconForRow:icon withScale:[UIScreen mainScreen].scale];
}

-(UIImage *) createIconForRow: (GPKGIconRow *) icon withScale: (float) scale{
    return [GPKGIconCache createIconForRow:icon fromCache:self withScale:scale];
}

+(UIImage *) createIconNoCacheForRow: (GPKGIconRow *) icon{
    return [self createIconNoCacheForRow:icon withScale:[UIScreen mainScreen].scale];
}

+(UIImage *) createIconNoCacheForRow: (GPKGIconRow *) icon withScale: (float) scale{
    return [self createIconForRow:icon fromCache:nil withScale:scale];
}

+(UIImage *) createIconForRow: (GPKGIconRow *) icon fromCache: (GPKGIconCache *) iconCache{
    return [self createIconForRow:icon fromCache:iconCache withScale:[UIScreen mainScreen].scale];
}

+(UIImage *) createIconForRow: (GPKGIconRow *) icon fromCache: (GPKGIconCache *) iconCache withScale: (float) scale{

    UIImage *iconImage = nil;
    
    if (icon != nil) {
        
        if (iconCache != nil) {
            iconImage = [iconCache imageForRow:icon];
        }
        
        if (iconImage == nil) {
            
            NSDictionary *imageSourceProperties = [icon dataImageSourceProperties];
            int dataWidth = [[imageSourceProperties objectForKey:(NSString *)kCGImagePropertyPixelWidth] intValue];
            int dataHeight = [[imageSourceProperties objectForKey:(NSString *)kCGImagePropertyPixelHeight] intValue];
            
            double styleWidth = dataWidth;
            double styleHeight = dataHeight;
            
            double widthScale = 1.0;
            double heightScale = 1.0;
            
            if([icon width] != nil){
                styleWidth = [[icon width] doubleValue];
                widthScale = dataWidth / styleWidth;
                if([icon height] == nil){
                    heightScale = widthScale;
                }
            }
            
            if([icon height] != nil){
                styleHeight = [[icon height] doubleValue];
                heightScale = dataHeight / styleHeight;
                if([icon width] == nil){
                    widthScale = heightScale;
                }
            }
            
            float dataScale = scale / MIN(widthScale, heightScale);
            iconImage = [icon dataImageWithScale:dataScale];
            
            if (widthScale != heightScale) {
                
                float width = styleWidth * scale;
                float height = styleHeight * scale;
                
                if (width != iconImage.size.width || height != iconImage.size.height) {
                    
                    UIGraphicsBeginImageContext(CGSizeMake(width, height));
                    [iconImage drawInRect:CGRectMake(0, 0, width, height)];
                    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    iconImage = scaledImage;
                }
                
            }
            
            if (iconCache != nil) {
                [iconCache putImage:iconImage forRow:icon];
            }
        }
        
    }
    
    return iconImage;
}

-(NSString *) rowKey: (GPKGIconRow *) iconRow{
    return [self idKey:[iconRow id]];
}

-(NSString *) idKey: (int) iconRowId{
    return [NSString stringWithFormat:@"%d", iconRowId];
}

@end
