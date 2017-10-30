//
//  GPKGFeatureOverlayQuery.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureOverlayQuery.h"
#import "GPKGProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGProjectionFactory.h"
#import "WKBGeometryPrinter.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "GPKGFeatureRowData.h"
#import "GPKGProjectionTransform.h"
#import "GPKGMapUtils.h"

@interface GPKGFeatureOverlayQuery ()

@property (nonatomic, strong) GPKGBoundedOverlay *boundedOverlay;
@property (nonatomic, strong) GPKGFeatureTiles *featureTiles;
@property (nonatomic) enum WKBGeometryType geometryType;

@end

@implementation GPKGFeatureOverlayQuery

-(instancetype) initWithFeatureOverlay: (GPKGFeatureOverlay *) featureOverlay{
    return [self initWithBoundedOverlay:featureOverlay andFeatureTiles:featureOverlay.featureTiles];
}

-(instancetype) initWithBoundedOverlay: (GPKGBoundedOverlay *) boundedOverlay andFeatureTiles: (GPKGFeatureTiles *) featureTiles{
    self = [super init];
    if(self != nil){
        self.boundedOverlay = boundedOverlay;
        self.featureTiles = featureTiles;
        
        GPKGFeatureDao * featureDao = [self.featureTiles getFeatureDao];
        self.geometryType = [featureDao getGeometryType];
        self.name = [NSString stringWithFormat:@"%@ - %@", featureDao.databaseName, featureDao.tableName];
        
        // Get the screen percentage to determine when a feature is clicked
        self.screenClickPercentage = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_SCREEN_CLICK_PERCENTAGE] floatValue];
        
        self.maxFeaturesInfo = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_MAX_FEATURES_INFO];
        self.featuresInfo = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_FEATURES_INFO];
        
        self.maxPointDetailedInfo = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_MAX_POINT_DETAILED_INFO] intValue];
        self.maxFeatureDetailedInfo = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_MAX_FEATURE_DETAILED_INFO] intValue];
        
        self.detailedInfoPrintPoints = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_DETAILED_INFO_PRINT_POINTS];
        self.detailedInfoPrintFeatures = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_DETAILED_INFO_PRINT_FEATURES];
    }
    return self;
}

-(GPKGBoundedOverlay *) getBoundedOverlay{
    return self.boundedOverlay;
}

-(GPKGFeatureTiles *) getFeatureTiles{
    return self.featureTiles;
}

-(enum WKBGeometryType) getGeometryType{
    return self.geometryType;
}

-(void) setScreenClickPercentage:(float)screenClickPercentage{
    if(screenClickPercentage < 0.0 || screenClickPercentage > 1.0){
        [NSException raise:@"Screen Click Percentage" format:@"Screen click percentage must be a float between 0.0 and 1.0, not %f", screenClickPercentage];
    }
    _screenClickPercentage = screenClickPercentage;
}

-(BOOL) onAtCurrentZoomWithMapView: (MKMapView *) mapView andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate{
    double zoom = [GPKGMapUtils currentZoomWithMapView:mapView];
    BOOL on = [self onAtZoom:zoom andLocationCoordinate:locationCoordinate];
    return on;
}

-(BOOL) onAtZoom: (double) zoom andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate{
    
    NSDecimalNumber * x = [[NSDecimalNumber alloc] initWithDouble:locationCoordinate.longitude];
    NSDecimalNumber * y = [[NSDecimalNumber alloc] initWithDouble:locationCoordinate.latitude];
    WKBPoint * point = [[WKBPoint alloc] initWithX:x andY:y];
    GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils getTileGridFromWGS84Point:point andZoom:zoom];
    
    BOOL on = [self.boundedOverlay hasTileWithX:tileGrid.minX andY:tileGrid.minY andZoom:zoom];
    return on;
}

-(int) tileFeatureCountWithMapPoint: (GPKGMapPoint *) mapPoint andDoubleZoom: (double) zoom{
    return [self tileFeatureCountWithLocationCoordinate:mapPoint.coordinate andDoubleZoom:zoom];
}

