//
//  GPKGIOUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGIOUtils.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"

@implementation GPKGIOUtils

+(NSString *) getPropertyListPathWithName: (NSString *) name{
    return [self getResourcePathWithName:name andType:GPKG_GEO_PACKAGE_PROPERTY_LIST_TYPE];
}

+(NSString *) getResourcePathWithName: (NSString *) name andType: (NSString *) type{
    
    NSString * resource = [NSString stringWithFormat:@"%@/%@", GPKG_GEO_PACKAGE_BUNDLE_NAME, name];
    NSString * resourcePath = [[NSBundle mainBundle] pathForResource:resource ofType:type];
    if(resourcePath == nil){
        resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:resource ofType:type];
        if(resourcePath == nil){
            resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:type];
            if(resourcePath == nil){
                resourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
            }
        }
    }
    if(resourcePath == nil){
        [NSException raise:@"Resource Not Found" format:@"Failed to find resource '%@' of type '%@'", name, type];
    }
    
    return resourcePath;
}

+(NSString *) documentsDirectory{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documents = [paths objectAtIndex:0];
    return documents;
}

+(NSString *) documentsDirectoryWithSubDirectory: (NSString *) subDirectory{
    NSString * documents = [self documentsDirectory];
    NSString * directory = [documents stringByAppendingPathComponent:subDirectory];
    return directory;
}

+(NSString *) geoPackageDirectory{
    NSString * geopackage = [GPKGProperties getValueOfProperty:GPKG_PROP_DIR_GEOPACKAGE];
    [self createDirectoryIfNotExists:geopackage];
    return geopackage;
}

+(NSString *) databaseDirectory{
    NSString * geopackage = [self geoPackageDirectory];
    NSString * database = [geopackage stringByAppendingPathComponent:[GPKGProperties getValueOfProperty:GPKG_PROP_DIR_DATABASE]];
    [self createDirectoryIfNotExists:database];
    return database;
}

+(NSString *) metadataDirectory{
    NSString * geopackage = [self geoPackageDirectory];
    NSString * metadata = [geopackage stringByAppendingPathComponent:[GPKGProperties getValueOfProperty:GPKG_PROP_DIR_METADATA]];
    [self createDirectoryIfNotExists:metadata];
    return metadata;
}

+(NSString *) metadataDatabaseFile{
    NSString * metadataDirectory = [self metadataDirectory];
    NSString * metadataFile = [metadataDirectory stringByAppendingPathComponent:[GPKGProperties getValueOfProperty:GPKG_PROP_DIR_METADATA_FILE_DB]];
    return metadataFile;
}

+(void) createDirectoryIfNotExists: (NSString *) directory{
    NSString * documentsDirectory = [self documentsDirectoryWithSubDirectory:directory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
        NSError *error = nil;
        BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if(error || !created){
            NSLog(@"Failed to create directory at path '%@' with error: %@", documentsDirectory, error);
        }
    }
}

+(NSString *) formatBytes: (int) bytes{
    
    double value = bytes;
    NSString * unit = @"B";
    
    if (bytes >= 1024) {
        int exponent = (int) (log(bytes) / log(1024));
        exponent = MIN(exponent, 4);
        switch (exponent) {
            case 1:
                unit = @"KB";
                break;
            case 2:
                unit = @"MB";
                break;
            case 3:
                unit = @"GB";
                break;
            case 4:
                unit = @"TB";
                break;
        }
        value = bytes / pow(1024, exponent);
    }
    
    return [NSString stringWithFormat:@"%.02f %@", value, unit];
}

+(NSString *) decodeUrl: (NSString *) url{
    NSString *result = [url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

@end
