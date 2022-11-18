//
//  GPKGDgiwgValidate.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgValidate.h"
#import "GPKGDgiwgCoordinateReferenceSystems.h"
#import "GPKGMetadataReference.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "PROJProjectionConstants.h"
#import "GPKGDgiwgConstants.h"
#import "GPKGCrsWktExtension.h"
#import "GPKGDgiwgMetadata.h"
#import "GPKGMetadataExtension.h"
#import "GPKGRTreeIndexExtension.h"
#import "GPKGExtensionManager.h"
#import "GPKGGeometryExtensions.h"
#import "CRSReader.h"
#import "GPKGZoomOtherExtension.h"
#import "GPKGWebPExtension.h"

@implementation GPKGDgiwgValidate

+(BOOL) isValid: (GPKGGeoPackage *) geoPackage{
    return [[self validate:geoPackage] isValid];
}

+(GPKGDgiwgValidationErrors *) validate: (GPKGGeoPackage *) geoPackage{

    GPKGDgiwgValidationErrors *errors = [self validateBase:geoPackage];

    for(NSString *tileTable in [geoPackage tileTables]){
        [errors addValidationErrors:[self validateTileTable:tileTable inGeoPackage:geoPackage]];
    }
    
    for(NSString *featureTable in [geoPackage featureTables]){
        [errors addValidationErrors:[self validateFeatureTable:featureTable inGeoPackage:geoPackage]];
    }

    return errors;
}

+(GPKGDgiwgValidationErrors *) validateBase: (GPKGGeoPackage *) geoPackage{

    GPKGDgiwgValidationErrors *errors = [[GPKGDgiwgValidationErrors alloc] init];

    GPKGCrsWktExtension *crsWktExtension = [[GPKGCrsWktExtension alloc] initWithGeoPackage:geoPackage];
    if(![crsWktExtension hasMinimum:GPKG_CRS_WKT_V_1]){
        [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_EX_TABLE_NAME andColumn:GPKG_EX_COLUMN_EXTENSION_NAME andValue:crsWktExtension.extensionName andConstraint:@"No mandatory CRS WKT extension" andRequirement:GPKG_DGIWG_REQ_EXTENSIONS_MANDATORY andKeys:[self primaryKeysOfExtension:crsWktExtension.extensionName withTable:GPKG_SRS_TABLE_NAME andColumn:crsWktExtension.definitionColumnName]]];
    }

    [errors addValidationErrors:[self validateMetadata:geoPackage]];

    return errors;
}

+(GPKGDgiwgValidationErrors *) validateTable: (NSString *) table inGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [self validateTables:[NSArray arrayWithObject:table] inGeoPackage:geoPackage];
}

+(GPKGDgiwgValidationErrors *) validateTables: (NSArray<NSString *> *) tables inGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGDgiwgValidationErrors *errors = [self validateBase:geoPackage];

    for(NSString *table in tables){
        enum GPKGContentsDataType dataType = [geoPackage dataTypeOfTable:table];
        if(dataType != -1){
            switch (dataType) {
                case GPKG_CDT_FEATURES:
                    [errors addValidationErrors:[self validateFeatureTable:table inGeoPackage:geoPackage]];
                    break;
                case GPKG_CDT_TILES:
                    [errors addValidationErrors:[self validateTileTable:table inGeoPackage:geoPackage]];
                    break;
                default:
                    break;
            }
        }
    }

    return errors;
}

