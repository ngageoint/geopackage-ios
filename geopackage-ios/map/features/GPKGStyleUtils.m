//
//  GPKGStyleUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyleUtils.h"

@implementation GPKGStyleUtils

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow andScale: (float) scale{
    return [self setFeatureStyleWithMapPoint:mapPoint andGeoPackage:geoPackage andFeature:featureRow andScale:scale andIconCache:nil];
}

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow andScale: (float) scale andIconCache: (GPKGIconCache *) iconCache{
    
    GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage];
    
    return [self setFeatureStyleWithMapPoint:mapPoint andExtension:featureStyleExtension andFeature:featureRow andScale:scale andIconCache:iconCache];
}

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow andScale: (float) scale{
    return [self setFeatureStyleWithMapPoint:mapPoint andExtension:featureStyleExtension andFeature:featureRow andScale:scale andIconCache:nil];
}

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow andScale: (float) scale andIconCache: (GPKGIconCache *) iconCache{
    
    GPKGFeatureStyle *featureStyle = [featureStyleExtension featureStyleWithFeature:featureRow];
    
    return [self setFeatureStyleWithMapPoint:mapPoint andFeatureStyle:featureStyle andScale:scale andIconCache:iconCache];
}

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andFeatureStyle: (GPKGFeatureStyle *) featureStyle andScale: (float) scale{
    return [self setFeatureStyleWithMapPoint:mapPoint andFeatureStyle:featureStyle andScale:scale andIconCache:nil];
}

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andFeatureStyle: (GPKGFeatureStyle *) featureStyle andScale: (float) scale andIconCache: (GPKGIconCache *) iconCache{
    
    BOOL featureStyleSet = NO;
    
    if (featureStyle != nil) {
        
        featureStyleSet = [self setIconWithMapPoint:mapPoint andIcon:featureStyle.icon andScale:scale andIconCache:iconCache];
        
        if(!featureStyleSet){
            
            featureStyleSet = [self setStyleWithMapPoint:mapPoint andStyle:featureStyle.style];
            
        }
        
    }
    
    return featureStyleSet;
}

+(BOOL) setIconWithMapPoint: (GPKGMapPoint *) mapPoint andIcon: (GPKGIconRow *) icon andScale: (float) scale{
    return [self setIconWithMapPoint:mapPoint andIcon:icon andScale:scale andIconCache:nil];
}

+(BOOL) setIconWithMapPoint: (GPKGMapPoint *) mapPoint andIcon: (GPKGIconRow *) icon andScale: (float) scale andIconCache: (GPKGIconCache *) iconCache{
    
    BOOL iconSet = NO;
    
    if (icon != nil) {
        
        UIImage *iconImage = [self createIconImageWithIcon:icon andScale:scale andIconCache:iconCache];
        [mapPoint.options setImage:iconImage];
        iconSet = YES;
        
        double anchorU = [icon anchorUOrDefault];
        double anchorV = [icon anchorVOrDefault];
        
        [mapPoint.options anchorWithU:anchorU andV:anchorV];
    }
    
    return iconSet;
}

+(UIImage *) createIconImageWithIcon: (GPKGIconRow *) icon andScale: (float) scale{
    return [GPKGIconCache createIconNoCacheForRow:icon withScale:scale];
}

+(UIImage *) createIconImageWithIcon: (GPKGIconRow *) icon andScale: (float) scale andIconCache: (GPKGIconCache *) iconCache{
    return [iconCache createIconForRow:icon withScale:scale];
}

+(BOOL) setStyleWithMapPoint: (GPKGMapPoint *) mapPoint andStyle: (GPKGStyleRow *) style{
    
    BOOL styleSet = NO;
    
    if (style != nil) {
        GPKGColor *color = [style colorOrDefault];
        UIColor *uiColor = [color uiColor];
        [mapPoint.options setPinTintColor:uiColor];
        styleSet = YES;
    }
    
    return styleSet;
}

+(BOOL) setFeatureStyleWithPolyline: (MKPolylineRenderer *) polylineRenderer andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow andScale: (float) scale{
    
    GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage];
    
    return [self setFeatureStyleWithPolyline:polylineRenderer andExtension:featureStyleExtension andFeature:featureRow andScale:scale];
}

+(BOOL) setFeatureStyleWithPolyline: (MKPolylineRenderer *) polylineRenderer andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow andScale: (float) scale{
    
    GPKGFeatureStyle *featureStyle = [featureStyleExtension featureStyleWithFeature:featureRow];
    
    return [self setFeatureStyleWithPolyline:polylineRenderer andFeatureStyle:featureStyle andScale:scale];
}

+(BOOL) setFeatureStyleWithPolyline: (MKPolylineRenderer *) polylineRenderer andFeatureStyle: (GPKGFeatureStyle *) featureStyle andScale: (float) scale{
    
    BOOL featureStyleSet = NO;
    
    if (featureStyle != nil) {
        
        featureStyleSet = [self setStyleWithPolyline:polylineRenderer andStyle:featureStyle.style andScale:scale];
        
    }
    
    return featureStyleSet;
}

+(BOOL) setStyleWithPolyline: (MKPolylineRenderer *) polylineRenderer andStyle: (GPKGStyleRow *) style andScale: (float) scale{

    if (style != nil) {
        
        GPKGColor *color = [style colorOrDefault];
        polylineRenderer.strokeColor = [color uiColor];
        
        double width = [style widthOrDefault];
        polylineRenderer.lineWidth = width * scale;
        
    }
    
    return style != nil;
}

@end
