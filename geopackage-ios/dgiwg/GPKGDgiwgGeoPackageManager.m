//
//  GPKGDgiwgGeoPackageManager.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgGeoPackageManager.h"
#import "GPKGDgiwgConstants.h"
#import "GPKGCrsWktExtension.h"

@implementation GPKGDgiwgGeoPackageManager

-(instancetype) init{
    self = [super init];
    return self;
}

-(GPKGDgiwgFile *) create: (NSString *) database withMetadata: (NSString *) metadata{
    return [self create:database withURI:GPKG_DGIWG_DMF_DEFAULT_URI andMetadata:metadata];
}

-(GPKGDgiwgFile *) create: (NSString *) database withURI: (NSString *) uri andMetadata: (NSString *) metadata{
    GPKGDgiwgFile *geoPackageFile = nil;
    if([super create:database]){
        geoPackageFile = [self createDGIWG:database withURI:uri andMetadata:metadata];
    }
    return geoPackageFile;
}

-(GPKGDgiwgFile *) create: (NSString *) database inDirectory: (NSString *) dbDirectory withMetadata: (NSString *) metadata{
    return [self create:database inDirectory:dbDirectory withURI:GPKG_DGIWG_DMF_DEFAULT_URI andMetadata:metadata];
}

-(GPKGDgiwgFile *) create: (NSString *) database inDirectory: (NSString *) dbDirectory withURI: (NSString *) uri andMetadata: (NSString *) metadata{
    GPKGDgiwgFile *geoPackageFile = nil;
    if([super create:database inDirectory:dbDirectory]){
        geoPackageFile = [self createDGIWG:database withURI:uri andMetadata:metadata];
    }
    return geoPackageFile;
}

/**
 * Create the DGIWG GeoPackage file
 *
 * @param database database name
 * @param file     GeoPackage file path
 * @param uri      URI
 * @param metadata metadata
 * @return GeoPackage file
 */
-(GPKGDgiwgFile *) createDGIWG: (NSString *) database withURI: (NSString *) uri andMetadata: (NSString *) metadata{

    GPKGDgiwgFile *geoPackageFile = nil;

    GPKGDgiwgGeoPackage *geoPackage = [self open:database];
    @try {
        
        if(geoPackage != nil){
            
            GPKGCrsWktExtension *wktExtension = [[GPKGCrsWktExtension alloc] initWithGeoPackage:geoPackage];
            [wktExtension extensionCreateVersion:GPKG_CRS_WKT_V_1];

            [geoPackage createGeoPackageDatasetMetadata:metadata withURI:uri];

            geoPackageFile = [geoPackage file];
            
        }
        
    } @finally {
        [geoPackage close];
    }

    return geoPackageFile;
}

-(GPKGDgiwgGeoPackage *) open: (NSString *) database{
    return [self open:database andValidate:YES];
}

-(GPKGDgiwgGeoPackage *) open: (NSString *) database andValidate: (BOOL) validate{
    
    GPKGDgiwgGeoPackage *geoPackage = nil;
    
    GPKGGeoPackage *gp = [super open:database];
    if(gp != nil){
        
        geoPackage = [[GPKGDgiwgGeoPackage alloc] initWithGeoPackage:gp];
        
        if(validate){
            [GPKGDgiwgGeoPackageManager validate:geoPackage];
        }
        
    }

    return geoPackage;
}

-(BOOL) deleteDGIWG: (GPKGDgiwgFile *) file{
    return [super delete:file.file];
}

-(BOOL) deleteDGIWG: (GPKGDgiwgFile *) file andFile: (BOOL) deleteFile{
    return [super delete:file.file andFile:deleteFile];
}

+(BOOL) isValid: (GPKGDgiwgGeoPackage *) geoPackage{
    return [geoPackage isValid];
}

+(GPKGDgiwgValidationErrors *) validate: (GPKGDgiwgGeoPackage *) geoPackage{
    return [geoPackage validate];
}

@end