+(GPKGDgiwgValidationErrors *) validateMetadata: (GPKGGeoPackage *) geoPackage{

    GPKGDgiwgValidationErrors *errors = [[GPKGDgiwgValidationErrors alloc] init];

    GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
    GPKGMetadataDao *metadataDao = [metadataExtension metadataDao];
    GPKGMetadataReferenceDao *referenceDao = [metadataExtension metadataReferenceDao];
    
    GPKGResultSet *resultSet = [GPKGDgiwgMetadata queryGeoPackageDMFMetadata:geoPackage];
    if(resultSet != nil && resultSet.count == 0){
        [resultSet close];
        resultSet = nil;
    }
    if(resultSet != nil){
            
        GPKGDgiwgValidationErrors *metadataErrors = [[GPKGDgiwgValidationErrors alloc] init];
        
        @try {
            while([resultSet moveToNext]){
                GPKGMetadataReference *reference = (GPKGMetadataReference *)[referenceDao object:resultSet];
                
                GPKGMetadata *metadata = (GPKGMetadata *)[metadataDao queryForIdObject:reference.fileId];
                
                GPKGDgiwgValidationErrors *mdErrors = [[GPKGDgiwgValidationErrors alloc] init];
                
                NSString *scope = metadata.scope;
                if([scope caseInsensitiveCompare:GPKG_MST_SERIES_NAME] != NSOrderedSame && [scope caseInsensitiveCompare:GPKG_MST_DATASET_NAME] != NSOrderedSame){
                    [mdErrors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_M_TABLE_NAME andColumn:GPKG_M_COLUMN_SCOPE andValue:scope andConstraint:[NSString stringWithFormat:@"%@ or %@", GPKG_MST_SERIES_NAME, GPKG_MST_DATASET_NAME] andRequirement:GPKG_DGIWG_REQ_METADATA_GPKG andKey:[self primaryKeyOfMetadata:metadata]]];
                }
                
                if(![[metadata.standardUri lowercaseString] hasPrefix:[GPKG_DGIWG_DMF_BASE_URI lowercaseString]]){
                    [mdErrors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_M_TABLE_NAME andColumn:GPKG_M_COLUMN_STANDARD_URI andValue:metadata.standardUri andConstraint:[NSString stringWithFormat:@"%@<version>", GPKG_DGIWG_DMF_BASE_URI] andRequirement:GPKG_DGIWG_REQ_METADATA_GPKG andKey:[self primaryKeyOfMetadata:metadata]]];
                }
                
                if([metadata.mimeType caseInsensitiveCompare:GPKG_DGIWG_METADATA_MIME_TYPE] != NSOrderedSame){
                    [mdErrors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_M_TABLE_NAME andColumn:GPKG_M_COLUMN_MIME_TYPE andValue:metadata.mimeType andConstraint:GPKG_DGIWG_METADATA_MIME_TYPE andRequirement:GPKG_DGIWG_REQ_METADATA_GPKG andKey:[self primaryKeyOfMetadata:metadata]]];
                }
                
                if([reference.referenceScope caseInsensitiveCompare:GPKG_RST_GEOPACKAGE_NAME] != NSOrderedSame){
                    [mdErrors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_MR_TABLE_NAME andColumn:GPKG_MR_COLUMN_REFERENCE_SCOPE andValue:reference.referenceScope andConstraint:GPKG_RST_GEOPACKAGE_NAME andRequirement:GPKG_DGIWG_REQ_METADATA_ROW andKeys:[self primaryKeysOfMetadataReference:reference]]];
                }
                
                if(reference.tableName != nil){
                    [mdErrors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_MR_TABLE_NAME andColumn:GPKG_MR_COLUMN_TABLE_NAME andValue:reference.tableName andConstraint:@"NULL" andRequirement:GPKG_DGIWG_REQ_METADATA_ROW andKeys:[self primaryKeysOfMetadataReference:reference]]];
                }
                
                if(reference.columnName != nil){
                    [mdErrors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_MR_TABLE_NAME andColumn:GPKG_MR_COLUMN_COLUMN_NAME andValue:reference.columnName andConstraint:@"NULL" andRequirement:GPKG_DGIWG_REQ_METADATA_ROW andKeys:[self primaryKeysOfMetadataReference:reference]]];
                }
                
                if(reference.rowIdValue != nil){
                    [mdErrors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_MR_TABLE_NAME andColumn:GPKG_MR_COLUMN_ROW_ID_VALUE andNumber:reference.rowIdValue andConstraint:@"NULL" andRequirement:GPKG_DGIWG_REQ_METADATA_ROW andKeys:[self primaryKeysOfMetadataReference:reference]]];
                }
                
                if(reference.parentId != nil){
                    [mdErrors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_MR_TABLE_NAME andColumn:GPKG_MR_COLUMN_PARENT_ID andNumber:reference.parentId andConstraint:@"NULL" andRequirement:GPKG_DGIWG_REQ_METADATA_ROW andKeys:[self primaryKeysOfMetadataReference:reference]]];
                }
                
                if([mdErrors isValid]){
                    metadataErrors = nil;
                    break;
                }

                [metadataErrors addValidationErrors:mdErrors];
            }
        } @finally {
            [resultSet close];
        }
        
        if(metadataErrors != nil){
            [errors addValidationErrors:metadataErrors];
        }
        
    }else{
        
        if(![metadataExtension has]){
            
            BOOL metadataTableExists = [metadataDao tableExists];
            
            if(!metadataTableExists){
                
                [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_EX_TABLE_NAME andColumn:GPKG_EX_COLUMN_EXTENSION_NAME andValue:metadataExtension.extensionName andConstraint:@"No mandatory Metadata extension" andRequirement:GPKG_DGIWG_REQ_EXTENSIONS_MANDATORY andKeys:[self primaryKeysOfExtension:metadataExtension.extensionName withTable:GPKG_M_TABLE_NAME]]];
                
            }
            
            BOOL referenceTableExists = [referenceDao tableExists];
            
            if(!referenceTableExists){
                
                [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_EX_TABLE_NAME andColumn:GPKG_EX_COLUMN_EXTENSION_NAME andValue:metadataExtension.extensionName andConstraint:@"No mandatory Metadata extension" andRequirement:GPKG_DGIWG_REQ_EXTENSIONS_MANDATORY andKeys:[self primaryKeysOfExtension:metadataExtension.extensionName withTable:GPKG_MR_TABLE_NAME]]];
                
            }
            
        }
        
        NSMutableArray<GPKGDgiwgValidationKey *> *keys = [NSMutableArray array];
        [keys addObject: [[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_M_COLUMN_STANDARD_URI andValue:GPKG_DGIWG_DMF_BASE_URI]];
        [keys addObject: [[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_MR_COLUMN_REFERENCE_SCOPE andValue:GPKG_RST_GEOPACKAGE_NAME]];
        [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_M_TABLE_NAME andColumn:GPKG_M_COLUMN_STANDARD_URI andValue:GPKG_DGIWG_DMF_BASE_URI andConstraint:@"No required metadata with DMF base URI and metadata reference 'geopackage' scope" andRequirement:GPKG_DGIWG_REQ_METADATA_DMF andKeys:keys]];
        
    }

    return errors;
}

