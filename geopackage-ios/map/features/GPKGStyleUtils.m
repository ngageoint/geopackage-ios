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

+(BOOL) setFeatureStyleWithPolyline: (GPKGPolyline *) polyline andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow{
    
    GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage];
    
    return [self setFeatureStyleWithPolyline:polyline andExtension:featureStyleExtension andFeature:featureRow];
}

+(BOOL) setFeatureStyleWithPolyline: (GPKGPolyline *) polyline andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow{
    
    GPKGFeatureStyle *featureStyle = [featureStyleExtension featureStyleWithFeature:featureRow];
    
    return [self setFeatureStyleWithPolyline:polyline andFeatureStyle:featureStyle];
}

+(BOOL) setFeatureStyleWithPolyline: (GPKGPolyline *) polyline andFeatureStyle: (GPKGFeatureStyle *) featureStyle{
    
    BOOL featureStyleSet = NO;
    
    if (featureStyle != nil) {
        
        featureStyleSet = [self setStyleWithPolyline:polyline andStyle:featureStyle.style];
        
    }
    
    return featureStyleSet;
}

+(BOOL) setStyleWithPolyline: (GPKGPolyline *) polyline andStyle: (GPKGStyleRow *) style{

    if (style != nil) {
        
        GPKGPolylineOptions *options = [[GPKGPolylineOptions alloc] init];
        
        GPKGColor *color = [style colorOrDefault];
        options.strokeColor = [color uiColor];
        
        options.lineWidth = [style widthOrDefault];
        
        [polyline setOptions:options];
    }
    
    return style != nil;
}

+(BOOL) setFeatureStyleWithPolygon: (GPKGPolygon *) polygon andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow{
    
    GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage];
    
    return [self setFeatureStyleWithPolygon:polygon andExtension:featureStyleExtension andFeature:featureRow];
}

+(BOOL) setFeatureStyleWithPolygon: (GPKGPolygon *) polygon andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow{
    
    GPKGFeatureStyle *featureStyle = [featureStyleExtension featureStyleWithFeature:featureRow];
    
    return [self setFeatureStyleWithPolygon:polygon andFeatureStyle:featureStyle];
}

+(BOOL) setFeatureStyleWithPolygon: (GPKGPolygon *) polygon andFeatureStyle: (GPKGFeatureStyle *) featureStyle{
    
    BOOL featureStyleSet = NO;
    
    if (featureStyle != nil) {
        
        featureStyleSet = [self setStyleWithPolygon:polygon andStyle:featureStyle.style];
        
    }
    
    return featureStyleSet;
}

+(BOOL) setStyleWithPolygon: (GPKGPolygon *) polygon andStyle: (GPKGStyleRow *) style{
    
    if (style != nil) {
        
        GPKGPolygonOptions *options = [[GPKGPolygonOptions alloc] init];
        
        GPKGColor *color = [style colorOrDefault];
        options.strokeColor = [color uiColor];
        
        options.lineWidth = [style widthOrDefault];
        
        GPKGColor *fillColor = [style fillColor];
        if(fillColor != nil){
            options.fillColor = [fillColor uiColor];
        }
        
        [polygon setOptions:options];
    }
    
    return style != nil;
}

@end
