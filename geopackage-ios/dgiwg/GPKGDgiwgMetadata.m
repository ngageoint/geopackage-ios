//
//  GPKGDgiwgMetadata.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgMetadata.h"
#import "GPKGDgiwgConstants.h"
#import "GPKGMetadataExtension.h"

@implementation GPKGDgiwgMetadata

+(GPKGMetadata *) createSeriesMetadata: (NSString *) metadata withURI: (NSString *) uri{
    return [self createMetadata:metadata withScope:GPKG_MST_SERIES andURI:uri];
}

+(GPKGMetadata *) createDatasetMetadata: (NSString *) metadata withURI: (NSString *) uri{
    return [self createMetadata:metadata withScope:GPKG_MST_DATASET andURI:uri];
}

+(GPKGMetadata *) createMetadata: (NSString *) metadata withScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri{
    
    GPKGMetadata *md = [[GPKGMetadata alloc] init];
    [md setMetadataScopeType:scope];
    [md setStandardUri:uri];
    [md setMimeType:GPKG_DGIWG_METADATA_MIME_TYPE];
    [md setMetadata:metadata];
    
    return md;
}

+(GPKGMetadataReference *) createGeoPackageMetadataReference{
    return [self createMetadataReferenceWithScope:GPKG_RST_GEOPACKAGE];
}

+(GPKGMetadataReference *) createMetadataReferenceWithScope: (enum GPKGReferenceScopeType) scope{
    
    GPKGMetadataReference *reference = [[GPKGMetadataReference alloc] init];
    [reference setReferenceScopeType:scope];
    
    return reference;
}

+(GPKGResultSet *) queryGeoPackageDMFMetadata: (GPKGGeoPackage *) geoPackage{
    return [self queryGeoPackageMetadata:geoPackage withBaseURI:GPKG_DGIWG_DMF_BASE_URI];
}

+(GPKGResultSet *) queryGeoPackageNASMetadata: (GPKGGeoPackage *) geoPackage{
    return [self queryGeoPackageMetadata:geoPackage withBaseURI:GPKG_DGIWG_NMIS_BASE_URI];
}

+(GPKGResultSet *) queryGeoPackageMetadata: (GPKGGeoPackage *) geoPackage withBaseURI: (NSString *) baseURI{
    
    GPKGResultSet *results = nil;
    
    GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
    
    if([metadataExtension has]){
        
        GPKGMetadataDao *metadataDao = [metadataExtension metadataDao];
        GPKGMetadataReferenceDao *referenceDao = [metadataExtension metadataReferenceDao];
        
        if([metadataDao tableExists] && [referenceDao tableExists]){
            
            NSString *query = [NSString stringWithFormat:@"SELECT %@.* FROM %@ LEFT JOIN %@ ON %@.%@ = %@.%@ WHERE %@.%@ LIKE '%@' AND (%@.%@ LIKE '%@')", GPKG_MR_TABLE_NAME, GPKG_MR_TABLE_NAME, GPKG_M_TABLE_NAME, GPKG_MR_TABLE_NAME, GPKG_MR_COLUMN_FILE_ID, GPKG_M_TABLE_NAME, GPKG_M_COLUMN_ID, GPKG_MR_TABLE_NAME, GPKG_MR_COLUMN_REFERENCE_SCOPE, GPKG_RST_GEOPACKAGE_NAME, GPKG_M_TABLE_NAME, GPKG_M_COLUMN_STANDARD_URI, [NSString stringWithFormat:@"%@%%", baseURI]];
            results = [referenceDao rawQuery:query];
            
        }
        
    }
    
    return results;
}

@end