+(GPKGDgiwgValidationErrors *) validateTileTable: (NSString *) tileTable inGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGDgiwgValidationErrors *errors = [[GPKGDgiwgValidationErrors alloc] init];

    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage tileMatrixSetDao];
    GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *)[tileMatrixSetDao queryForIdObject:tileTable];

    if(tileMatrixSet != nil){
        GPKGSpatialReferenceSystem *srs = [tileMatrixSetDao srs:tileMatrixSet];
        [errors addValidationErrors:[self validateCRSWithTileTable:tileTable andSRS:srs]];
        
        GPKGDgiwgCoordinateReferenceSystems *crs = [GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithSRS:srs];
        if(crs != nil){
            
            GPKGBoundingBox *boundingBox = [crs bounds];
            if(![boundingBox contains:[tileMatrixSet boundingBox]]){

                NSString *crsBounds = [NSString stringWithFormat:@"CRS %@ Bounds: %@", [crs authorityAndCode], boundingBox];

                if([tileMatrixSet.minX doubleValue] < [boundingBox.minLongitude doubleValue]){
                    [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TMS_TABLE_NAME andColumn:GPKG_TMS_COLUMN_MIN_X andNumber:tileMatrixSet.minX andConstraint:crsBounds andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKey:[self primaryKeyOfTileMatrixSet:tileMatrixSet]]];
                }

                if([tileMatrixSet.minY doubleValue] < [boundingBox.minLatitude doubleValue]){
                    [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TMS_TABLE_NAME andColumn:GPKG_TMS_COLUMN_MIN_Y andNumber:tileMatrixSet.minY andConstraint:crsBounds andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKey:[self primaryKeyOfTileMatrixSet:tileMatrixSet]]];
                }
                
                if([tileMatrixSet.maxX doubleValue] > [boundingBox.maxLongitude doubleValue]){
                    [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TMS_TABLE_NAME andColumn:GPKG_TMS_COLUMN_MAX_X andNumber:tileMatrixSet.maxX andConstraint:crsBounds andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKey:[self primaryKeyOfTileMatrixSet:tileMatrixSet]]];
                }

                if([tileMatrixSet.maxY doubleValue] > [boundingBox.maxLatitude doubleValue]){
                    [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TMS_TABLE_NAME andColumn:GPKG_TMS_COLUMN_MAX_Y andNumber:tileMatrixSet.maxY andConstraint:crsBounds andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKey:[self primaryKeyOfTileMatrixSet:tileMatrixSet]]];
                }

            }
            
        }
        
    }else{
        [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TMS_TABLE_NAME andColumn:GPKG_TMS_COLUMN_TABLE_NAME andValue:tileTable andConstraint:@"No Tile Matrix Set for tile table" andRequirement:GPKG_DGIWG_REQ_CRS_RASTER_TILE_MATRIX_SET]];
    }

    GPKGTileMatrixDao *tileMatrixDao = [geoPackage tileMatrixDao];
    NSArray<GPKGTileMatrix *> *tileMatrices = [tileMatrixDao tileMatricesForTableName:tileTable];

    if(tileMatrices == nil || tileMatrices.count == 0){
        [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TM_TABLE_NAME andColumn:GPKG_TM_COLUMN_TABLE_NAME andValue:tileTable andConstraint:@"No Tile Matrices for tile table" andRequirement:GPKG_DGIWG_REQ_CRS_RASTER_TILE_MATRIX_SET andKey:[self primaryKeyOfTileMatrixSet:tileMatrixSet]]];
    }else{

        GPKGTileMatrix *previousTileMatrix = nil;

        for(GPKGTileMatrix *tileMatrix in tileMatrices){

            int zoomLevel = [tileMatrix.zoomLevel intValue];
            if(zoomLevel < GPKG_DGIWG_MIN_ZOOM_LEVEL || zoomLevel > GPKG_DGIWG_MAX_ZOOM_LEVEL){
                [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TM_TABLE_NAME andColumn:GPKG_TM_COLUMN_ZOOM_LEVEL andNumber:tileMatrix.zoomLevel andConstraint:[NSString stringWithFormat:@"%d <= %@ <= %d", (int) GPKG_DGIWG_MIN_ZOOM_LEVEL, GPKG_TM_COLUMN_ZOOM_LEVEL, (int) GPKG_DGIWG_MAX_ZOOM_LEVEL] andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKeys:[self primaryKeysOfTileMatrix:tileMatrix]]];
            }

            if([tileMatrix.tileWidth intValue] != GPKG_DGIWG_TILE_WIDTH){
                [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TM_TABLE_NAME andColumn:GPKG_TM_COLUMN_TILE_WIDTH andNumber:tileMatrix.tileWidth andConstraintValue:[NSNumber numberWithInteger:GPKG_DGIWG_TILE_WIDTH] andRequirement:GPKG_DGIWG_REQ_TILE_SIZE_MATRIX andKeys:[self primaryKeysOfTileMatrix:tileMatrix]]];
            }
            
            if([tileMatrix.tileHeight intValue] != GPKG_DGIWG_TILE_HEIGHT){
                [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TM_TABLE_NAME andColumn:GPKG_TM_COLUMN_TILE_HEIGHT andNumber:tileMatrix.tileHeight andConstraintValue:[NSNumber numberWithInteger:GPKG_DGIWG_TILE_HEIGHT] andRequirement:GPKG_DGIWG_REQ_TILE_SIZE_MATRIX andKeys:[self primaryKeysOfTileMatrix:tileMatrix]]];
            }

            if(previousTileMatrix != nil){

                int zoomChange = [tileMatrix.zoomLevel intValue] - [previousTileMatrix.zoomLevel intValue];
                double factor = pow(2, zoomChange);
                double pixelXSize = [previousTileMatrix.pixelXSize doubleValue] / factor;
                double pixelYSize = [previousTileMatrix.pixelYSize doubleValue] / factor;
                
                if([tileMatrix.pixelXSize doubleValue] != pixelXSize){
                    [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TM_TABLE_NAME andColumn:GPKG_TM_COLUMN_PIXEL_X_SIZE andNumber:tileMatrix.pixelXSize andConstraintValue:[[NSDecimalNumber alloc] initWithDouble:pixelXSize] andRequirement:GPKG_DGIWG_REQ_ZOOM_FACTOR andKeys:[self primaryKeysOfTileMatrix:tileMatrix]]];
                }
                
                if([tileMatrix.pixelYSize doubleValue] != pixelYSize){
                    [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TM_TABLE_NAME andColumn:GPKG_TM_COLUMN_PIXEL_Y_SIZE andNumber:tileMatrix.pixelYSize andConstraintValue:[[NSDecimalNumber alloc] initWithDouble:pixelYSize] andRequirement:GPKG_DGIWG_REQ_ZOOM_FACTOR andKeys:[self primaryKeysOfTileMatrix:tileMatrix]]];
                }

                if(zoomChange > 1){
                    NSMutableString *zoomMissing = [NSMutableString string];
                    [zoomMissing appendFormat:@"%d", [previousTileMatrix.zoomLevel intValue] + 1];
                    if(zoomChange > 2){
                        [zoomMissing appendString:@" - "];
                        [zoomMissing appendFormat:@"%d", [tileMatrix.zoomLevel intValue] - 1];
                    }
                    [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_TM_TABLE_NAME andColumn:GPKG_TM_COLUMN_ZOOM_LEVEL andNumber:tileMatrix.zoomLevel andConstraint:[NSString stringWithFormat:@"Missing adjacent zoom level(s): %@", zoomMissing] andRequirement:GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_MULTIPLE andKeys:[self primaryKeysOfTileMatrix:tileMatrix]]];
                }

            }

            previousTileMatrix = tileMatrix;
        }

    }

    GPKGZoomOtherExtension *zoomOtherExtension = [[GPKGZoomOtherExtension alloc] initWithGeoPackage:geoPackage];
    if([zoomOtherExtension hasWithTableName:tileTable]){
        [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_EX_TABLE_NAME andColumn:GPKG_EX_COLUMN_EXTENSION_NAME andValue:zoomOtherExtension.extensionName andConstraint:@"Zoom other intervals not allowed" andRequirement:GPKG_DGIWG_REQ_EXTENSIONS_NOT_ALLOWED andKeys:[self primaryKeysOfExtension:zoomOtherExtension.extensionName withTable:tileTable andColumn:GPKG_TC_COLUMN_TILE_DATA]]];
    }

    GPKGWebPExtension *webPExtension = [[GPKGWebPExtension alloc] initWithGeoPackage:geoPackage];
    if([webPExtension hasWithTableName:tileTable]){
        [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_EX_TABLE_NAME andColumn:GPKG_EX_COLUMN_EXTENSION_NAME andValue:webPExtension.extensionName andConstraint:@"WebP encoding not allowed" andRequirement:GPKG_DGIWG_REQ_EXTENSIONS_NOT_ALLOWED andKeys:[self primaryKeysOfExtension:webPExtension.extensionName withTable:tileTable andColumn:GPKG_TC_COLUMN_TILE_DATA]]];
    }
 
    return errors;
}

