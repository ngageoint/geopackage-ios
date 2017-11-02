//
//  GPKGFeatureInfoBuilder.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/1/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGFeatureInfoBuilder.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "WKBGeometryPrinter.h"
#import "GPKGDataColumnsDao.h"
#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGProjectionTransform.h"
#import "GPKGFeatureIndexListResults.h"
#import "GPKGMapShapeConverter.h"
#import "GPKGProjectionFactory.h"
#import "GPKGMapUtils.h"

@interface GPKGFeatureInfoBuilder ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;
@property (nonatomic) enum WKBGeometryType geometryType;

@end

@implementation GPKGFeatureInfoBuilder

-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self != nil){
        
        self.featureDao = featureDao;
        
        self.geometryType = [featureDao getGeometryType];
        self.name = [NSString stringWithFormat:@"%@ - %@", featureDao.databaseName, featureDao.tableName];
        
        self.maxPointDetailedInfo = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_MAX_POINT_DETAILED_INFO] intValue];
        self.maxFeatureDetailedInfo = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_MAX_FEATURE_DETAILED_INFO] intValue];
        
        self.detailedInfoPrintPoints = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_DETAILED_INFO_PRINT_POINTS];
        self.detailedInfoPrintFeatures = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_DETAILED_INFO_PRINT_FEATURES];
    }
    return self;
}

-(enum WKBGeometryType) geometryType{
    return _geometryType;
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results{
    return [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andProjection:nil];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andProjection: (GPKGProjection *) projection{
    return [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andMapView:nil andTolerance:0 andPoint:nil andProjection:projection];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andMapView: (MKMapView *) mapView andTolerance: (double) tolerance andPoint: (WKBPoint *) point{
    return [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andMapView:mapView andTolerance:tolerance andPoint:point andProjection:nil];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andMapView: (MKMapView *) mapView andTolerance: (double) tolerance andPoint: (WKBPoint *) point andProjection: (GPKGProjection *) projection{
    CLLocationCoordinate2D locationCoordinate;
    if(point != nil){
        locationCoordinate = CLLocationCoordinate2DMake([point.y doubleValue], [point.x doubleValue]);
    }else{
        locationCoordinate = kCLLocationCoordinate2DInvalid;
    }
    return [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andMapView:mapView andTolerance:tolerance andLocationCoordinate:locationCoordinate andProjection:projection];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andMapView: (MKMapView *) mapView andTolerance: (double) tolerance andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate{
    return [self buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andMapView:mapView andTolerance:tolerance andLocationCoordinate:locationCoordinate andProjection:nil];
}

-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andMapView: (MKMapView *) mapView andTolerance: (double) tolerance andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andProjection: (GPKGProjection *) projection{
    
    NSMutableString * message = nil;
    
    // Fine filter results so that the click location is within the tolerance of each feature row result
    GPKGFeatureIndexResults *filteredResults = [self fineFilterResults:results withMapView:mapView andTolerance:tolerance andLocation:locationCoordinate];
    
    int featureCount = filteredResults.count;
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
            
            for(GPKGFeatureRow * featureRow in filteredResults){
                
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
            if(CLLocationCoordinate2DIsValid(locationCoordinate)){
                [message appendString:@" near location:\n"];
                WKBPoint *point = [[WKBPoint alloc] initWithXValue:locationCoordinate.longitude andYValue:locationCoordinate.latitude];
                [message appendFormat:@"%@", [WKBGeometryPrinter getGeometryString:point]];
            }
        }
    }
    
    [results close];
    
    return message;
}

-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andMapView: (MKMapView *) mapView andTolerance: (double) tolerance andPoint: (WKBPoint *) point{
    return [self buildTableDataAndCloseWithFeatureIndexResults:results andMapView:mapView andTolerance:tolerance andPoint:point andProjection:nil];
}

-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andMapView: (MKMapView *) mapView andTolerance: (double) tolerance andPoint: (WKBPoint *) point andProjection: (GPKGProjection *) projection{
    CLLocationCoordinate2D locationCoordinate;
    if(point != nil){
        locationCoordinate = CLLocationCoordinate2DMake([point.y doubleValue], [point.x doubleValue]);
    }else{
        locationCoordinate = kCLLocationCoordinate2DInvalid;
    }
    return [self buildTableDataAndCloseWithFeatureIndexResults:results andMapView:mapView andTolerance:tolerance andLocationCoordinate:locationCoordinate andProjection:projection];
}

-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andMapView: (MKMapView *) mapView andTolerance: (double) tolerance andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate{
    return [self buildTableDataAndCloseWithFeatureIndexResults:results andMapView:mapView andTolerance:tolerance andLocationCoordinate:locationCoordinate andProjection:nil];
}

-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andMapView: (MKMapView *) mapView andTolerance: (double) tolerance andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andProjection: (GPKGProjection *) projection{
    
    GPKGFeatureTableData * tableData = nil;
    
    // Fine filter results so that the click location is within the tolerance of each feature row result
    GPKGFeatureIndexResults *filteredResults = [self fineFilterResults:results withMapView:mapView andTolerance:tolerance andLocation:locationCoordinate];
    
    int featureCount = filteredResults.count;
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
            
            for(GPKGFeatureRow * featureRow in filteredResults){
                
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
            
            tableData = [[GPKGFeatureTableData alloc] initWithName:self.featureDao.tableName  andCount:featureCount andRows:rows];
        }else{
            tableData = [[GPKGFeatureTableData alloc] initWithName:self.featureDao.tableName  andCount:featureCount];
        }
    }
    
    [results close];
    
    return tableData;
}

-(void) projectGeometry: (GPKGGeometryData *) geometryData withProjection: (GPKGProjection *) projection{
    
    if(geometryData.geometry != nil){
        
        GPKGSpatialReferenceSystemDao * srsDao = [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.featureDao.database];
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

-(GPKGDataColumnsDao *) getDataColumnsDao{
    
    GPKGDataColumnsDao * dataColumnsDao = [[GPKGDataColumnsDao alloc] initWithDatabase:self.featureDao.database];
    
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

-(GPKGFeatureIndexResults *) fineFilterResults: (GPKGFeatureIndexResults *) results withMapView: (MKMapView *) mapView andTolerance: (double) tolerance andLocation: (CLLocationCoordinate2D) clickLocation{
    
    GPKGFeatureIndexResults *filteredResults = nil;
    if(self.geometryType == WKB_POINT || !CLLocationCoordinate2DIsValid(clickLocation)){
        filteredResults = results;
    }else{
        
        GPKGFeatureIndexListResults *filteredListResults = [[GPKGFeatureIndexListResults alloc] init];
        
        GPKGMapShapeConverter *converter = [[GPKGMapShapeConverter alloc] initWithProjection:self.featureDao.projection];
        
        for (GPKGFeatureRow *featureRow in results) {
            
            GPKGGeometryData *geomData = [featureRow getGeometry];
            if (geomData != nil) {
                WKBGeometry *geometry = geomData.geometry;
                if (geometry != nil) {
                    
                    GPKGMapShape *mapShape = [converter toShapeWithGeometry:geometry];
                    if([GPKGMapUtils isLocation:clickLocation onShape:mapShape withMapView:mapView andTolerance:tolerance]){
                        
                        [filteredListResults addRow:featureRow];
                        
                    }
                    
                }
            }
            
        }
        
        filteredResults = filteredListResults;
    }
    
    return filteredResults;
}

@end
