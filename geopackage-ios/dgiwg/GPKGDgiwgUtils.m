//
//  GPKGDgiwgUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgUtils.h"
#import "GPKGDgiwgConstants.h"
#import "GPKGMetadataExtension.h"
#import "GPKGDgiwgMetadata.h"

@implementation GPKGDgiwgUtils

+(GPKGTileMatrixSet *) createTilesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    
    [geoPackage createTileMatrixSetTable];
    [geoPackage createTileMatrixTable];

    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage spatialReferenceSystemDao];
    [srsDao createOrUpdate:srs];
    
    if(informativeBounds == nil){
        informativeBounds = extentBounds;
    }

    GPKGContents *contents = [[GPKGContents alloc] init];
    [contents setTableName:table];
    [contents setContentsDataType:GPKG_CDT_TILES];
    [contents setIdentifier:identifier];
    [contents setTheDescription:description];
    [contents setMinX:informativeBounds.minLongitude];
    [contents setMinY:informativeBounds.minLatitude];
    [contents setMaxX:informativeBounds.maxLongitude];
    [contents setMaxY:informativeBounds.maxLatitude];
    [contents setSrs:srs];

    GPKGTileTable *tileTable = [[GPKGTileTable alloc] initWithTable:table];
    [geoPackage createTileTable:tileTable];

    [[geoPackage contentsDao] create:contents];

    GPKGTileMatrixSet *tileMatrixSet = [[GPKGTileMatrixSet alloc] init];
    [tileMatrixSet setContents:contents];
    [tileMatrixSet setSrsId:contents.srsId];
    [tileMatrixSet setMinX:extentBounds.minLongitude];
    [tileMatrixSet setMinY:extentBounds.minLatitude];
    [tileMatrixSet setMaxX:extentBounds.maxLongitude];
    [tileMatrixSet setMaxY:extentBounds.maxLatitude];

    [[geoPackage tileMatrixSetDao] create:tileMatrixSet];

    [geoPackage saveSchema:tileTable];
    
    return tileMatrixSet;
}

+(void) createTileMatricesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    NSMutableArray<NSNumber *> *zoomLevels = [NSMutableArray array];
    for(int zoom = minZoom; zoom <= maxZoom; zoom++){
        [zoomLevels addObject:[NSNumber numberWithInt:zoom]];
    }
    [self createTileMatricesWithGeoPackage:geoPackage andTable:table andBounds:boundingBox andZoomLevels:zoomLevels andWidth:matrixWidth andHeight:matrixHeight];
}

+(void) createTileMatricesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andZoomLevels: (NSArray<NSNumber *> *) zoomLevels andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    
    NSOrderedSet<NSNumber *> *zooms = [NSOrderedSet orderedSetWithArray:zoomLevels];

    int minZoom = [[zooms firstObject] intValue];
    int maxZoom = [[zooms lastObject] intValue];
    
    for(int zoom = minZoom; zoom <= maxZoom; zoom++){

        if([zooms containsObject:[NSNumber numberWithInt:zoom]]){
            [self createTileMatrixWithGeoPackage:geoPackage andTable:table andBounds:boundingBox andZoom:zoom andWidth:matrixWidth andHeight:matrixHeight];
        }

        matrixWidth *= 2;
        matrixHeight *= 2;

    }

}

+(void) createTileMatrixWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    
    double pixelXSize = [boundingBox longitudeRangeValue] / matrixWidth
            / GPKG_DGIWG_TILE_WIDTH;
    double pixelYSize = [boundingBox latitudeRangeValue] / matrixHeight
            / GPKG_DGIWG_TILE_HEIGHT;

    [self createTileMatrixWithGeoPackage:geoPackage andTable:table andZoom:zoom andWidth:matrixWidth andHeight:matrixHeight andPixelX:pixelXSize andPixelY:pixelYSize];
}

+(void) createTileMatrixWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight andPixelX: (double) pixelXSize andPixelY: (double) pixelYSize{

    if(zoom < 0){
        [NSException raise:@"Illegal Zoom Level" format:@"Illegal negative zoom level: %d", zoom];
    }

    GPKGContents *contents = [geoPackage contentsOfTable:table];
    if(contents == nil){
        [NSException raise:@"Table Contents" format:@"Failed to retrieve Contents for table: %@", table];
    }

    GPKGTileMatrix *tileMatrix = [[GPKGTileMatrix alloc] init];
    [tileMatrix setContents:contents];
    [tileMatrix setZoomLevel:[NSNumber numberWithInt:zoom]];
    [tileMatrix setMatrixWidth:[NSNumber numberWithInt:matrixWidth]];
    [tileMatrix setMatrixHeight:[NSNumber numberWithInt:matrixHeight]];
    [tileMatrix setTileWidth:[NSNumber numberWithInteger:GPKG_DGIWG_TILE_WIDTH]];
    [tileMatrix setTileHeight:[NSNumber numberWithInteger:GPKG_DGIWG_TILE_HEIGHT]];
    [tileMatrix setPixelXSizeValue:pixelXSize];
    [tileMatrix setPixelYSizeValue:pixelYSize];

    [[geoPackage tileMatrixDao] create:tileMatrix];

}