+(GPKGDgiwgValidationErrors *) validateCRSWithTileTable: (NSString *) tileTable andSRS: (GPKGSpatialReferenceSystem *) srs{

    GPKGDgiwgValidationErrors *errors = [[GPKGDgiwgValidationErrors alloc] init];

    GPKGDgiwgCoordinateReferenceSystems *crs = [self validateCRSWithErrors:errors andTable:tileTable andSRS:srs andContentsType:GPKG_CDT_TILES];

    if(crs == nil){

        PROJProjection *projection = [srs projection];
        NSString *definition = [projection definition];

        CRSObject *definitionCrs = [projection definitionCRS];
        if(definitionCrs == nil){
            if(definition != nil){
                @try {
                    definitionCrs = [CRSReader read:definition];
                } @catch (NSException *e) {
                    [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_DEFINITION andValue:definition andConstraint:[NSString stringWithFormat:@"Failed to read tiles coordinate reference system definition: %@", [e description]] andRequirement:GPKG_DGIWG_REQ_CRS_RASTER_ALLOWED andKey:[self primaryKeyOfSRS:srs]]];
                }
            }
        }

        if(definitionCrs != nil){

            BOOL valid = NO;

            if(definitionCrs.type == CRS_TYPE_PROJECTED && [definitionCrs isKindOfClass:[CRSProjectedCoordinateReferenceSystem class]]){
                CRSProjectedCoordinateReferenceSystem *projected = (CRSProjectedCoordinateReferenceSystem *) definitionCrs;
                CRSOperationMethods *operationMethod = projected.mapProjection.method.method;
                switch(operationMethod.type){
                    case CRS_METHOD_LAMBERT_CONIC_CONFORMAL_1SP:
                    case CRS_METHOD_LAMBERT_CONIC_CONFORMAL_2SP:
                        valid = YES;
                        break;
                    default:
                        break;
                }
            }
            
            if(!valid){
                [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_DEFINITION andValue:definition andConstraint:@"Unsupported tiles coordinate reference system" andRequirement:GPKG_DGIWG_REQ_CRS_RASTER_ALLOWED andKey:[self primaryKeyOfSRS:srs]]];
            }

        }else if(![errors hasErrors]){
            [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_DEFINITION andValue:definition andConstraint:@"Failed to read tiles coordinate reference system definition" andRequirement:GPKG_DGIWG_REQ_CRS_RASTER_ALLOWED andKey:[self primaryKeyOfSRS:srs]]];
        }

    }

    return errors;
}

