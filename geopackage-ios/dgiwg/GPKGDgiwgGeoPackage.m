//
//  GPKGDgiwgGeoPackage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgGeoPackage.h"
#import "GPKGDgiwgValidate.h"

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
    return nil; // TODO
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return nil; // TODO
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return nil; // TODO
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return nil; // TODO
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return nil; // TODO
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return nil; // TODO
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return nil; // TODO
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return nil; // TODO
}

-(GPKGTileMatrixSet *) createTilesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andInformativeBounds: (GPKGBoundingBox *) informativeBounds andSRS: (GPKGSpatialReferenceSystem *) srs andExtentBounds: (GPKGBoundingBox *) extentBounds{
    return nil; // TODO
}

-(void) createTileMatricesWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    // TODO
}

-(void) createTileMatricesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    // TODO
}

-(void) createTileMatricesWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andZoomLevels: (NSArray<NSNumber *> *) zoomLevels andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    // TODO
}

-(void) createTileMatricesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andZoomLevels: (NSArray<NSNumber *> *) zoomLevels andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
   // TODO
}

-(void) createTileMatrixWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    // TODO
}

-(void) createTileMatrixWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight{
    // TODO
}

-(void) createTileMatrixWithTable: (NSString *) table andZoom: (int) zoom andWidth: (int) matrixWidth andHeight: (int) matrixHeight andPixelX: (double) pixelXSize andPixelY: (double) pixelYSize{
    // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andCRS: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andSRS: (GPKGSpatialReferenceSystem *) srs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andSRS: (GPKGSpatialReferenceSystem *) srs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andSRS: (GPKGSpatialReferenceSystem *) srs{
    return nil; // TODO
}

-(GPKGGeometryColumns *) createFeaturesWithTable: (NSString *) table andIdentifier: (NSString *) identifier andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andGeometryType: (enum SFGeometryType) geometryType andDataType: (enum GPKGDgiwgDataType) dataType andColumns: (NSArray<GPKGFeatureColumn *> *) columns andSRS: (GPKGSpatialReferenceSystem *) srs{
    return nil; // TODO
}

-(void) createMetadata: (GPKGMetadata *) metadata andReference: (GPKGMetadataReference *) reference{
    // TODO
}

-(void) createMetadata: (GPKGMetadata *) metadata{
    // TODO
}

-(void) createMetadataReference: (GPKGMetadataReference *) reference withMetadata: (GPKGMetadata *) metadata{
    // TODO
}

-(void) createMetadataReference: (GPKGMetadataReference *) reference{
    // TODO
}

-(GPKGMetadataReference *) createGeoPackageSeriesMetadata: (NSString *) metadata withURI: (NSString *) uri{
    return nil; // TODO
}

-(GPKGMetadataReference *) createGeoPackageDatasetMetadata: (NSString *) metadata withURI: (NSString *) uri{
    return nil; // TODO
}

-(GPKGMetadataReference *) createGeoPackageMetadata: (NSString *) metadata withScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri{
    return nil; // TODO
}

-(GPKGMetadataReference *) createMetadata: (NSString *) metadata withScope: (enum GPKGMetadataScopeType) scope andURI: (NSString *) uri andReference: (GPKGMetadataReference *) reference{
    return nil; // TODO
}

+(GPKGResultSet *) queryGeoPackageDMFMetadata{
    return nil; // TODO
}

+(GPKGResultSet *) queryGeoPackageNASMetadata{
    return nil; // TODO
}

+(GPKGResultSet *) queryGeoPackageMetadataWithBaseURI: (NSString *) baseURI{
    return nil; // TODO
}

@end
