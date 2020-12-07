//
//  GPKGTileReprojection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojection.h"
#import "GPKGTileTableMetadata.h"
#import "GPKGTileCreator.h"
#import "GPKGSQLiteMaster.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGUtils.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionConstants.h"
#import "GPKGTileGridBoundingBox.h"

@interface GPKGTileReprojection ()

@property (nonatomic, strong) GPKGTileDao *tileDao;

@property (nonatomic, strong) GPKGGeoPackage *geoPackage;

@property (nonatomic, strong) NSString *table;

@property (nonatomic, strong) SFPProjection *projection;

@property (nonatomic, strong) GPKGTileDao *reprojectTileDao;

@property (nonatomic) BOOL replace;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, GPKGTileReprojectionZoom *> *zoomConfigs;

@end

@implementation GPKGTileReprojection

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (SFPProjection *) projection{
    return [self createWithGeoPackage:geoPackage andTable:table toTable:table inProjection:projection];
}

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTable: (NSString *) reprojectTable inProjection: (SFPProjection *) projection{
    return [self createWithGeoPackage:geoPackage andTable:table toGeoPackage:geoPackage andTable:reprojectTable inProjection:projection];
}

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTable: (NSString *) reprojectTable inProjection: (SFPProjection *) projection{
    return [self createWithTileDao:[geoPackage tileDaoWithTableName:table] toGeoPackage:reprojectGeoPackage andTable:reprojectTable inProjection:projection];
}

+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (SFPProjection *) projection{
    return [[GPKGTileReprojection alloc] initWithTileDao:tileDao toGeoPackage:geoPackage andTable:table inProjection:projection];
}

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTileDao: (GPKGTileDao *) reprojectTileDao{
    return [self createWithTileDao:[geoPackage tileDaoWithTableName:table] toTileDao:reprojectTileDao];
}