-(int) tileFeatureCountWithMapPoint: (GPKGMapPoint *) mapPoint andZoom: (int) zoom{
    return [self tileFeatureCountWithLocationCoordinate:mapPoint.coordinate andZoom:zoom];
}

-(int) tileFeatureCountWithMKMapPoint: (MKMapPoint) mapPoint andDoubleZoom: (double) zoom{
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
    return [self tileFeatureCountWithLocationCoordinate:coord andDoubleZoom:zoom];
}

-(int) tileFeatureCountWithMKMapPoint: (MKMapPoint) mapPoint andZoom: (int) zoom{
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
    return [self tileFeatureCountWithLocationCoordinate:coord andZoom:zoom];
}

-(int) tileFeatureCountWithLocationCoordinate: (CLLocationCoordinate2D) location andDoubleZoom: (double) zoom{
    int zoomValue = (int) zoom;
    int tileFeaturesCount = [self tileFeatureCountWithLocationCoordinate:location andZoom:zoomValue];
    return tileFeaturesCount;
}

-(int) tileFeatureCountWithLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (int) zoom{
    NSDecimalNumber * x = [[NSDecimalNumber alloc] initWithDouble:location.longitude];
    NSDecimalNumber * y = [[NSDecimalNumber alloc] initWithDouble:location.latitude];
    WKBPoint * point = [[WKBPoint alloc] initWithX:x andY:y];
    int tileFeaturesCount = [self tileFeatureCountWithPoint:point andZoom:zoom];
    return tileFeaturesCount;
}

-(int) tileFeatureCountWithPoint: (WKBPoint *) point andDoubleZoom: (double) zoom{
    int zoomValue = (int) zoom;
    int tileFeaturesCount = [self tileFeatureCountWithPoint:point andZoom:zoomValue];
    return tileFeaturesCount;
}

-(int) tileFeatureCountWithPoint: (WKBPoint *) point andZoom: (int) zoom{
    GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils getTileGridFromWGS84Point:point andZoom:zoom];
    return [self.featureTiles queryIndexedFeaturesCountWithX:tileGrid.minX andY:tileGrid.minY andZoom:zoom];
}

-(BOOL) moreThanMaxFeatures: (int) tileFeaturesCount{
    return self.featureTiles.maxFeaturesPerTile != nil && tileFeaturesCount > [self.featureTiles.maxFeaturesPerTile intValue];
}

-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGFeatureIndexResults * results = [self queryFeaturesWithBoundingBox:boundingBox withProjection:nil];
    return results;
}