+(GPKGGeometryColumns *) createFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andSRS: (GPKGSpatialReferenceSystem *) srs{
    
    [geoPackage createGeometryColumnsTable];

    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage spatialReferenceSystemDao];
    [srsDao createOrUpdate:srs];

    GPKGContents *contents = [[GPKGContents alloc] init];
    [contents setTableName:table];
    [contents setContentsDataType:GPKG_CDT_FEATURES];
    [contents setIdentifier:identifier];
    [contents setTheDescription:description];
    [contents setMinX:bounds.minLongitude];
    [contents setMinY:bounds.minLatitude];
    [contents setMaxX:bounds.maxLongitude];
    [contents setMaxY:bounds.maxLatitude];
    [contents setSrs:srs];

    NSMutableArray<GPKGFeatureColumn *> *featureColumns = nil;
    
    BOOL hasPk = NO;
    BOOL hasGeometry = NO;
    if(columns == nil){
        featureColumns = [NSMutableArray array];
    }else{
        featureColumns = [NSMutableArray arrayWithArray:columns];
        for(GPKGFeatureColumn *column in columns){
            if(column.primaryKey){
                hasPk = YES;
                if(hasGeometry){
                    break;
                }
            }else if([column isGeometry]){
                hasGeometry = YES;
                if(hasPk){
                    break;
                }
            }
        }
    }
    if(!hasGeometry){
        [featureColumns insertObject:[GPKGFeatureColumn createGeometryColumnWithName:GPKG_FTM_DEFAULT_COLUMN_NAME andGeometryType:geometryType] atIndex:0];
    }
    if(!hasPk){
        [featureColumns insertObject:[GPKGFeatureColumn createPrimaryKeyColumnWithName:GPKG_UTM_DEFAULT_ID_COLUMN_NAME andAutoincrement:DEFAULT_AUTOINCREMENT] atIndex:0];
    }

    GPKGFeatureTable *featureTable = [[GPKGFeatureTable alloc] initWithTable:table andColumns:featureColumns];
    [geoPackage createFeatureTable:featureTable];

    [[geoPackage contentsDao] create:contents];

    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setContents:contents];
    [geometryColumns setColumnName:[featureTable geometryColumnName]];
    [geometryColumns setGeometryType:geometryType];
    [geometryColumns setSrs:srs];
    [geometryColumns setZ:[NSNumber numberWithInt:[GPKGDgiwgDataTypes z:dataType]]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];

    [[geoPackage geometryColumnsDao] create:geometryColumns];

    [geoPackage saveSchema:featureTable];
    
    return geometryColumns;
}

+(void) createMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andMetadata: (GPKGMetadata *) metadata andReference: (GPKGMetadataReference *) reference{
    
    [self createMetadataWithGeoPackage:geoPackage andMetadata:metadata];
    [self createMetadataReferenceWithGeoPackage:geoPackage andMetadata:metadata andReference:reference];
    
}

+(void) createMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andMetadata: (GPKGMetadata *) metadata{
    
    GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
    [metadataExtension createMetadataTable];
    GPKGMetadataDao *metadataDao = [metadataExtension metadataDao];
    
    [metadataDao create:metadata];
    
}

+(void) createMetadataReferenceWithGeoPackage: (GPKGGeoPackage *) geoPackage andMetadata: (GPKGMetadata *) metadata andReference: (GPKGMetadataReference *) reference{
    
    [reference setMetadata:metadata];
    [self createMetadataReferenceWithGeoPackage:geoPackage andReference:reference];
    
}

+(void) createMetadataReferenceWithGeoPackage: (GPKGGeoPackage *) geoPackage andReference: (GPKGMetadataReference *) reference{
    
    GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
    [metadataExtension createMetadataReferenceTable];
    GPKGMetadataReferenceDao *metadataReferenceDao = [metadataExtension metadataReferenceDao];
    
    [metadataReferenceDao create:reference];
    
}

+(GPKGMetadataReference *) createGeoPackageSeriesMetadata: (NSString *) metadata withGeoPackage: (GPKGGeoPackage *) geoPackage andURI: (NSString *) uri{
    return [self createGeoPackageMetadata:metadata withGeoPackage:geoPackage andScope:GPKG_MST_SERIES andURI:uri];
}

+(GPKGMetadataReference *) createGeoPackageDatasetMetadata: (NSString *) metadata withGeoPackage: (GPKGGeoPackage *) geoPackage andURI: (NSString *) uri{
    return [self createGeoPackageMetadata:metadata withGeoPackage:geoPackage andScope:GPKG_MST_DATASET andURI:uri];
}

+(GPKGMetadataReference *) createGeoPackageMetadata: (NSString *) metadata withGeoPackage: (GPKGGeoPackage *) geoPackage andScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri{
    GPKGMetadata *md = [GPKGDgiwgMetadata createMetadata:metadata withScope:scope andURI:uri];
    GPKGMetadataReference *reference = [GPKGDgiwgMetadata createGeoPackageMetadataReference];
    [self createMetadataWithGeoPackage:geoPackage andMetadata:md andReference:reference];
    return reference;
}

+(GPKGMetadataReference *) createMetadata: (NSString *) metadata withGeoPackage: (GPKGGeoPackage *) geoPackage andScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri andReference: (GPKGMetadataReference *) reference{
    GPKGMetadata *md = [GPKGDgiwgMetadata createMetadata:metadata withScope:scope andURI:uri];
    [self createMetadataWithGeoPackage:geoPackage andMetadata:md andReference:reference];
    return reference;
}

@end