+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toTileDao: (GPKGTileDao *) reprojectTileDao{
    return [[GPKGTileReprojection alloc] initWithTileDao:tileDao toTileDao:reprojectTileDao];
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (SFPProjection *) projection{
    self = [super init];
    if(self != nil){
        _optimize = NO;
        _overwrite = NO;
        _replace = NO;
        _tileDao = tileDao;
        _geoPackage = geoPackage;
        _table = table;
        _projection = projection;
        _zoomConfigs = [NSMutableDictionary dictionary];
    }
    return self;
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao toTileDao: (GPKGTileDao *) reprojectTileDao{
    self = [super init];
    if(self != nil){
        _optimize = NO;
        _overwrite = NO;
        _replace = NO;
        _tileDao = tileDao;
        _reprojectTileDao = reprojectTileDao;
        _zoomConfigs = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSDictionary<NSNumber *,GPKGTileReprojectionZoom *> *) zoomConfigs{
    return _zoomConfigs;
}

-(GPKGTileReprojectionZoom *) configForZoom: (int) zoom{
    return [GPKGUtils objectForKey:[NSNumber numberWithInt:zoom] inDictionary:_zoomConfigs];
}

-(GPKGTileReprojectionZoom *) configOrCreateForZoom: (int) zoom{
    GPKGTileReprojectionZoom *config = [self configForZoom:zoom];
    if(config == nil){
        config = [[GPKGTileReprojectionZoom alloc] initWithZoom:zoom];
        [self setConfig:config forZoom:zoom];
    }
    return config;
}

-(void) setConfig: (GPKGTileReprojectionZoom *) config forZoom: (int) zoom{
    [GPKGUtils setObject:config forKey:[NSNumber numberWithInt:zoom] inDictionary:_zoomConfigs];
}

-(void) setToZoom: (int) toZoom forZoom: (int) zoom{
    [[self configOrCreateForZoom:zoom] setToZoom:[NSNumber numberWithInt:toZoom]];
}

-(int) toZoomForZoom: (int) zoom{
    int toZoom = zoom;
    GPKGTileReprojectionZoom *config = [self configForZoom:zoom];
    if(config != nil && [config hasToZoom]){
        toZoom = [config.toZoom intValue];
    }
    return toZoom;
}

-(void) setTileWidth: (int) tileWidth forZoom: (int) zoom{
    [[self configOrCreateForZoom:zoom] setTileWidth:[NSNumber numberWithInt:tileWidth]];
}

-(NSNumber *) tileWidthForZoom: (int) zoom{
    NSNumber *tileWidth = _tileWidth;
    GPKGTileReprojectionZoom *config = [self configForZoom:zoom];
    if(config != nil && [config hasTileWidth]){
        tileWidth = config.tileWidth;
    }
    return tileWidth;
}

-(void) setTileHeight: (int) tileHeight forZoom: (int) zoom{
    [[self configOrCreateForZoom:zoom] setTileHeight:[NSNumber numberWithInt:tileHeight]];
}

-(NSNumber *) tileHeightForZoom: (int) zoom{
    NSNumber *tileHeight = _tileHeight;
    GPKGTileReprojectionZoom *config = [self configForZoom:zoom];
    if(config != nil && [config hasTileHeight]){
        tileHeight = config.tileHeight;
    }
    return tileHeight;
}

-(void) setMatrixWidth: (int) matrixWidth forZoom: (int) zoom{
    [[self configOrCreateForZoom:zoom] setMatrixWidth:[NSNumber numberWithInt:matrixWidth]];
}

-(NSNumber *) matrixWidthForZoom: (int) zoom{
    NSNumber *matrixWidth = nil;
    GPKGTileReprojectionZoom *config = [self configForZoom:zoom];
    if(config != nil && [config hasMatrixWidth]){
        matrixWidth = config.matrixWidth;
    }
    return matrixWidth;
}

-(void) setMatrixHeight: (int) matrixHeight forZoom: (int) zoom{
    [[self configOrCreateForZoom:zoom] setMatrixHeight:[NSNumber numberWithInt:matrixHeight]];
}

-(NSNumber *) matrixHeightForZoom: (int) zoom{
    NSNumber *matrixHeight = nil;
    GPKGTileReprojectionZoom *config = [self configForZoom:zoom];
    if(config != nil && [config hasMatrixHeight]){
        matrixHeight = config.matrixHeight;
    }
    return matrixHeight;
}

-(void) initialize{
    if(_reprojectTileDao == nil){
        
        GPKGBoundingBox *boundingBox = [_tileDao boundingBoxInProjection:_projection];
        GPKGSpatialReferenceSystem *srs = [[_geoPackage spatialReferenceSystemDao] srsWithOrganization:_projection.authority andCoordsysId:[NSNumber numberWithInt:[_projection.code intValue]]];
        
        if([_tileDao.databaseName isEqualToString:_geoPackage.name] && [_tileDao.tableName caseInsensitiveCompare:_table] == NSOrderedSame){
            // Replacing source table, find a temp table name for the reprojections
            int count = 1;
            NSString *tempTable = [NSString stringWithFormat:@"%@_%d", _table, ++count];
            while([GPKGSQLiteMaster countWithConnection:_tileDao.database andQuery:[GPKGSQLiteMasterQuery createWithColumn:GPKG_SMC_NAME andValue:tempTable]] > 0){
                tempTable = [NSString stringWithFormat:@"%@_%d", _table, ++count];
            }
            _table = tempTable;
            _replace = YES;
        }
        
        if(_optimize){
            
            GPKGTileMatrix *tileMatrix = [_reprojectTileDao tileMatrixAtMinZoom];
            GPKGTileGridBoundingBox *tileGridBoundingBox = [self optimizeWithBoundingBox:boundingBox andTileMatrix:tileMatrix];
            
            if(tileGridBoundingBox != nil){
                boundingBox = tileGridBoundingBox.boundingBox;
            }
            
        }
        
        GPKGTileTable *tileTable = nil;
        if([_geoPackage isTable:_table]){
            
            if(![_geoPackage isTileTable:_table]){
                [NSException raise:@"Existing Table" format:@"Table exists and is not a tile table: %@", _table];
            }
            
            _reprojectTileDao = [_geoPackage tileDaoWithTableName:_table];
            
            if(![_reprojectTileDao.projection isEqualToProjection:_projection]){
                [NSException raise:@"Table Projection" format:@"Existing tile table projection differs from the reprojection. Table: %@, Projection: %@, Reprojection: %@", _table, [_reprojectTileDao.projection description], [_projection description]];
            }
            
            GPKGTileMatrixSet *tileMatrixSet = _reprojectTileDao.tileMatrixSet;
            
            if(_reprojectTileDao.tileMatrices.count > 0){
                
                GPKGTileMatrix *tileMatrix = [_reprojectTileDao tileMatrixAtMinZoom];
                
                if(fabs([[tileMatrixSet.minX decimalNumberBySubtracting:boundingBox.minLongitude] doubleValue]) > [tileMatrix.pixelXSize doubleValue]
                   || fabs([[tileMatrixSet.minY decimalNumberBySubtracting:boundingBox.minLatitude] doubleValue]) > [tileMatrix.pixelYSize doubleValue]
                   || fabs([[tileMatrixSet.maxX decimalNumberBySubtracting:boundingBox.maxLongitude] doubleValue]) > [tileMatrix.pixelXSize doubleValue]
                   || fabs([[tileMatrixSet.maxY decimalNumberBySubtracting:boundingBox.maxLatitude] doubleValue]) > [tileMatrix.pixelYSize doubleValue]){
                    
                    if(!_overwrite){
                        [NSException raise:@"Geographic Properties" format:@"Existing Tile Matrix Set Geographic Properties differ. Enable 'overwrite' to replace all tiles. GeoPackage: %@, Tile Table: %@", _reprojectTileDao.databaseName, _reprojectTileDao.tableName];
                    }
                    
                    [[_reprojectTileDao tileMatrixDao] deleteById:_table];
                    [_reprojectTileDao deleteAll];
                    
                }
            }
            
            GPKGContents *contents = [_reprojectTileDao contents];
            [contents setSrs:srs];
            [contents setMinX:boundingBox.minLongitude];
            [contents setMinY:boundingBox.minLatitude];
            [contents setMaxX:boundingBox.maxLongitude];
            [contents setMaxY:boundingBox.maxLatitude];
            [[_geoPackage contentsDao] update:contents];
            
            [tileMatrixSet setSrs:srs];
            [tileMatrixSet setMinX:boundingBox.minLongitude];
            [tileMatrixSet setMinY:boundingBox.minLatitude];
            [tileMatrixSet setMaxX:boundingBox.maxLongitude];
            [tileMatrixSet setMaxY:boundingBox.maxLatitude];
            [[_reprojectTileDao tileMatrixSetDao] update:tileMatrixSet];

        }else{
            tileTable = [_geoPackage createTileTableWithMetadata:[GPKGTileTableMetadata createWithTable:_table andTileBoundingBox:boundingBox andTileSrsId:srs.srsId]];
            _reprojectTileDao = [_geoPackage tileDaoWithTable:tileTable];
        }
    }
}

-(void) finish{
    if(_replace){
        [_geoPackage deleteTable:_tileDao.tableName];
        [_geoPackage copyTable:_reprojectTileDao.tableName toTable:_tileDao.tableName];
        [_geoPackage deleteTable:_reprojectTileDao.tableName];
        _reprojectTileDao = nil;
        _table = _tileDao.tableName;
        _replace = NO;
    }
}

-(int) reproject{
    [self initialize];
    
    int tiles = 0;
    
    for(GPKGTileMatrix *tileMatrix in _tileDao.tileMatrices){
        tiles += [self reprojectIfExistsWithZoom:[tileMatrix.zoomLevel intValue]];
    }
    
    [self finish];
    return tiles;
}

-(int) reprojectWithMinZoom: (int) minZoom andMaxZoom: (int) maxZoom{
    [self initialize];
    
    int tiles = 0;
    
    for(int zoom = minZoom; zoom <= maxZoom; zoom++){
        
        tiles += [self reprojectIfExistsWithZoom:zoom];
        
    }
    
    [self finish];
    return tiles;
}

-(int) reprojectWithZooms: (NSArray<NSNumber *> *) zooms{
    [self initialize];
    
    int tiles = 0;
    
    for(NSNumber *zoom in zooms){
        
        tiles += [self reprojectIfExistsWithZoom:[zoom intValue]];
        
    }
    
    [self finish];
    return tiles;
}

-(int) reprojectWithZoom: (int) zoom{
    [self initialize];
    
    int tiles = [self reprojectIfExistsWithZoom:zoom];
    
    [self finish];
    return tiles;
}

-(int) reprojectIfExistsWithZoom: (int) zoom{
    
    int tiles = 0;
    
    GPKGTileMatrix *tileMatrix = [_tileDao tileMatrixWithZoomLevel:zoom];
    
    if(tileMatrix != nil){
        tiles = [self reprojectWithTileMatrix:tileMatrix];
    }
    
    return tiles;
}

-(int) reprojectWithTileMatrix: (GPKGTileMatrix *) tileMatrix{
    
    int tiles = 0;
    
    int zoom = [tileMatrix.zoomLevel intValue];
    int toZoom = [self toZoomForZoom:zoom];
    
    NSNumber *tileWidth = [self tileWidthForZoom:zoom];
    if(tileWidth == nil){
        tileWidth = tileMatrix.tileWidth;
    }
    
    NSNumber *tileHeight = [self tileHeightForZoom:zoom];
    if(tileHeight == nil){
        tileHeight = tileMatrix.tileHeight;
    }
    
    NSNumber *matrixWidth = [self matrixWidthForZoom:zoom];
    if(matrixWidth == nil){
        matrixWidth = tileMatrix.matrixWidth;
    }
    
    NSNumber *matrixHeight = [self matrixHeightForZoom:zoom];
    if(matrixHeight == nil){
        matrixHeight = tileMatrix.matrixHeight;
    }
    
    GPKGBoundingBox *boundingBox = [_reprojectTileDao boundingBox];
    
    if(_optimize){
        
        GPKGTileGridBoundingBox *tileGridBoundingBox = [self optimizeWithBoundingBox:boundingBox andTileMatrix:tileMatrix];
        
        if(tileGridBoundingBox != nil){
            toZoom = [tileGridBoundingBox.zoomLevel intValue];
            boundingBox = tileGridBoundingBox.boundingBox;
            GPKGTileGrid *tileGrid = tileGridBoundingBox.tileGrid;
            matrixWidth = [NSNumber numberWithInt:[tileGrid width]];
            matrixHeight = [NSNumber numberWithInt:[tileGrid height]];
        }
        
    }
    
    double minLongitude = [boundingBox.minLongitude doubleValue];
    double maxLatitude = [boundingBox.maxLatitude doubleValue];
    
    double longitudeRange = [boundingBox longitudeRangeValue];
    double latitudeRange = [boundingBox latitudeRangeValue];
    
    double pixelXSize = longitudeRange / [matrixWidth intValue] / [tileWidth intValue];
    double pixelYSize = latitudeRange / [matrixHeight intValue] / [tileHeight intValue];
    
    BOOL saveTileMatrix = YES;
    
    GPKGTileMatrix *toTileMatrix = [_reprojectTileDao tileMatrixWithZoomLevel:toZoom];
    if(toTileMatrix == nil){
        
        toTileMatrix = [[GPKGTileMatrix alloc] init];
        [toTileMatrix setTableName:_reprojectTileDao.tableName];
        [toTileMatrix setZoomLevel:[NSNumber numberWithInt:toZoom]];
        
    }else if(![toTileMatrix.matrixHeight isEqualToNumber:matrixHeight]
        || ![toTileMatrix.matrixWidth isEqualToNumber:matrixWidth]
        || ![toTileMatrix.tileHeight isEqualToNumber:tileHeight]
        || ![toTileMatrix.tileWidth isEqualToNumber:tileWidth]
        || ![GPKGUtils compareDouble:[toTileMatrix.pixelXSize doubleValue] withDouble:pixelXSize]
        || ![GPKGUtils compareDouble:[toTileMatrix.pixelYSize doubleValue] withDouble:pixelYSize]){
        
        if(!_overwrite){
            [NSException raise:@"Geographic Properties" format:@"Existing Tile Matrix Geographic Properties differ. Enable 'overwrite' to replace existing tiles at zoom level %d. GeoPackage: %@, Tile Table: %@", toZoom, _reprojectTileDao.databaseName, _reprojectTileDao.tableName];
        }
        
        // Delete the existing tiles at the zoom level
        GPKGColumnValues *fieldValues = [[GPKGColumnValues alloc] init];
        [fieldValues addColumn:GPKG_TC_COLUMN_ZOOM_LEVEL withValue:toTileMatrix.zoomLevel];
        [_reprojectTileDao deleteByFieldValues:fieldValues];

    }else{
        saveTileMatrix = NO;
    }
    
    if(saveTileMatrix){
        // Create or update the tile matrix
        [toTileMatrix setMatrixHeight:matrixHeight];
        [toTileMatrix setMatrixWidth:matrixWidth];
        [toTileMatrix setTileHeight:tileHeight];
        [toTileMatrix setTileWidth:tileWidth];
        [toTileMatrix setPixelXSizeValue:pixelXSize];
        [toTileMatrix setPixelYSizeValue:pixelYSize];
        [[_reprojectTileDao tileMatrixDao] createOrUpdate:toTileMatrix];
    }
    
    GPKGBoundingBox *zoomBounds = [_tileDao boundingBoxWithZoomLevel:zoom inProjection:_reprojectTileDao.projection];
    GPKGTileGrid *tileGrid = [GPKGTileBoundingBoxUtils tileGridWithTotalBoundingBox:boundingBox andMatrixWidth:[matrixWidth intValue] andMatrixHeight:[matrixHeight intValue] andBoundingBox:zoomBounds];
    
    GPKGTileCreator *tileCreator = [[GPKGTileCreator alloc] initWithTileDao:_tileDao andWidth:tileWidth andHeight:tileHeight andProjection:_reprojectTileDao.projection];
    
    for(int tileRow = tileGrid.minY; tileRow <= tileGrid.maxY; tileRow++){
        
        double tileMaxLatitude = maxLatitude - ((tileRow / [matrixHeight doubleValue]) * latitudeRange);
        double tileMinLatitude = maxLatitude - (((tileRow + 1) / [matrixHeight doubleValue]) * latitudeRange);
        
        for(int tileColumn = tileGrid.minX; tileColumn <= tileGrid.maxX; tileColumn++){
            
            double tileMinLongitude = minLongitude + ((tileColumn / [matrixWidth doubleValue]) * longitudeRange);
            double tileMaxLongitude = minLongitude + (((tileColumn + 1) / [matrixWidth doubleValue]) * longitudeRange);
            
            GPKGBoundingBox *tileBounds = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:tileMinLongitude andMinLatitudeDouble:tileMinLatitude andMaxLongitudeDouble:tileMaxLongitude andMaxLatitudeDouble:tileMaxLatitude];
            
            GPKGGeoPackageTile *tile = [tileCreator tileWithBoundingBox:tileBounds andZoom:zoom];
            
            if(tile != nil){
                
                GPKGTileRow *row = [_reprojectTileDao queryForTileWithColumn:tileColumn andRow:tileRow andZoomLevel:toZoom];
                
                if(row == nil){
                    row = [_reprojectTileDao newRow];
                    [row setTileColumn:tileColumn];
                    [row setTileRow:tileRow];
                    [row setZoomLevel:toZoom];
                }
                
                [row setTileData:tile.data];
                
                [_reprojectTileDao createOrUpdate:row];
                tiles++;
            }
        }
        
    }
    
    return tiles;
}

-(GPKGTileGridBoundingBox *) optimizeWithBoundingBox: (GPKGBoundingBox *) boundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix{
    
    GPKGTileGridBoundingBox *tileGridBoundingBox = nil;
    
    int zoom = [self.tileDao mapZoomWithTileMatrix:tileMatrix];
    
    GPKGTileGrid *tileGrid = nil;
    SFPProjection *projection = _reprojectTileDao.projection;
    switch([projection getUnit]){
        case SFP_UNIT_METERS:
            {
                SFPProjection *webMercator = [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
                SFPProjectionTransform *transform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:webMercator];
                GPKGBoundingBox *webMercatorBoundingBox = [boundingBox transform:transform];
                tileGrid = [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:webMercatorBoundingBox andZoom:zoom];
                webMercatorBoundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithTileGrid:tileGrid andZoom:zoom];
                boundingBox = [webMercatorBoundingBox transform:[transform inverseTransformation]];
            }
            break;
        case SFP_UNIT_DEGREES:
            {
                SFPProjection *wgs84 = [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
                SFPProjectionTransform *transform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:wgs84];
                GPKGBoundingBox *wgs84BoundingBox = [boundingBox transform:transform];
                tileGrid = [GPKGTileBoundingBoxUtils tileGridWithWgs84BoundingBox:wgs84BoundingBox andZoom:zoom];
                wgs84BoundingBox = [GPKGTileBoundingBoxUtils wgs84BoundingBoxWithTileGrid:tileGrid andZoom:zoom];
                boundingBox = [wgs84BoundingBox transform:[transform inverseTransformation]];
            }
            break;
        default:
            break;
    }
    
    if(tileGrid != nil){
        tileGridBoundingBox = [[GPKGTileGridBoundingBox alloc] initWithZoom:[NSNumber numberWithInt:zoom] andGrid:tileGrid andBoundingBox:boundingBox];
    }
    
    return tileGridBoundingBox;
}

@end
