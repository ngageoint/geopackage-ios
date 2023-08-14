//
//  GPKGTileReprojection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojection.h"
#import "GPKGTileCreator.h"
#import "GPKGSQLiteMaster.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGUtils.h"

@interface GPKGTileReprojection ()

@property (nonatomic, strong) GPKGTileDao *tileDao;

@property (nonatomic, strong) GPKGGeoPackage *geoPackage;

@property (nonatomic, strong) NSString *table;

@property (nonatomic, strong) PROJProjection *projection;

@property (nonatomic, strong) GPKGTileDao *reprojectTileDao;

@property (nonatomic) BOOL replace;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, GPKGTileReprojectionZoom *> *zoomConfigs;

@property (nonatomic, strong) GPKGTileGrid *optimizeTileGrid;

@property (nonatomic) int optimizeZoom;

@end

@implementation GPKGTileReprojection

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (PROJProjection *) projection{
    return [self createWithGeoPackage:geoPackage andTable:table toTable:table inProjection:projection];
}

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTable: (NSString *) reprojectTable inProjection: (PROJProjection *) projection{
    return [self createWithGeoPackage:geoPackage andTable:table toGeoPackage:geoPackage andTable:reprojectTable inProjection:projection];
}

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTable: (NSString *) reprojectTable inProjection: (PROJProjection *) projection{
    return [self createWithTileDao:[geoPackage tileDaoWithTableName:table] toGeoPackage:reprojectGeoPackage andTable:reprojectTable inProjection:projection];
}

+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (PROJProjection *) projection{
    return [[GPKGTileReprojection alloc] initWithTileDao:tileDao toGeoPackage:geoPackage andTable:table inProjection:projection];
}

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTileDao: (GPKGTileDao *) reprojectTileDao{
    return [self createWithTileDao:[geoPackage tileDaoWithTableName:table] toTileDao:reprojectTileDao];
}

+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toTileDao: (GPKGTileDao *) reprojectTileDao{
    return [[GPKGTileReprojection alloc] initWithTileDao:tileDao toTileDao:reprojectTileDao];
}

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTileDao: (GPKGTileDao *) reprojectTileDao{
    return [self createWithTileDao:[geoPackage tileDaoWithTableName:table] toGeoPackage:reprojectGeoPackage andTileDao:reprojectTileDao];
}

+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) reprojectTileDao{
    return [[GPKGTileReprojection alloc] initWithTileDao:tileDao toGeoPackage:geoPackage andTileDao:reprojectTileDao];
}

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andOptimize: (GPKGTileReprojectionOptimize *) optimize{
    return [self createWithGeoPackage:geoPackage andTable:table toTable:table andOptimize:optimize];
}

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTable: (NSString *) reprojectTable andOptimize: (GPKGTileReprojectionOptimize *) optimize{
    return [self createWithGeoPackage:geoPackage andTable:table toGeoPackage:geoPackage andTable:reprojectTable andOptimize:optimize];
}

+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTable: (NSString *) reprojectTable andOptimize: (GPKGTileReprojectionOptimize *) optimize{
    return [self createWithTileDao:[geoPackage tileDaoWithTableName:table] toGeoPackage:reprojectGeoPackage andTable:reprojectTable andOptimize:optimize];
}

+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andOptimize: (GPKGTileReprojectionOptimize *) optimize{
    GPKGTileReprojection *tileReprojection = [[GPKGTileReprojection alloc] initWithTileDao:tileDao toGeoPackage:geoPackage andTable:table inProjection:[optimize projection]];
    [tileReprojection setOptimize:optimize];
    return tileReprojection;
}

+(int) reprojectGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (PROJProjection *) projection{
    return [[self createWithGeoPackage:geoPackage andTable:table inProjection:projection] reproject];
}

+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTable: (NSString *) reprojectTable inProjection: (PROJProjection *) projection{
    return [[self createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:projection] reproject];
}

+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTable: (NSString *) reprojectTable inProjection: (PROJProjection *) projection{
    return [[self createWithGeoPackage:geoPackage andTable:table toGeoPackage:reprojectGeoPackage andTable:reprojectTable inProjection:projection] reproject];
}

+(int) reprojectFromTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (PROJProjection *) projection{
    return [[self createWithTileDao:tileDao toGeoPackage:geoPackage andTable:table inProjection:projection] reproject];
}

+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTileDao: (GPKGTileDao *) reprojectTileDao{
    return [[self createWithGeoPackage:geoPackage andTable:table toTileDao:reprojectTileDao] reproject];
}

+(int) reprojectFromTileDao: (GPKGTileDao *) tileDao toTileDao: (GPKGTileDao *) reprojectTileDao{
    return [[self createWithTileDao:tileDao toTileDao:reprojectTileDao] reproject];
}

