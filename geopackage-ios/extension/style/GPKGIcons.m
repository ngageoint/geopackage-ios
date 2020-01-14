//
//  GPKGIcons.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGIcons.h"
#import "SFGeometryUtils.h"

@interface GPKGIcons ()

/**
 * Default icon
 */
@property (nonatomic, strong) GPKGIconRow *defaultIconRow;

/**
 * Geometry type to icon mapping
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, GPKGIconRow *> *icons;

@end

@implementation GPKGIcons

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.icons = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) setDefaultIcon: (GPKGIconRow *) iconRow{
    [self setIcon:iconRow forGeometryType:SF_NONE];
}

-(void) setIcon: (GPKGIconRow *) iconRow forGeometryType: (enum SFGeometryType) geometryType{
    if (geometryType != SF_NONE && geometryType >= 0) {
        if (iconRow != nil) {
            [self.icons setObject:iconRow forKey:[NSNumber numberWithInt:geometryType]];
        } else {
            [self.icons removeObjectForKey:[NSNumber numberWithInt:geometryType]];
        }
    } else {
        self.defaultIconRow = iconRow;
    }
}

-(GPKGIconRow *) defaultIcon{
    return _defaultIconRow;
}

-(NSDictionary<NSNumber *, GPKGIconRow *> *) allIcons{
    return _icons;
}

-(GPKGIconRow *) icon{
    return [self iconForGeometryType:SF_NONE];
}

-(GPKGIconRow *) iconForGeometryType: (enum SFGeometryType) geometryType{

    GPKGIconRow *iconRow = nil;
    
    if (geometryType != SF_NONE && geometryType >= 0 && self.icons.count > 0) {
        iconRow = [self.icons objectForKey:[NSNumber numberWithInt:geometryType]];
        if(iconRow == nil){
            NSArray<NSNumber *> *geometryTypes = [SFGeometryUtils parentHierarchyOfType:geometryType];
            for(NSNumber *geometryTypeNumber in geometryTypes){
                iconRow = [self.icons objectForKey:geometryTypeNumber];
                if(iconRow != nil){
                    break;
                }
            }
        }

    }
    
    if (iconRow == nil) {
        iconRow = self.defaultIconRow;
    }
    
    if (iconRow == nil && (geometryType == SF_NONE || geometryType < 0) && self.icons.count == 1) {
        iconRow = [[self.icons allValues] objectAtIndex:0];
    }
    
    return iconRow;
}

-(BOOL) isEmpty{
    return self.defaultIconRow == nil && self.icons.count == 0;
}

-(BOOL) hasDefault{
    return self.defaultIconRow != nil;
}

@end
