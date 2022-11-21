//
//  GPKGDgiwgGeoPackage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgGeoPackage.h"
#import "GPKGDgiwgValidate.h"
#import "GPKGDgiwgUtils.h"
#import "GPKGRTreeIndexExtension.h"
#import "GPKGDgiwgMetadata.h"

@interface GPKGDgiwgGeoPackage()

/**
 * DGIWG File
 */
@property (nonatomic, strong) GPKGDgiwgFile *file;

/**
 * Validate errors when validated
 */
@property (nonatomic, strong) GPKGDgiwgValidationErrors *errors;

@end

@implementation GPKGDgiwgGeoPackage

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithConnection:geoPackage.database andWritable:geoPackage.writable andMetadataDb:geoPackage.metadataDb];
    if(self != nil){
        _file = [[GPKGDgiwgFile alloc] initWithFile:self.path andName:self.name];
    }
    return self;
}

-(GPKGDgiwgFile *) file{
    return _file;
}

-(GPKGDgiwgFileName *) fileName{
    return _file.fileName;
}

-(BOOL) isValid{
    return [[self validate] isValid];
}

-(GPKGDgiwgValidationErrors *) validate{
    _errors = [GPKGDgiwgValidate validate:self];
    return _errors;
}

-(GPKGDgiwgValidationErrors *) errors{
    return _errors;
}

-(GPKGDgiwgValidationErrors *) validateTable: (NSString *) table{
    return [GPKGDgiwgValidate validateTable:table inGeoPackage:self];
}

-(GPKGDgiwgValidationErrors *) validateTables: (NSArray<NSString *> *) tables{
    return [GPKGDgiwgValidate validateTables:tables inGeoPackage:self];
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return [self createTilesWithTable:table andIdentifier:table andDescription:table andCRS:crs];
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return [self createTilesWithTable:table andIdentifier:identifier andDescription:description andInformativeBounds:nil andCRS:crs];
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    GPKGSpatialReferenceSystem *srs = [crs createTilesSpatialReferenceSystem];
    return [self createTilesWithTable:table andIdentifier:identifier andDescription:description andInformativeBounds:informativeBounds andSRS:srs andExtentBounds:[crs bounds]];
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return [self createTilesWithTable:table andIdentifier:table andDescription:table andCRS:crs andExtentBounds:extentBounds];
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return [self createTilesWithTable:table andIdentifier:identifier andDescription:description andInformativeBounds:nil andCRS:crs andExtentBounds:extentBounds];
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return [self createTilesWithTable:table andIdentifier:identifier andDescription:description andInformativeBounds:informativeBounds andSRS:[crs createTilesSpatialReferenceSystem] andExtentBounds:extentBounds];
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return [self createTilesWithTable:table andIdentifier:table andDescription:table andSRS:srs andExtentBounds:extentBounds];
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return [self createTilesWithTable:table andIdentifier:identifier andDescription:description andInformativeBounds:nil andSRS:srs andExtentBounds:extentBounds];
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return [GPKGDgiwgUtils createTilesWithGeoPackage:self andTable:table andIdentifier:identifier andDescription:description andInformativeBounds:informativeBounds andSRS:srs andExtentBounds:extentBounds];
}

-(void) createTileMatricesWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    return [self createTileMatricesWithTable:tileMatrixSet.tableName andBounds:[tileMatrixSet boundingBox] andMinZoom:minZoom andMaxZoom:maxZoom andWidth:matrixWidth andHeight:matrixHeight];
}

-(void) createTileMatricesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    return [GPKGDgiwgUtils createTileMatricesWithGeoPackage:self andTable:table andBounds:boundingBox andMinZoom:minZoom andMaxZoom:maxZoom andWidth:matrixWidth andHeight:matrixHeight];
}

-(void) createTileMatricesWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andZoomLevels: (NSArray<NSNumber *> *) zoomLevels andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    return [self createTileMatricesWithTable:tileMatrixSet.tableName andBounds:[tileMatrixSet boundingBox] andZoomLevels:zoomLevels andWidth:matrixWidth andHeight:matrixHeight];
}

-(void) createTileMatricesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andZoomLevels: (NSArray<NSNumber *> *) zoomLevels andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    return [GPKGDgiwgUtils createTileMatricesWithGeoPackage:self andTable:table andBounds:boundingBox andZoomLevels:zoomLevels andWidth:matrixWidth andHeight:matrixHeight];
}

-(void) createTileMatrixWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    [self createTileMatrixWithTable:tileMatrixSet.tableName andBounds:[tileMatrixSet boundingBox] andZoom:zoom andWidth:matrixWidth andHeight:matrixHeight];
}

-(void) createTileMatrixWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    return [GPKGDgiwgUtils createTileMatrixWithGeoPackage:self andTable:table andBounds:boundingBox andZoom:zoom andWidth:matrixWidth andHeight:matrixHeight];
}

