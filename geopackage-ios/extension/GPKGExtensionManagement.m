//
//  GPKGExtensionManagement.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGExtensionManagement.h"

@interface GPKGExtensionManagement()

@property (nonatomic, strong)  GPKGGeoPackage *geoPackage;

@end

@implementation GPKGExtensionManagement

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super init];
    if(self != nil){
        _geoPackage = geoPackage;
    }
    return self;
}

-(GPKGGeoPackage *) geoPackage{
    return _geoPackage;
}

-(NSString *) author{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) deleteExtensionsForTable: (NSString *) table{
    [self doesNotRecognizeSelector:_cmd];
}

-(void) deleteExtensions{
    [self doesNotRecognizeSelector:_cmd];
}

-(void) copyExtensionsFromTable: (NSString *) table toTable: (NSString *) newTable{
    [self doesNotRecognizeSelector:_cmd];
}

@end
