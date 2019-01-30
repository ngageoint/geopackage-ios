//
//  GPKGStyles.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyles.h"
#import "SFGeometryUtils.h"

@interface GPKGStyles ()

/**
 * Default style
 */
@property (nonatomic, strong) GPKGStyleRow *defaultStyleRow;

/**
 * Geometry type to style mapping
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, GPKGStyleRow *> *styles;

@end

@implementation GPKGStyles

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.styles = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) setDefaultStyle: (GPKGStyleRow *) styleRow{
    [self setStyle:styleRow forGeometryType:SF_NONE];
}

-(void) setStyle: (GPKGStyleRow *) styleRow forGeometryType: (enum SFGeometryType) geometryType{
    if (geometryType != SF_NONE && geometryType >= 0) {
        if (styleRow != nil) {
            [self.styles setObject:styleRow forKey:[NSNumber numberWithInt:geometryType]];
        } else {
            [self.styles removeObjectForKey:[NSNumber numberWithInt:geometryType]];
        }
    } else {
        self.defaultStyleRow = styleRow;
    }
}

-(GPKGStyleRow *) defaultStyle{
    return self.defaultStyleRow;
}

-(NSDictionary<NSNumber *, GPKGStyleRow *> *) allStyles{
    return self.styles;
}

-(GPKGStyleRow *) style{
    return [self styleForGeometryType:SF_NONE];
}

-(GPKGStyleRow *) styleForGeometryType: (enum SFGeometryType) geometryType{

    GPKGStyleRow *styleRow = nil;
    
    if (geometryType != SF_NONE && geometryType >= 0 && self.styles.count > 0) {
        styleRow = [self.styles objectForKey:[NSNumber numberWithInt:geometryType]];
        if(styleRow == nil){
            NSArray<NSNumber *> *geometryTypes = [SFGeometryUtils parentHierarchyOfType:geometryType];
            for(NSNumber *geometryTypeNumber in geometryTypes){
                styleRow = [self.styles objectForKey:geometryTypeNumber];
                if(styleRow != nil){
                    break;
                }
            }
        }
        
    }
    
    if (styleRow == nil) {
        styleRow = self.defaultStyleRow;
    }
    
    if (styleRow == nil && (geometryType == SF_NONE || geometryType < 0) && self.styles.count == 1) {
        styleRow = [[self.styles allValues] objectAtIndex:0];
    }
    
    return styleRow;
}

-(BOOL) isEmpty{
    return self.defaultStyleRow == nil && self.styles.count == 0;
}

-(BOOL) hasDefault{
    return self.defaultStyleRow != nil;
}

@end