+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTileDao: (GPKGTileDao *) reprojectTileDao{
    return [[self createWithGeoPackage:geoPackage andTable:table toGeoPackage:reprojectGeoPackage andTileDao:reprojectTileDao] reproject];
}

+(int) reprojectFromTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) reprojectTileDao{
    return [[self createWithTileDao:tileDao toGeoPackage:geoPackage andTileDao:reprojectTileDao] reproject];
}

+(int) reprojectGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andOptimize: (GPKGTileReprojectionOptimize *) optimize{
    return [[self createWithGeoPackage:geoPackage andTable:table andOptimize:optimize] reproject];
}

+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTable: (NSString *) reprojectTable andOptimize: (GPKGTileReprojectionOptimize *) optimize{
    return [[self createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable andOptimize:optimize] reproject];
}

+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTable: (NSString *) reprojectTable andOptimize: (GPKGTileReprojectionOptimize *) optimize{
    return [[self createWithGeoPackage:geoPackage andTable:table toGeoPackage:reprojectGeoPackage andTable:reprojectTable andOptimize:optimize] reproject];
}

+(int) reprojectFromTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andOptimize: (GPKGTileReprojectionOptimize *) optimize{
    return [[self createWithTileDao:tileDao toGeoPackage:geoPackage andTable:table andOptimize:optimize] reproject];
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (PROJProjection *) projection{
    self = [super init];
    if(self != nil){
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
        _overwrite = NO;
        _replace = NO;
        _tileDao = tileDao;
        _reprojectTileDao = reprojectTileDao;
        _zoomConfigs = [NSMutableDictionary dictionary];
    }
    return self;
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) reprojectTileDao{
    self = [self initWithTileDao:tileDao toTileDao:reprojectTileDao];
    if(self != nil){
        _geoPackage = geoPackage;
    }
    return self;
}

-(NSMutableDictionary<NSNumber *,GPKGTileReprojectionZoom *> *) zoomConfigs{
    return _zoomConfigs;
}

-(GPKGTileReprojectionZoom *) configForZoom: (int) zoom{
    return [GPKGUtils objectForKey:[NSNumber numberWithInt:zoom] inDictionary:_zoomConfigs];
}

-(GPKGTileReprojectionZoom *) configOrCreateForZoom: (int) zoom{
    GPKGTileReprojectionZoom *config = [self configForZoom:zoom];
    if(config == nil){
        config = [[GPKGTileReprojectionZoom alloc] initWithZoom:zoom];
        [self setConfig:config];
    }
    return config;
}

-(void) setConfig: (GPKGTileReprojectionZoom *) config{
    [GPKGUtils setObject:config forKey:[NSNumber numberWithInt:[config zoom]] inDictionary:_zoomConfigs];
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
        GPKGBoundingBox *contentsBoundingBox = boundingBox;
        GPKGSpatialReferenceSystem *srs = [[_geoPackage spatialReferenceSystemDao] srsWithProjection:_projection];
        
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
        
        if(_optimize != nil){
            boundingBox = [self optimizeWithBoundingBox:boundingBox];
        }
        
        GPKGTileTable *tileTable = nil;
        if([_geoPackage isTable:_table]){
            
            if(![_geoPackage isTileTable:_table]){
                [NSException raise:@"Existing Table" format:@"Table exists and is not a tile table: %@", _table];
            }
            
            _reprojectTileDao = [_geoPackage tileDaoWithTableName:_table];
            
            if(![_reprojectTileDao.projection isEqualToProjection:_projection]){
                [NSException raise:@"Table Projection" format:@"Existing tile table projection differs from the reprojection. Table: %@, Projection: %@, Reprojection: %@", _table, [_projection description], [_reprojectTileDao.projection description]];
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
                    
                    [[_reprojectTileDao tileMatrixDao] deleteByTableName:_table];
                    [_reprojectTileDao deleteAll];
                    
                }
            }
            
            GPKGContents *contents = [_reprojectTileDao contents];
            [contents setSrs:srs];
            [contents setMinX:contentsBoundingBox.minLongitude];
            [contents setMinY:contentsBoundingBox.minLatitude];
            [contents setMaxX:contentsBoundingBox.maxLongitude];
            [contents setMaxY:contentsBoundingBox.maxLatitude];
            [[_geoPackage contentsDao] update:contents];
            
            [tileMatrixSet setSrs:srs];
            [tileMatrixSet setMinX:boundingBox.minLongitude];
            [tileMatrixSet setMinY:boundingBox.minLatitude];
            [tileMatrixSet setMaxX:boundingBox.maxLongitude];
            [tileMatrixSet setMaxY:boundingBox.maxLatitude];
            [[_reprojectTileDao tileMatrixSetDao] update:tileMatrixSet];

        }else{
            tileTable = [_geoPackage createTileTableWithMetadata:[GPKGTileTableMetadata createWithTable:_table andContentsBoundingBox:contentsBoundingBox andTileBoundingBox:boundingBox andTileSrsId:srs.srsId]];
            _reprojectTileDao = [_geoPackage tileDaoWithTable:tileTable];
        }
    }
}

