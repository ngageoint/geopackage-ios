//
//  GPKGStyleUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyleUtils.h"

@implementation GPKGStyleUtils

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow{
    return [self setFeatureStyleWithMapPoint:mapPoint andGeoPackage:geoPackage andFeature:featureRow andIconCache:nil];
}

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow andIconCache: (GPKGIconCache *) iconCache{
    
    GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage];
    
    return [self setFeatureStyleWithMapPoint:mapPoint andExtension:featureStyleExtension andFeature:featureRow andIconCache:iconCache];
}

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow{
    return [self setFeatureStyleWithMapPoint:mapPoint andExtension:featureStyleExtension andFeature:featureRow andIconCache:nil];
}

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow andIconCache: (GPKGIconCache *) iconCache{
    
    GPKGFeatureStyle *featureStyle = [featureStyleExtension featureStyleWithFeature:featureRow];
    
    return [self setFeatureStyleWithMapPoint:mapPoint andFeatureStyle:featureStyle andIconCache:iconCache];
}

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andFeatureStyle: (GPKGFeatureStyle *) featureStyle{
    return [self setFeatureStyleWithMapPoint:mapPoint andFeatureStyle:featureStyle andIconCache:nil];
}

+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andFeatureStyle: (GPKGFeatureStyle *) featureStyle andIconCache: (GPKGIconCache *) iconCache{
    
    BOOL featureStyleSet = NO;
    
    if (featureStyle != nil) {
        
        featureStyleSet = [self setIconWithMapPoint:mapPoint andIcon:featureStyle.icon andIconCache:iconCache];
        
        if(!featureStyleSet){
            
            featureStyleSet = [self setStyleWithMapPoint:mapPoint andStyle:featureStyle.style];
            
        }
        
    }
    
    return featureStyleSet;
}

+(BOOL) setIconWithMapPoint: (GPKGMapPoint *) mapPoint andIcon: (GPKGIconRow *) icon{
    return [self setIconWithMapPoint:mapPoint andIcon:icon andIconCache:nil];
}

+(BOOL) setIconWithMapPoint: (GPKGMapPoint *) mapPoint andIcon: (GPKGIconRow *) icon andIconCache: (GPKGIconCache *) iconCache{
    
    BOOL iconSet = NO;
    
    if (icon != nil) {
        
        UIImage *iconImage = [self createIconImageWithIcon:icon andIconCache:iconCache];
        [mapPoint.options setImage:iconImage];
        iconSet = YES;
        
        double anchorU = [icon anchorUOrDefault];
        double anchorV = [icon anchorVOrDefault];
        
        [mapPoint.options anchorWithU:anchorU andV:anchorV];
    }
    
    return iconSet;
}

+(UIImage *) createIconImageWithIcon: (GPKGIconRow *) icon{
    return [GPKGIconCache createIconNoCacheForRow:icon];
}

+(UIImage *) createIconImageWithIcon: (GPKGIconRow *) icon andIconCache: (GPKGIconCache *) iconCache{
    return [iconCache createIconForRow:icon];
}

+(BOOL) setStyleWithMapPoint: (GPKGMapPoint *) mapPoint andStyle: (GPKGStyleRow *) style{
    
    BOOL styleSet = NO;
    
    if (style != nil) {
        CLRColor *color = [style colorOrDefault];
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
        
        CLRColor *color = [style colorOrDefault];
        [options setStrokeColor:[color uiColor]];
        
        [options setLineWidth:[style widthOrDefault]];
        
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
        
        CLRColor *color = [style colorOrDefault];
        [options setStrokeColor:[color uiColor]];
        
        [options setLineWidth:[style widthOrDefault]];
        
        CLRColor *fillColor = [style fillColor];
        if(fillColor != nil){
            [options setFillColor:[fillColor uiColor]];
        }
        
        [polygon setOptions:options];
    }
    
    return style != nil;
}

@end
