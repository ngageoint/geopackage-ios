//
//  GPKGMetadataDb.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/29/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMetadataDb.h"
#import "GPKGConnection.h"
#import "GPKGIOUtils.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGGeoPackageMetadataTableCreator.h"

@implementation GPKGMetadataDb

-(instancetype)init{
    self = [super init];
    if(self != nil){
        NSString *metadataFile = [GPKGIOUtils metadataDatabaseFile];
        NSString *documentsMetadataFile = [GPKGIOUtils documentsDirectoryWithSubDirectory:metadataFile];
        self.connection = [[GPKGConnection alloc] initWithDatabaseFilename:documentsMetadataFile];
        
        // For future upgrades, read the application id here and if populated and different, perform metadata database upgrades as needed
        
        GPKGGeoPackageMetadataDao *dao = [self geoPackageMetadataDao];
        if(![dao tableExists]){
        
            // Set the application id
            [self.connection setApplicationId:GPKG_METADATA_APPLICATION_ID];
            
            // Create the tables
            [self createGeoPackageMetadataTable];
            [self createTableMetadataTable];
            [self createGeometryMetadataTable];
        }
    }
    return self;
}

-(void) close{
    if(self.connection != nil){
        [self.connection close];
    }
}

-(GPKGGeoPackageMetadataDao *) geoPackageMetadataDao{
    return [[GPKGGeoPackageMetadataDao alloc] initWithDatabase:self.connection];
}

-(GPKGTableMetadataDao *) tableMetadataDao{
    return [[GPKGTableMetadataDao alloc] initWithDatabase:self.connection];
}

-(GPKGGeometryMetadataDao *) geometryMetadataDao{
    return [[GPKGGeometryMetadataDao alloc] initWithDatabase:self.connection];
}

+(BOOL) deleteMetadataFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *metadataFile = [GPKGIOUtils metadataDatabaseFile];
    NSString *documentsMetadataFile = [GPKGIOUtils documentsDirectoryWithSubDirectory:metadataFile];
    BOOL fileDeleted = [fileManager removeItemAtPath:documentsMetadataFile error:&error];
    if(error || !fileDeleted){
        [NSException raise:@"Delete GeoPackage Metadata File" format:@"Failed to delete GeoPackage Metadata file at path '%@' with error: %@", documentsMetadataFile, error];
    }
    return fileDeleted;
}

-(BOOL) createGeoPackageMetadataTable{
    BOOL created = NO;
    GPKGGeoPackageMetadataDao *dao = [self geoPackageMetadataDao];
    if(![dao tableExists]){
        GPKGGeoPackageMetadataTableCreator *tableCreator = [[GPKGGeoPackageMetadataTableCreator alloc] initWithDatabase:self.connection];
        created = [tableCreator createGeoPackageMetadata] > 0;
    }
    return created;
}

-(BOOL) createTableMetadataTable{
    BOOL created = NO;
    GPKGTableMetadataDao *dao = [self tableMetadataDao];
    if(![dao tableExists]){
        GPKGGeoPackageMetadataTableCreator *tableCreator = [[GPKGGeoPackageMetadataTableCreator alloc] initWithDatabase:self.connection];
        created = [tableCreator createTableMetadata] > 0;
    }
    return created;
}

-(BOOL) createGeometryMetadataTable{
    BOOL created = NO;
    GPKGGeometryMetadataDao *dao = [self geometryMetadataDao];
    if(![dao tableExists]){
        GPKGGeoPackageMetadataTableCreator *tableCreator = [[GPKGGeoPackageMetadataTableCreator alloc] initWithDatabase:self.connection];
        created = [tableCreator createGeometryMetadata] > 0;
    }
    return created;
}

@end