-(void) createTileMatrixWithTable: (NSString *) table andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight andPixelX: (double) pixelXSize andPixelY: (double) pixelYSize{
    return [GPKGDgiwgUtils createTileMatrixWithGeoPackage:self andTable:table andZoom:zoom andWidth:matrixWidth andHeight:matrixHeight andPixelX:pixelXSize andPixelY:pixelYSize];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return [self createFeaturesWithTable:table andGeometryType:geometryType andColumns:nil andCRS:crs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return [self createFeaturesWithTable:table andIdentifier:table andDescription:table andGeometryType:geometryType andColumns:columns andCRS:crs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return [self createFeaturesWithTable:table andIdentifier:identifier andDescription:description andGeometryType:geometryType andColumns:nil andCRS:crs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    GPKGSpatialReferenceSystem *srs = [crs createFeaturesSpatialReferenceSystem];
    enum GPKGDgiwgDataType dataType = [[[crs featuresDataTypes] firstObject] intValue];
    return [self createFeaturesWithTable:table andIdentifier:identifier andDescription:description andBounds:[crs bounds] andGeometryType:geometryType andDataType:dataType andColumns:columns andSRS:srs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return [self createFeaturesWithTable:table andBounds:bounds andGeometryType:geometryType andColumns:nil andCRS:crs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return [self createFeaturesWithTable:table andIdentifier:table andDescription:table andBounds:bounds andGeometryType:geometryType andColumns:columns andCRS:crs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return [self createFeaturesWithTable:table andIdentifier:identifier andDescription:description andBounds:bounds andGeometryType:geometryType andColumns:nil andCRS:crs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    GPKGSpatialReferenceSystem *srs = [crs createFeaturesSpatialReferenceSystem];
    enum GPKGDgiwgDataType dataType = [[[crs featuresDataTypes] firstObject] intValue];
    return [self createFeaturesWithTable:table andIdentifier:identifier andDescription:description andBounds:bounds andGeometryType:geometryType andDataType:dataType andColumns:columns andSRS:srs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andSRS: (GPKGSpatialReferenceSystem *) srs{
    return [self createFeaturesWithTable:table andBounds:bounds andGeometryType:geometryType andDataType:dataType andColumns:nil andSRS:srs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andSRS: (GPKGSpatialReferenceSystem *) srs{
    return [self createFeaturesWithTable:table andIdentifier:table andDescription:table andBounds:bounds andGeometryType:geometryType andDataType:dataType andColumns:columns andSRS:srs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andSRS: (GPKGSpatialReferenceSystem *) srs{
    return [self createFeaturesWithTable:table andIdentifier:identifier andDescription:description andBounds:bounds andGeometryType:geometryType andDataType:dataType andColumns:nil andSRS:srs];
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andSRS: (GPKGSpatialReferenceSystem *) srs{

    GPKGGeometryColumns *geometryColumns = [GPKGDgiwgUtils createFeaturesWithGeoPackage:self andTable:table andIdentifier:identifier andDescription:description andBounds:bounds andGeometryType:geometryType andDataType:dataType andColumns:columns andSRS:srs];

    GPKGRTreeIndexExtension *extension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:self];
    [extension createWithFeatureTable:[[self featureDaoWithGeometryColumns:geometryColumns] featureTable]];

    return geometryColumns;
}

-(void) createMetadata: (GPKGMetadata *) metadata andReference: (GPKGMetadataReference *) reference{
    return [GPKGDgiwgUtils createMetadataWithGeoPackage:self andMetadata:metadata andReference:reference];
}

-(void) createMetadata: (GPKGMetadata *) metadata{
    return [GPKGDgiwgUtils createMetadataWithGeoPackage:self andMetadata:metadata];
}

-(void) createMetadataReference: (GPKGMetadataReference *) reference withMetadata: (GPKGMetadata *) metadata{
    return [GPKGDgiwgUtils createMetadataReferenceWithGeoPackage:self andMetadata:metadata andReference:reference];
}

-(void) createMetadataReference: (GPKGMetadataReference *) reference{
    return [GPKGDgiwgUtils createMetadataReferenceWithGeoPackage:self andReference:reference];
}

-(GPKGMetadataReference *) createGeoPackageSeriesMetadata: (NSString *) metadata withURI: (NSString *) uri{
    return [GPKGDgiwgUtils createGeoPackageSeriesMetadata:metadata withGeoPackage:self andURI:uri];
}

-(GPKGMetadataReference *) createGeoPackageDatasetMetadata: (NSString *) metadata withURI: (NSString *) uri{
    return [GPKGDgiwgUtils createGeoPackageDatasetMetadata:metadata withGeoPackage:self andURI:uri];
}

-(GPKGMetadataReference *) createGeoPackageMetadata: (NSString *) metadata withScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri{
    return [GPKGDgiwgUtils createGeoPackageMetadata:metadata withGeoPackage:self andScope:scope andURI:uri];
}

-(GPKGMetadataReference *) createMetadata: (NSString *) metadata withScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri andReference: (GPKGMetadataReference *) reference{
    return [GPKGDgiwgUtils createMetadata:metadata withGeoPackage:self andScope:scope andURI:uri andReference:reference];
}

-(GPKGResultSet *) queryGeoPackageDMFMetadata{
    return [GPKGDgiwgMetadata queryGeoPackageDMFMetadata:self];
}

-(GPKGResultSet *) queryGeoPackageNASMetadata{
    return [GPKGDgiwgMetadata queryGeoPackageNASMetadata:self];
}

-(GPKGResultSet *) queryGeoPackageMetadataWithBaseURI: (NSString *) baseURI{
    return [GPKGDgiwgMetadata queryGeoPackageMetadata:self withBaseURI:baseURI];
}

@end
