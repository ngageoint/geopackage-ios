//
//  GPKGFeaturePreview.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGFeaturePreview.h"
#import "GPKGSqlUtils.h"
#import "PROJProjectionFactory.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "PROJProjectionConstants.h"

@interface GPKGFeaturePreview ()

/**
 * GeoPackage
 */
@property (nonatomic, strong) GPKGGeoPackage *geoPackage;

/**
 * Feature Tiles for drawing
 */
@property (nonatomic, strong) GPKGFeatureTiles *featureTiles;

/**
 * Query columns
 */
@property (nonatomic, strong) NSMutableSet<NSString *> *columns;

@end

@implementation GPKGFeaturePreview

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) featureTable{
    return [self initWithGeoPackage:geoPackage andFeatureDao:[geoPackage featureDaoWithTableName:featureTable]];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao{
    return [self initWithGeoPackage:geoPackage andFeatureTiles:[[GPKGFeatureTiles alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao]];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureTiles: (GPKGFeatureTiles *) featureTiles{
    self = [super init];
    if(self != nil){
        _bufferPercentage = 0.0;
        _columns = [NSMutableSet set];
        _geoPackage = geoPackage;
        _featureTiles = featureTiles;
        GPKGFeatureDao *featureDao = [featureTiles featureDao];
        [_columns addObject:[featureDao idColumnName]];
        [_columns addObject:[featureDao geometryColumnName]];
        _where = [NSString stringWithFormat:@"%@ IS NOT NULL", [GPKGSqlUtils quoteWrapName:[featureDao geometryColumnName]]];
    }
    return self;
}

-(GPKGGeoPackage *) geoPackage{
    return _geoPackage;
}

-(GPKGFeatureTiles *) featureTiles{
    return _featureTiles;
}

-(void) setBufferPercentage: (double) bufferPercentage{
    if (bufferPercentage < 0.0 || bufferPercentage >= 0.5) {
        [NSException raise:@"Out of Range" format:@"Buffer percentage must be in the range: 0.0 <= bufferPercentage < 0.5. invalid value: %f", bufferPercentage];
    }
    _bufferPercentage = bufferPercentage;
}

-(NSSet<NSString *> *) columns{
    return _columns;
}

-(void) addColumns: (NSArray<NSString *> *) columns{
    [_columns addObjectsFromArray:columns];
}

-(void) addColumn: (NSString *) column{
    [_columns addObject:column];
}

-(void) appendWhere: (NSString *) where{
    if(_where == nil){
        _where = where;
    }else{
        _where = [NSString stringWithFormat:@"%@ AND %@", _where, where];
    }
}

-(UIImage *) draw{
    
    UIImage *image = nil;

    GPKGFeatureDao *featureDao = [_featureTiles featureDao];
    NSString *table = featureDao.tableName;

    PROJProjection *webMercator = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];

    GPKGBoundingBox *boundingBox = [_geoPackage featureBoundingBoxOfTable:table inProjection:webMercator andManual:NO];
    if(boundingBox == nil){
        boundingBox = [_geoPackage contentsBoundingBoxOfTable:table inProjection:webMercator];
    }
    if(boundingBox == nil && _manual){
        boundingBox = [_geoPackage featureBoundingBoxOfTable:table inProjection:webMercator andManual:_manual];
    }
    if(boundingBox != nil){
        boundingBox = [GPKGTileBoundingBoxUtils boundWebMercatorBoundingBox:boundingBox];
        GPKGBoundingBox *expandedBoundingBox = [boundingBox squareExpandWithBuffer:_bufferPercentage];
        expandedBoundingBox = [GPKGTileBoundingBoxUtils boundWebMercatorBoundingBox:expandedBoundingBox];
        int zoom = [GPKGTileBoundingBoxUtils zoomLevelWithWebMercatorBoundingBox:expandedBoundingBox];
        
        GPKGResultSet *results = [featureDao queryWithColumns:[_columns allObjects] andWhere:_where andWhereArgs:_whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil andLimit:_limit != nil ? [_limit stringValue] : nil];
        image = [_featureTiles drawTileWithZoom:zoom andBoundingBox:expandedBoundingBox andResults:results];
    }

    return image;
}

-(void) close{
    [_featureTiles close];
}

@end