+(GPKGDgiwgValidationErrors *) validateFeatureTable: (NSString *) featureTable inGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGDgiwgValidationErrors *errors = [[GPKGDgiwgValidationErrors alloc] init];

    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage geometryColumnsDao];
    GPKGGeometryColumns *geometryColumns = [geometryColumnsDao queryForTableName:featureTable];

    if(geometryColumns != nil){
        GPKGSpatialReferenceSystem *srs = [geometryColumnsDao srs:geometryColumns];
        [errors addValidationErrors:[self validateCRSWithFeatureTable:featureTable andSRS:srs]];

        NSString *geomColumn = geometryColumns.columnName;

        int z = [geometryColumns.z intValue];
        if(z != 0 && z != 1){
            [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_GC_TABLE_NAME andColumn:GPKG_GC_COLUMN_Z andNumber:[NSNumber numberWithInt:z] andConstraint:@"Geometry Columns z values of prohibited (0) or mandatory (1)" andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKeys:[self primaryKeysOfGeometryColumns:geometryColumns]]];
        }

        GPKGDgiwgCoordinateReferenceSystems *crs = [GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithSRS:srs];
        if(crs != nil){

            if(z == 0){
                if(![crs isDataType:GPKG_DGIWG_DT_FEATURES_2D]){
                    [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_GC_TABLE_NAME andColumn:GPKG_GC_COLUMN_Z andNumber:[NSNumber numberWithInt:z] andConstraint:[NSString stringWithFormat:@"Geometry Columns z value of prohibited (0) is for 2-D CRS. CRS %@ Types: %@", [crs authorityAndCode], [crs dataTypeNames]] andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKeys:[self primaryKeysOfGeometryColumns:geometryColumns]]];
                }
            }else if(z == 1){
                if(![crs isDataType:GPKG_DGIWG_DT_FEATURES_3D]){
                    [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_GC_TABLE_NAME andColumn:GPKG_GC_COLUMN_Z andNumber:[NSNumber numberWithInt:z] andConstraint:[NSString stringWithFormat:@"Geometry Columns z value of mandatory (1) is for 3-D CRS. CRS %@ Types: %@", [crs authorityAndCode], [crs dataTypeNames]] andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKeys:[self primaryKeysOfGeometryColumns:geometryColumns]]];
                }
            }

        }

        GPKGRTreeIndexExtension *rTreeIndexExtension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
        if(![rTreeIndexExtension hasWithTableName:featureTable]){
            [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_EX_TABLE_NAME andColumn:GPKG_EX_COLUMN_EXTENSION_NAME andValue:rTreeIndexExtension.extensionName andConstraint:@"No mandatory RTree extension for feature table" andRequirement:GPKG_DGIWG_REQ_EXTENSIONS_MANDATORY andKeys:[self primaryKeysOfExtension:rTreeIndexExtension.extensionName withTable:featureTable andColumn:geomColumn]]];
        }
        
        GPKGGeometryExtensions *geometryExtensions = [[GPKGGeometryExtensions alloc] initWithGeoPackage:geoPackage];
        for(int i = SF_CIRCULARSTRING; i <= SF_SURFACE; i++){
            enum SFGeometryType geometryType = i;
            if([geometryExtensions hasWithTable:featureTable andColumn:geomColumn andType:geometryType]){
                NSString *geometryExtensionName = [GPKGGeometryExtensions extensionName:geometryType];
                [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_EX_TABLE_NAME andColumn:GPKG_EX_COLUMN_EXTENSION_NAME andValue:geometryExtensionName andConstraint:@"Nonlinear geometry type not allowed" andRequirement:GPKG_DGIWG_REQ_EXTENSIONS_NOT_ALLOWED andKeys:[self primaryKeysOfExtension:geometryExtensionName withTable:featureTable andColumn:geomColumn]]];
            }
        }

    } else {
        [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_GC_TABLE_NAME andColumn:GPKG_GC_COLUMN_TABLE_NAME andValue:featureTable andConstraint:@"No Geometry Columns for feature table" andRequirement:GPKG_DGIWG_REQ_GEOPACKAGE_BASE]];
    }

    return errors;
}

