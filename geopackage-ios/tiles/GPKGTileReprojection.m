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

@interface GPKGTileReprojection ()

@property (nonatomic, strong) GPKGTileDao *tileDao;

@property (nonatomic, strong) GPKGGeoPackage *geoPackage;

@property (nonatomic, strong) NSString *table;

@property (nonatomic, strong) SFPProjection *projection;

@property (nonatomic, strong) GPKGTileDao *reprojectTileDao;

@property (nonatomic) BOOL replace;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *zoomMapping;

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
        _optimize = YES;
        _overwrite = NO;
        _replace = NO;
        _tileDao = tileDao;
        _geoPackage = geoPackage;
        _table = table;
        _projection = projection;
        _zoomMapping = [NSMutableDictionary dictionary];
    }
    return self;
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao toTileDao: (GPKGTileDao *) reprojectTileDao{
    self = [super init];
    if(self != nil){
        _optimize = YES;
        _overwrite = NO;
        _replace = NO;
        _tileDao = tileDao;
        _reprojectTileDao = reprojectTileDao;
        _zoomMapping = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSDictionary<NSNumber *,NSNumber *> *) zoomMap{
    return _zoomMapping;
}

-(void) setZoomMap: (NSDictionary<NSNumber *,NSNumber *> *) zoomMap{
    if(zoomMap != nil){
        _zoomMapping = [NSMutableDictionary dictionaryWithDictionary:zoomMap];
    }else{
        [_zoomMapping removeAllObjects];
    }
}

-(void) mapFromZoom: (int) fromZoom toZoom: (int) toZoom{
    [_zoomMapping setObject:[NSNumber numberWithInt:toZoom] forKey:[NSNumber numberWithInt:fromZoom]];
}

-(int) zoomFromZoom: (int) fromZoom{
    int zoom = fromZoom;
    NSNumber *zoomNumber = [_zoomMapping objectForKey:[NSNumber numberWithInt:fromZoom]];
    if(zoomNumber != nil){
        zoom = [zoomNumber intValue];
    }
    return zoom;
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
                
                GPKGTileMatrix *tileMatrix = [_reprojectTileDao.tileMatrices objectAtIndex:0];
                
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
    
    int fromZoom = [tileMatrix.zoomLevel intValue];
    int toZoom = [self zoomFromZoom:fromZoom];
    
    NSNumber *tileWidth = _tileWidth;
    if(tileWidth == nil){
        tileWidth = tileMatrix.tileWidth;
    }
    
    NSNumber *tileHeight = _tileHeight;
    if(tileHeight == nil){
        tileHeight = tileMatrix.tileHeight;
    }
    
    int matrixWidth = [tileMatrix.matrixWidth intValue];
    int matrixHeight = [tileMatrix.matrixHeight intValue];
    // TODO optimize for XYZ and wgs84 tiles
    
    GPKGBoundingBox *bbox = [_reprojectTileDao boundingBox];
    
    double minLongitude = [bbox.minLongitude doubleValue];
    double maxLatitude = [bbox.maxLatitude doubleValue];
    
    double longitudeRange = [bbox longitudeRangeValue];
    double latitudeRange = [bbox latitudeRangeValue];
    
    double pixelXSize = longitudeRange / matrixWidth / [tileWidth intValue];
    double pixelYSize = latitudeRange / matrixHeight / [tileHeight intValue];
    
    BOOL saveTileMatrix = YES;
    
    GPKGTileMatrix *toTileMatrix = [_reprojectTileDao tileMatrixWithZoomLevel:toZoom];
    if(toTileMatrix == nil){
        
        toTileMatrix = [[GPKGTileMatrix alloc] init];
        [toTileMatrix setTableName:_reprojectTileDao.tableName];
        [toTileMatrix setZoomLevel:[NSNumber numberWithInt:toZoom]];
        
    }else if(![toTileMatrix.matrixHeight isEqualToNumber:[NSNumber numberWithInt:matrixHeight]]
        || ![toTileMatrix.matrixWidth isEqualToNumber:[NSNumber numberWithInt:matrixWidth]]
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
        [toTileMatrix setMatrixHeight:[NSNumber numberWithInt:matrixHeight]];
        [toTileMatrix setMatrixWidth:[NSNumber numberWithInt:matrixWidth]];
        [toTileMatrix setTileHeight:tileHeight];
        [toTileMatrix setTileWidth:tileWidth];
        [toTileMatrix setPixelXSizeValue:pixelXSize];
        [toTileMatrix setPixelYSizeValue:pixelYSize];
        [[_reprojectTileDao tileMatrixDao] createOrUpdate:toTileMatrix];
    }
    
    GPKGBoundingBox *zoomBounds = [_tileDao boundingBoxWithZoomLevel:fromZoom inProjection:_reprojectTileDao.projection];
    GPKGTileGrid *tileGrid = [GPKGTileBoundingBoxUtils tileGridWithTotalBoundingBox:bbox andMatrixWidth:matrixWidth andMatrixHeight:matrixHeight andBoundingBox:zoomBounds];
    
    GPKGTileCreator *tileCreator = [[GPKGTileCreator alloc] initWithTileDao:_tileDao andWidth:tileWidth andHeight:tileHeight andProjection:_reprojectTileDao.projection];
    
    for(int tileRow = tileGrid.minY; tileRow <= tileGrid.maxY; tileRow++){
        
        double tileMaxLatitude = maxLatitude - ((tileRow / (double) matrixHeight) * latitudeRange);
        double tileMinLatitude = maxLatitude - (((tileRow + 1) / (double) matrixHeight) * latitudeRange);
        
        for(int tileColumn = tileGrid.minX; tileColumn <= tileGrid.maxX; tileColumn++){
            
            double tileMinLongitude = minLongitude + ((tileColumn / (double) matrixWidth) * longitudeRange);
            double tileMaxLongitude = minLongitude + (((tileColumn + 1) / (double) matrixWidth) * longitudeRange);
            
            GPKGBoundingBox *tileBounds = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:tileMinLongitude andMinLatitudeDouble:tileMinLatitude andMaxLongitudeDouble:tileMaxLongitude andMaxLatitudeDouble:tileMaxLatitude];
            
            GPKGGeoPackageTile *tile = [tileCreator tileWithBoundingBox:tileBounds andZoom:fromZoom];
            
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

@end
