//
//  GPKGGeoPackageExample.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 1/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGGeoPackageExample.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGGeoPackage.h"
#import "GPKGGeoPackageManager.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGIOUtils.h"

@implementation GPKGGeoPackageExample

static NSString *GEOPACKAGE_NAME = @"example";

-(void) testExample{
    
    NSLog(@"Creating: %@", GEOPACKAGE_NAME);
    GPKGGeoPackage *geoPackage = [GPKGGeoPackageExample createGeoPackage];
    
    // TODO
    
    [geoPackage close];
    [GPKGGeoPackageExample exportGeoPackage];
}

+(void) exportGeoPackage{
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory getManager];
    
    NSString *exportDirectory = [GPKGIOUtils documentsDirectory];
    
    NSString * exportedFile = [[exportDirectory stringByAppendingPathComponent:GEOPACKAGE_NAME] stringByAppendingPathExtension:GPKG_GEOPACKAGE_EXTENSION];
    [GPKGIOUtils deleteFile:exportedFile];
    
    [manager exportGeoPackage:GEOPACKAGE_NAME toDirectory:exportDirectory];
    
    NSLog(@"Created: %@", exportedFile);
}

+(GPKGGeoPackage *) createGeoPackage{
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory getManager];
    
    [manager delete:GEOPACKAGE_NAME];
    
    [manager create:GEOPACKAGE_NAME];
    
    GPKGGeoPackage *geoPackage = [manager open:GEOPACKAGE_NAME];
    if(geoPackage == nil){
        [NSException raise:@"GeoPackage " format:@"Failed to open database"];
    }
    
    return geoPackage;
}

@end