+(GPKGDgiwgValidationErrors *) validateCRSWithFeatureTable: (NSString *) featureTable andSRS: (GPKGSpatialReferenceSystem *) srs{

    GPKGDgiwgValidationErrors *errors = [[GPKGDgiwgValidationErrors alloc] init];

    GPKGDgiwgCoordinateReferenceSystems *crs = [self validateCRSWithErrors:errors andTable:featureTable andSRS:srs andContentsType:GPKG_CDT_FEATURES];

    if(crs == nil){
        [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_DEFINITION andValue:[srs projectionDefinition] andConstraint:@"Unsupported features coordinate reference system" andRequirement:GPKG_DGIWG_REQ_CRS_2D_VECTOR andKey:[self primaryKeyOfSRS:srs]]];
    }

    return errors;
}

/**
 * Validate the coordinate reference system
 *
 * @param errors
 *            validation errors
 * @param table
 *            table name
 * @param srs
 *            spatial reference system
 * @param type
 *            contents data type
 * @return coordinate reference system
 */
+(GPKGDgiwgCoordinateReferenceSystems *) validateCRSWithErrors: (GPKGDgiwgValidationErrors *) errors andTable: (NSString *) table andSRS: (GPKGSpatialReferenceSystem *) srs andContentsType: (enum GPKGContentsDataType) type{

    GPKGDgiwgCoordinateReferenceSystems *crs = [GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithSRS:srs];
    
    if(crs != nil){
        
        BOOL valid = NO;
        
        for(NSNumber *dataType in [crs dataTypes]){
            if([GPKGDgiwgDataTypes dataType:[dataType intValue]] == type){
                valid = YES;
                break;
            }
        }
        
        if(!valid){
            [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_DEFINITION andValue:[srs projectionDefinition] andConstraint:[NSString stringWithFormat:@"Unsupported %@ coordinate reference system", [GPKGContentsDataTypes name:type]] andRequirement:GPKG_DGIWG_REQ_CRS_WKT andKey:[self primaryKeyOfSRS:srs]]];
        }
        
        NSString *definition = nil;
        if([crs type] == CRS_TYPE_COMPOUND){
            definition = srs.definition_12_063;
        }else{
            definition = [srs projectionDefinition];
        }
        NSString *definitionTrimmed = nil;
        if(definition != nil){
            definitionTrimmed = [definition stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        if(definition == nil || definitionTrimmed.length == 0 || [definitionTrimmed caseInsensitiveCompare:GPKG_UNDEFINED_DEFINITION] == NSOrderedSame){
            [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:[crs type] == CRS_TYPE_COMPOUND ? [GPKGProperties valueOfProperty:@"geopackage.extensions.crs_wkt.definition.column_name"] : GPKG_SRS_COLUMN_DEFINITION andValue:definition andConstraint:@"Missing required coordinate reference system well-known text definition" andRequirement:GPKG_DGIWG_REQ_CRS_WKT andKey:[self primaryKeyOfSRS:srs]]];
        }
        
        if([srs.srsName caseInsensitiveCompare:[crs name]] != NSOrderedSame){
            [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_SRS_NAME andValue:srs.srsName andConstraint:[crs name] andRequirement:GPKG_DGIWG_REQ_CRS_WKT andKey:[self primaryKeyOfSRS:srs]]];
        }
        
        if([srs.srsId intValue] != [crs code]){
            [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_SRS_ID andNumber:srs.srsId andConstraintValue:[NSNumber numberWithInt:[crs code]] andRequirement:GPKG_DGIWG_REQ_CRS_WKT andKey:[self primaryKeyOfSRS:srs]]];
        }
        
        if([srs.organization caseInsensitiveCompare:[crs authority]] != NSOrderedSame){
            [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_ORGANIZATION andValue:srs.organization andConstraint:[crs authority] andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKey:[self primaryKeyOfSRS:srs]]];
        }
        
        if([srs.organizationCoordsysId intValue] != [crs code]){
            [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_ORGANIZATION_COORDSYS_ID andNumber:srs.organizationCoordsysId andConstraintValue:[NSNumber numberWithInt:[crs code]] andRequirement:GPKG_DGIWG_REQ_CRS_WKT andKey:[self primaryKeyOfSRS:srs]]];
        }
        
    }else{
        
        if([srs.organization caseInsensitiveCompare:PROJ_AUTHORITY_EPSG] != NSOrderedSame){
            [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_ORGANIZATION andValue:srs.organization andConstraint:PROJ_AUTHORITY_EPSG andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKey:[self primaryKeyOfSRS:srs]]];
        }
        
    }

    NSString *description = srs.theDescription;
    NSString *descriptionTrimmed = nil;
    if(description != nil){
        descriptionTrimmed = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    if(description == nil || descriptionTrimmed.length == 0 || [descriptionTrimmed caseInsensitiveCompare:GPKG_DGIWG_DESCRIPTION_UNKNOWN] == NSOrderedSame || [descriptionTrimmed caseInsensitiveCompare:GPKG_DGIWG_DESCRIPTION_TBD] == NSOrderedSame){
        [errors addError:[[GPKGDgiwgValidationError alloc] initWithTable:GPKG_SRS_TABLE_NAME andColumn:GPKG_SRS_COLUMN_DESCRIPTION andValue:srs.theDescription andConstraint:@"Invalid empty or unspecified description" andRequirement:GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY andKey:[self primaryKeyOfSRS:srs]]];
    }
     
    return crs;
}

