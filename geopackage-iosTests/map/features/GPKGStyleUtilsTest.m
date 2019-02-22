//
//  GPKGStyleUtilsTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/22/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyleUtilsTest.h"
#import "GPKGImageConverter.h"
#import "GPKGIconRow.h"
#import "GPKGStyleUtils.h"
#import "GPKGTestUtils.h"

@implementation GPKGStyleUtilsTest

/**
 * Test set icon
 */
-(void) testSetIcon{
    
    float scale = [UIScreen mainScreen].nativeScale;
    
    [self testSetIconWithScale:scale andImageWidth:40 andImageHeight:40 andIconWidth:30.0 andIconHeight:20.0];
    [self testSetIconWithScale:scale andImageWidth:40 andImageHeight:40 andIconWidth:200.0 andIconHeight:160.0];
    [self testSetIconWithScale:scale andImageWidth:40 andImageHeight:40 andIconWidth:10.0 andIconHeight:5.0];
    [self testSetIconWithScale:scale andImageWidth:40 andImageHeight:40 andIconWidth:200.0 andIconHeight:10.0];
    
    [self testSetIconWithScale:scale andImageWidth:40 andImageHeight:40 andIconWidth:30.0 andIconHeightNumber:nil];
    [self testSetIconWithScale:scale andImageWidth:40 andImageHeight:40 andIconWidthNumber:nil andIconHeight:160.0];
    [self testSetIconWithScale:scale andImageWidth:40 andImageHeight:40 andIconWidthNumber:nil andIconHeightNumber:nil];
    
    [self testSetIconWithScale:scale andImageWidth:40 andImageHeight:80 andIconWidth:20.0 andIconHeight:40.0];
    [self testSetIconWithScale:scale andImageWidth:40 andImageHeight:80 andIconWidth:80.0 andIconHeight:160.0];
    [self testSetIconWithScale:scale andImageWidth:40 andImageHeight:80 andIconWidth:10.0 andIconHeight:20.0];

    [self testSetIconWithScale:scale andImageWidth:32 andImageHeight:37 andIconWidth:23.0 andIconHeight:31.0];
    [self testSetIconWithScale:scale andImageWidth:32 andImageHeight:37 andIconWidth:119.0 andIconHeight:130.0];
    [self testSetIconWithScale:scale andImageWidth:32 andImageHeight:37 andIconWidth:7.0 andIconHeight:4.0];
    [self testSetIconWithScale:scale andImageWidth:32 andImageHeight:37 andIconWidth:165.0 andIconHeight:9.0];
    
    [self testSetIconWithScale:scale andImageWidth:32 andImageHeight:37 andIconWidth:23.0 andIconHeightNumber:nil];
    [self testSetIconWithScale:scale andImageWidth:32 andImageHeight:37 andIconWidthNumber:nil andIconHeight:160.0];
    [self testSetIconWithScale:scale andImageWidth:32 andImageHeight:37 andIconWidthNumber:nil andIconHeightNumber:nil];
    
    for (int i = 0; i < 100; i++) {
        scale = 1.0 + [GPKGTestUtils randomDoubleLessThan:3.0];
        int imageWidth = 1 + [GPKGTestUtils randomIntLessThan:100];
        int imageHeight = 1 + [GPKGTestUtils randomIntLessThan:100];
        double iconWidth = 1 + [GPKGTestUtils randomDoubleLessThan:100.0];
        double iconHeight = 1 + [GPKGTestUtils randomDoubleLessThan:100.0];
        [self testSetIconWithScale:scale andImageWidth:imageWidth andImageHeight:imageHeight andIconWidth:iconWidth andIconHeight:iconHeight];
    }
    
    for (int i = 0; i < 100; i++) {
        scale = 1.0 + [GPKGTestUtils randomDoubleLessThan:3.0];
        int imageWidth = 1 + [GPKGTestUtils randomIntLessThan:100];
        int imageHeight = 1 + [GPKGTestUtils randomIntLessThan:100];
        [self testSetIconWithScale:scale andImageWidth:imageWidth andImageHeight:imageHeight andIconWidthNumber:nil andIconHeightNumber:nil];
    }
    
}

-(void) testSetIconWithScale: (float) scale andImageWidth: (int) imageWidth andImageHeight: (int) imageHeight andIconWidth: (double) iconWidth andIconHeight: (double) iconHeight{
    [self testSetIconWithScale:scale andImageWidth:imageWidth andImageHeight:imageHeight andIconWidthNumber:[[NSDecimalNumber alloc] initWithDouble:iconWidth] andIconHeightNumber:[[NSDecimalNumber alloc] initWithDouble:iconHeight]];
}

-(void) testSetIconWithScale: (float) scale andImageWidth: (int) imageWidth andImageHeight: (int) imageHeight andIconWidthNumber: (NSDecimalNumber *) iconWidth andIconHeight: (double) iconHeight{
    [self testSetIconWithScale:scale andImageWidth:imageWidth andImageHeight:imageHeight andIconWidthNumber:iconWidth andIconHeightNumber:[[NSDecimalNumber alloc] initWithDouble:iconHeight]];
}

-(void) testSetIconWithScale: (float) scale andImageWidth: (int) imageWidth andImageHeight: (int) imageHeight andIconWidth: (double) iconWidth andIconHeightNumber: (NSDecimalNumber *) iconHeight{
    [self testSetIconWithScale:scale andImageWidth:imageWidth andImageHeight:imageHeight andIconWidthNumber:[[NSDecimalNumber alloc] initWithDouble:iconWidth] andIconHeightNumber:iconHeight];
}

-(void) testSetIconWithScale: (float) scale andImageWidth: (int) imageWidth andImageHeight: (int) imageHeight andIconWidthNumber: (NSDecimalNumber *) iconWidth andIconHeightNumber: (NSDecimalNumber *) iconHeight{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, imageWidth, imageHeight);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *data = [GPKGImageConverter toData:image andFormat:GPKG_CF_PNG];
    
    GPKGIconRow *icon = [[GPKGIconRow alloc] init];
    [icon setData:data];
    [icon setWidth:iconWidth];
    [icon setHeight:iconHeight];
    
    double styleWidth;
    double styleHeight;
    
    if (iconWidth == nil && iconHeight == nil) {
        styleWidth = imageWidth;
        styleHeight = imageHeight;
    } else if (iconWidth != nil && iconHeight != nil) {
        styleWidth = [iconWidth doubleValue];
        styleHeight = [iconHeight doubleValue];
    } else if (iconWidth != nil) {
        styleWidth = [iconWidth doubleValue];
        styleHeight = ([iconWidth doubleValue] / imageWidth) * imageHeight;
    } else {
        styleHeight = [iconHeight doubleValue];
        styleWidth = ([iconHeight doubleValue] / imageHeight) * imageWidth;
    }
    
    UIImage *iconImage = [GPKGStyleUtils createIconImageWithIcon:icon andScale:scale];
    [GPKGTestUtils assertNotNil:iconImage];
    
    double expectedWidth = scale * styleWidth;
    double expectedHeight = scale * styleHeight;
    
    int lowerWidth = (int)floor(expectedWidth - 0.5);
    int upperWidth = (int)ceil(expectedWidth + 0.5);
    int lowerHeight = (int)floor(expectedHeight - 0.5);
    int upperHeight = (int)ceil(expectedHeight + 0.5);
    
    [GPKGTestUtils assertTrue:iconImage.size.width >= lowerWidth && iconImage.size.width <= upperWidth];
    [GPKGTestUtils assertTrue:iconImage.size.height >= lowerHeight && iconImage.size.height <= upperHeight];
    
}

@end
