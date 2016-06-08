//
//  GPKGTilesGeoPackageTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGTilesGeoPackageTestCase.h"
#import "GPKGGeoPackageManager.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGTestConstants.h"

@implementation GPKGTilesGeoPackageTestCase

-(instancetype) initWithName: (NSString *) name andFile: (NSString *) file{
    self = [super init];
    if(self != nil){
        self.dbName = name;
        self.file = file;
    }
    return self;
}

-(GPKGGeoPackage *) getGeoPackage{
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    
    // Delete
    [manager delete:self.dbName];
    
    NSString *filePath  = [[[NSBundle bundleForClass:[GPKGTilesGeoPackageTestCase class]] resourcePath] stringByAppendingPathComponent:self.file];
    
    // Import
    [manager importGeoPackageFromPath:filePath withName:self.dbName];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:self.dbName];
    [manager close];
    if(geoPackage == nil){
        [NSException raise:@"Failed to Open" format:@"Failed to open database"];
    }
    
    return geoPackage;
}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    
    // Close
    if (self.geoPackage != nil) {
        [self.geoPackage close];
    }
    
    // Delete
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    [manager delete:self.dbName];
    [manager close];
    
    [super tearDown];
}

@end