/**
 * Get the Spatial Reference System primary key
 *
 * @param srs
 *            spatial reference system
 * @return primary key
 */
+(GPKGDgiwgValidationKey *) primaryKeyOfSRS: (GPKGSpatialReferenceSystem *) srs{
    GPKGDgiwgValidationKey *key = nil;
    if(srs != nil){
        key = [[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_SRS_COLUMN_SRS_ID andNumber:srs.srsId];
    }
    return key;
}

/**
 * Get the Metadata primary key
 *
 * @param metadata
 *            metadata
 * @return primary key
 */
+(GPKGDgiwgValidationKey *) primaryKeyOfMetadata: (GPKGMetadata *) metadata{
    GPKGDgiwgValidationKey *key = nil;
    if(metadata != nil){
        key = [[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_M_COLUMN_ID andNumber:metadata.id];
    }
    return key;
}

/**
 * Get the Metadata Reference primary key
 *
 * @param reference
 *            metadata reference
 * @return primary key
 */
+(NSArray<GPKGDgiwgValidationKey *> *) primaryKeysOfMetadataReference: (GPKGMetadataReference *) reference{
    NSMutableArray<GPKGDgiwgValidationKey *> *keys = [NSMutableArray array];
    
    if(reference != nil){
        [keys addObject:[[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_MR_COLUMN_FILE_ID andNumber:reference.fileId]];
        if(reference.parentId != nil){
            [keys addObject:[[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_MR_COLUMN_PARENT_ID andNumber:reference.parentId]];
        }
    }
    
    return keys;
}

/**
 * Get the Tile Matrix Set primary key
 *
 * @param tileMatrixSet
 *            tile matrix set
 * @return primary key
 */
+(GPKGDgiwgValidationKey *) primaryKeyOfTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet{
    GPKGDgiwgValidationKey *key = nil;
    if(tileMatrixSet != nil){
        key = [[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_TMS_COLUMN_TABLE_NAME andValue:tileMatrixSet.tableName];
    }
    return key;
}

/**
 * Get the Tile Matrix primary keys
 *
 * @param tileMatrix
 *            tile matrix
 * @return primary keys
 */
+(NSArray<GPKGDgiwgValidationKey *> *) primaryKeysOfTileMatrix: (GPKGTileMatrix *) tileMatrix{
    NSMutableArray<GPKGDgiwgValidationKey *> *keys = [NSMutableArray array];
    if(tileMatrix != nil){
        [keys addObject:[[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_TM_COLUMN_TABLE_NAME andValue:tileMatrix.tableName]];
        [keys addObject:[[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_TM_COLUMN_ZOOM_LEVEL andNumber:tileMatrix.zoomLevel]];
    }
    return keys;
}

/**
 * Get the Geometry Columns primary keys
 *
 * @param geometryColumns
 *            geometry columns
 * @return primary keys
 */
+(NSArray<GPKGDgiwgValidationKey *> *) primaryKeysOfGeometryColumns: (GPKGGeometryColumns *) geometryColumns{
    NSMutableArray<GPKGDgiwgValidationKey *> *keys = [NSMutableArray array];
    if(geometryColumns != nil){
        [keys addObject:[[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_GC_COLUMN_TABLE_NAME andValue:geometryColumns.tableName]];
        [keys addObject:[[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_GC_COLUMN_COLUMN_NAME andValue:geometryColumns.columnName]];
    }
    return keys;
}

/**
 * Get the Extension primary keys
 *
 * @param extension
 *            extension name
 * @param table
 *            table name
 * @return primary keys
 */
+(NSArray<GPKGDgiwgValidationKey *> *) primaryKeysOfExtension: (NSString *) extension withTable: (NSString *) table{
    return [self primaryKeysOfExtension:extension withTable:table andColumn:nil];
}

/**
 * Get the Extension primary keys
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @param extension
 *            extension name
 * @return primary keys
 */
+(NSArray<GPKGDgiwgValidationKey *> *) primaryKeysOfExtension: (NSString *) extension withTable: (NSString *) table andColumn: (NSString *) column{
    
    NSMutableArray<GPKGDgiwgValidationKey *> *keys = [NSMutableArray array];
    
    if(table != nil){
        [keys addObject:[[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_EX_COLUMN_TABLE_NAME andValue:table]];
    }
    
    if(column != nil){
        [keys addObject:[[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_EX_COLUMN_COLUMN_NAME andValue:column]];
    }
    
    [keys addObject:[[GPKGDgiwgValidationKey alloc] initWithColumn:GPKG_EX_COLUMN_EXTENSION_NAME andValue:extension]];
    
    return keys;
}

@end