-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (GPKGProjection *) projection{
    
    if(projection == nil){
        projection = [GPKGProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    }
    
    // Query for features
    GPKGFeatureIndexManager * indexManager = self.featureTiles.indexManager;
    if(indexManager == nil){
        [NSException raise:@"Index Manager" format:@"Index Manager is not set on the Feature Tiles and is required to query indexed features"];
    }
    GPKGFeatureIndexResults * results = [indexManager queryWithBoundingBox:boundingBox andProjection:projection];
    return results;
}

-(BOOL) isIndexed{
    return [self.featureTiles isIndexQuery];
}

-(NSString *) buildMaxFeaturesInfoMessageWithTileFeaturesCount: (int) tileFeaturesCount{
    return [NSString stringWithFormat:@"%@\n\t%d features", self.name, tileFeaturesCount];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results{
    return [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andProjection:nil];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andProjection: (GPKGProjection *) projection{
    return [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andPoint:nil andProjection:projection];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate{
    return [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andLocationCoordinate:locationCoordinate andProjection:nil];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andProjection: (GPKGProjection *) projection{
    NSDecimalNumber * x = [[NSDecimalNumber alloc] initWithDouble:locationCoordinate.longitude];
    NSDecimalNumber * y = [[NSDecimalNumber alloc] initWithDouble:locationCoordinate.latitude];
    WKBPoint * point = [[WKBPoint alloc] initWithX:x andY:y];
    return [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andPoint:point andProjection:projection];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andPoint: (WKBPoint *) point{
    return [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andPoint:point andProjection:nil];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andPoint: (WKBPoint *) point andProjection: (GPKGProjection *) projection{
    
    NSMutableString * message = nil;
    
    int featureCount = results.count;
    if(featureCount > 0){
        
        int maxFeatureInfo = 0;
        if(self.geometryType == WKB_POINT){
            maxFeatureInfo = self.maxPointDetailedInfo;
        } else{
            maxFeatureInfo = self.maxFeatureDetailedInfo;
        }
        
        if(featureCount <= maxFeatureInfo){
            message = [[NSMutableString alloc] init];
            [message appendFormat:@"%@\n", self.name];
            
            int featureNumber = 0;
            
            GPKGDataColumnsDao * dataColumnsDao = [self getDataColumnsDao];
            
            for(GPKGFeatureRow * featureRow in results){
                
                featureNumber++;
                if(featureNumber > maxFeatureInfo){
                    break;
                }
                
                if(featureCount > 1){
                    if(featureNumber > 1){
                        [message appendString:@"\n"];
                    }else{
                        [message appendFormat:@"\n%d Features\n", featureCount];
                    }
                    [message appendFormat:@"\nFeature %d:\n", featureNumber];
                }
                
                int geometryColumn = [featureRow getGeometryColumnIndex];
                for(int i = 0; i < [featureRow columnCount]; i++){
                    if(i != geometryColumn){
                        NSObject * value = [featureRow getValueWithIndex:i];
                        if(value != nil){
                            NSString * columnName = [featureRow getColumnNameWithIndex:i];
                            columnName = [self getColumnNameWithDataColumnsDao:dataColumnsDao andFeatureRow:featureRow andColumnName:columnName];
                            [message appendFormat:@"\n%@: %@", columnName, value];
                        }
                    }
                }
                
                GPKGGeometryData * geomData = [featureRow getGeometry];
                if(geomData != nil && geomData.geometry != nil){
                
                    BOOL printFeatures = false;
                    if(geomData.geometry.geometryType == WKB_POINT){
                        printFeatures = self.detailedInfoPrintPoints;
                    } else{
                        printFeatures = self.detailedInfoPrintFeatures;
                    }
                    
                    if(printFeatures){
                        if(projection != nil){
                            [self projectGeometry:geomData withProjection:projection];
                        }
                        [message appendFormat:@"\n\n%@", [WKBGeometryPrinter getGeometryString:geomData.geometry]];
                    }
                }
            }
        }else{
            message = [[NSMutableString alloc] init];
            [message appendFormat:@"%@\n\t%d features", self.name, featureCount];
            if(point != nil){
                [message appendString:@" near location:\n"];
                [message appendFormat:@"%@", [WKBGeometryPrinter getGeometryString:point]];
            }
        }
    }
    
    [results close];
    
    return message;
}

-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate{
    return [self buildTableDataAndCloseWithFeatureIndexResults:results andLocationCoordinate:locationCoordinate andProjection:nil];
}

-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andProjection: (GPKGProjection *) projection{
    NSDecimalNumber * x = [[NSDecimalNumber alloc] initWithDouble:locationCoordinate.longitude];
    NSDecimalNumber * y = [[NSDecimalNumber alloc] initWithDouble:locationCoordinate.latitude];
    WKBPoint * point = [[WKBPoint alloc] initWithX:x andY:y];
    return [self buildTableDataAndCloseWithFeatureIndexResults:results andPoint:point andProjection:projection];
}

-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andPoint: (WKBPoint *) point{
    return [self buildTableDataAndCloseWithFeatureIndexResults:results andPoint:point andProjection:nil];
}

-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andPoint: (WKBPoint *) point andProjection: (GPKGProjection *) projection{
    
    GPKGFeatureTableData * tableData = nil;
    
    int featureCount = results.count;
    if(featureCount > 0){
        
        int maxFeatureInfo = 0;
        if(self.geometryType == WKB_POINT){
            maxFeatureInfo = self.maxPointDetailedInfo;
        } else{
            maxFeatureInfo = self.maxFeatureDetailedInfo;
        }
        
        if(featureCount <= maxFeatureInfo){
            
            GPKGDataColumnsDao * dataColumnsDao = [self getDataColumnsDao];
            
            NSMutableArray<GPKGFeatureRowData *> * rows = [[NSMutableArray alloc] init];
            
            for(GPKGFeatureRow * featureRow in results){
                
                NSMutableDictionary * values = [[NSMutableDictionary alloc] init];
                NSString * geometryColumnName = nil;
                
                int geometryColumn = [featureRow getGeometryColumnIndex];
                for(int i = 0; i < [featureRow columnCount]; i++){
                    
                    NSObject * value = [featureRow getValueWithIndex:i];
                    
                    NSString * columnName = [featureRow getColumnNameWithIndex:i];
                    
                    columnName = [self getColumnNameWithDataColumnsDao:dataColumnsDao andFeatureRow:featureRow andColumnName:columnName];
                    
                    if(i == geometryColumn){
                        geometryColumnName = columnName;
                        if(projection != nil){
                            GPKGGeometryData * geomData = (GPKGGeometryData *) value;
                            if(geomData != nil){
                                [self projectGeometry:geomData withProjection:projection];
                            }
                        }
                    }
                    
                    if(value != nil){
                        [values setObject:value forKey:columnName];
                    }
                }
                
                GPKGFeatureRowData * featureRowData = [[GPKGFeatureRowData alloc] initWithValues:values andGeometryColumnName:geometryColumnName];
                [rows addObject:featureRowData];
            }
            
            tableData = [[GPKGFeatureTableData alloc] initWithName:[self.featureTiles getFeatureDao].tableName  andCount:featureCount andRows:rows];
        }else{
            tableData = [[GPKGFeatureTableData alloc] initWithName:[self.featureTiles getFeatureDao].tableName  andCount:featureCount];
        }
    }
    
    [results close];
    
    return tableData;
}

-(void) projectGeometry: (GPKGGeometryData *) geometryData withProjection: (GPKGProjection *) projection{
    
    if(geometryData.geometry != nil){
    
        GPKGSpatialReferenceSystemDao * srsDao = [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:[self.featureTiles getFeatureDao].database];
        NSNumber * srsId = geometryData.srsId;
        GPKGSpatialReferenceSystem * srs = (GPKGSpatialReferenceSystem *) [srsDao queryForIdObject:srsId];
        
        if(![projection isEqualToAuthority:srs.organization andNumberCode:srs.organizationCoordsysId]){
            
            GPKGProjection * geomProjection = [GPKGProjectionFactory projectionWithSrs:srs];
            GPKGProjectionTransform * transform = [[GPKGProjectionTransform alloc] initWithFromProjection:geomProjection andToProjection:projection];
            
            WKBGeometry * projectedGeometry = [transform transformWithGeometry:geometryData.geometry];
            [geometryData setGeometry:projectedGeometry];
            NSNumber *coordsysId = [NSNumber numberWithInteger:[[projection code] integerValue]];
            GPKGSpatialReferenceSystem *projectionSrs = [srsDao getOrCreateWithOrganization:[projection authority] andCoordsysId:coordsysId];
            [geometryData setSrsId:projectionSrs.srsId];
        }
   
    }
}

-(NSString *) buildMapClickMessageWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView{
    CLLocationCoordinate2D locationCoordinate = [mapView convertPoint:point toCoordinateFromView:mapView];
    return [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andMapView:mapView];
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView{
    return [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andMapView:mapView andProjection:nil];
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView andProjection: (GPKGProjection *) projection{
    
    // Get the zoom level
    double zoom = [GPKGMapUtils currentZoomWithMapView:mapView];
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox * boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:self.screenClickPercentage];
    
    NSString * message = [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andProjection:projection];
    
    return message;
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds{
    return [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andZoom:zoom andMapBounds:mapBounds andProjection:nil];
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andProjection: (GPKGProjection *) projection{
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox * boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapBounds:mapBounds andScreenPercentage:self.screenClickPercentage];
    
    NSString * message = [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andProjection:projection];
    
    return message;
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andClickBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    
    NSString * message = nil;
    
    // Verify the features are indexed and we are getting information
    if([self isIndexed] && (self.maxFeaturesInfo || self.featuresInfo)){
        
        @try {
            
            if([self onAtZoom:zoom andLocationCoordinate:locationCoordinate]){
                
                // Get the number of features in the tile location
                int tileFeatureCount = [self tileFeatureCountWithLocationCoordinate:locationCoordinate andDoubleZoom:zoom];
                
                // If more than a configured max features to draw
                if([self moreThanMaxFeatures:tileFeatureCount]){
                    
                    // Build the max features message
                    if(self.maxFeaturesInfo){
                        message = [self buildMaxFeaturesInfoMessageWithTileFeaturesCount:tileFeatureCount];
                    }
                    
                }
                // Else, query for the features near the click
                else if(self.featuresInfo){
                    
                    // Query for results and build the message
                    GPKGFeatureIndexResults * results = [self queryFeaturesWithBoundingBox:boundingBox withProjection:projection];
                    message = [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andLocationCoordinate:locationCoordinate andProjection:projection];
                }
            }
            
        }
        @catch (NSException *e) {
            NSLog(@"Build Map Click Message Error: %@", [e description]);
        }
    }
    
    return message;
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView{
    return [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andMapView:mapView andProjection:nil];
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView andProjection: (GPKGProjection *) projection{
    
    // Get the zoom level
    double zoom = [GPKGMapUtils currentZoomWithMapView:mapView];
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox * boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:self.screenClickPercentage];
    
    GPKGFeatureTableData * tableData = [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andProjection:projection];
    
    return tableData;
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds{
    return [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andZoom:zoom andMapBounds:mapBounds andProjection:nil];
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andProjection: (GPKGProjection *) projection{
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox * boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapBounds:mapBounds andScreenPercentage:self.screenClickPercentage];
    
    GPKGFeatureTableData * tableData = [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andProjection:projection];
    
    return tableData;
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andClickBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    
    GPKGFeatureTableData * tableData = nil;
    
    // Verify the features are indexed and we are getting information
    if([self isIndexed] && (self.maxFeaturesInfo || self.featuresInfo)){
        
        @try {
            
            if([self onAtZoom:zoom andLocationCoordinate:locationCoordinate]){
                
                // Get the number of features in the tile location
                int tileFeatureCount = [self tileFeatureCountWithLocationCoordinate:locationCoordinate andDoubleZoom:zoom];
                
                // If more than a configured max features to draw
                if([self moreThanMaxFeatures:tileFeatureCount]){
                    
                    // Build the max features message
                    if(self.maxFeaturesInfo){
                        tableData = [[GPKGFeatureTableData alloc] initWithName:[self.featureTiles getFeatureDao].tableName andCount:tileFeatureCount];
                    }
                    
                }
                // Else, query for the features near the click
                else if(self.featuresInfo){
                    
                    // Query for results and build the message
                    GPKGFeatureIndexResults * results = [self queryFeaturesWithBoundingBox:boundingBox withProjection:projection];
                    tableData = [self buildTableDataAndCloseWithFeatureIndexResults:results andLocationCoordinate:locationCoordinate andProjection:projection];
                }
            }
            
        }
        @catch (NSException *e) {
            NSLog(@"Build Map Click Message Error: %@", [e description]);
        }
    }
    
    return tableData;
}

-(GPKGDataColumnsDao *) getDataColumnsDao{
    
    GPKGDataColumnsDao * dataColumnsDao = [[GPKGDataColumnsDao alloc] initWithDatabase:[self.featureTiles getFeatureDao].database];
    
    if(![dataColumnsDao tableExists]){
        dataColumnsDao = nil;
    }
    
    return dataColumnsDao;
}

-(NSString *) getColumnNameWithDataColumnsDao: (GPKGDataColumnsDao *) dataColumnsDao andFeatureRow: (GPKGFeatureRow *) featureRow andColumnName: (NSString *) columnName{
    
    NSString * newColumnName = columnName;
    
    if(dataColumnsDao != nil){
        GPKGDataColumns * dataColumn = [dataColumnsDao getDataColumnByTableName:featureRow.table.tableName andColumnName:columnName];
        if(dataColumn != nil){
            newColumnName = dataColumn.name;
        }
    }
    
    return newColumnName;
}

@end