-(void) finish{
    BOOL active = [self isActive];
    if(_replace){
        if(active){
            [_geoPackage deleteTable:_tileDao.tableName];
            [_geoPackage copyTable:_reprojectTileDao.tableName toTable:_tileDao.tableName];
            [_geoPackage deleteTable:_reprojectTileDao.tableName];
            _reprojectTileDao = nil;
        }
        _table = _tileDao.tableName;
        _replace = NO;
    }
    if(_progress != nil){
        if(active){
            [_progress completed];
        }else{
            if([_progress cleanupOnCancel]){
                if(_geoPackage == nil){
                    [NSException raise:@"Geographic Cleanup" format:@"Reprojeciton cleanup not supported when constructed without the GeoPackage. GeoPackage: %@, Tile Table: %@", _reprojectTileDao.databaseName, _reprojectTileDao.tableName];
                }
                [_geoPackage deleteTable:_reprojectTileDao.tableName];
            }
            [_progress failureWithError:@"Operation was canceled"];
        }
    }
}

-(int) reproject{
    [self initialize];
    
    int tiles = 0;
    
    for(GPKGTileMatrix *tileMatrix in _tileDao.tileMatrices){
        
        if(![self isActive]){
            break;
        }
        
        tiles += [self reprojectIfExistsWithZoom:[tileMatrix.zoomLevel intValue]];
        
    }
    
    [self finish];
    return tiles;
}

-(int) reprojectWithMinZoom: (int) minZoom andMaxZoom: (int) maxZoom{
    [self initialize];
    
    int tiles = 0;
    
    for(int zoom = minZoom; zoom <= maxZoom; zoom++){
        
        if(![self isActive]){
            break;
        }
        
        tiles += [self reprojectIfExistsWithZoom:zoom];
        
    }
    
    [self finish];
    return tiles;
}

-(int) reprojectWithZooms: (NSArray<NSNumber *> *) zooms{
    [self initialize];
    
    int tiles = 0;
    
    for(NSNumber *zoom in zooms){
        
        if(![self isActive]){
            break;
        }
        
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
    
    if(_optimizeTileGrid != nil){
        
        toZoom = [self.tileDao mapZoomWithTileMatrix:tileMatrix];
        
        GPKGTileGrid *tileGrid = [GPKGTileBoundingBoxUtils tileGrid:_optimizeTileGrid zoomFrom:_optimizeZoom to:toZoom];
        matrixWidth = [NSNumber numberWithInt:[tileGrid width]];
        matrixHeight = [NSNumber numberWithInt:[tileGrid height]];
        
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
        || ![GPKGUtils compareDouble:[toTileMatrix.pixelXSize doubleValue] withDouble:pixelXSize andDelta:pixelSizeDelta]
        || ![GPKGUtils compareDouble:[toTileMatrix.pixelYSize doubleValue] withDouble:pixelYSize andDelta:pixelSizeDelta]){

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
        
        for(int tileColumn = tileGrid.minX; [self isActive] && tileColumn <= tileGrid.maxX; tileColumn++){
            
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
                
                if(_progress != nil){
                    [_progress addProgress:1];
                }
            }
        }
        
    }
    
    return tiles;
}

-(GPKGBoundingBox *) optimizeWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    
    if(_optimize.world){
        _optimizeZoom = 0;
        _optimizeTileGrid = [_optimize tileGrid];
        boundingBox = [_optimize boundingBox];
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromProjection:[_optimize projection] andToProjection:_projection];
        if(![transform isSameProjection]){
            boundingBox = [boundingBox transform:transform];
        }
        [transform destroy];
    }else{
        _optimizeZoom = [self.tileDao mapZoomWithTileMatrix:[_tileDao tileMatrixAtMinZoom]];
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromProjection:_projection andToProjection:[_optimize projection]];
        if(![transform isSameProjection]){
            boundingBox = [boundingBox transform:transform];
        }
        _optimizeTileGrid = [_optimize tileGridWithBoundingBox:boundingBox andZoom:_optimizeZoom];
        boundingBox = [_optimize boundingBoxWithTileGrid:_optimizeTileGrid andZoom:_optimizeZoom];
        if(![transform isSameProjection]){
            SFPGeometryTransform *inverseTransform = [transform inverseTransformation];
            boundingBox = [boundingBox transform:inverseTransform];
            [inverseTransform destroy];
        }
        [transform destroy];
    }
    
    return boundingBox;
}

-(BOOL) isActive{
    return _progress == nil || [_progress isActive];
}

@end
