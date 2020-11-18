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

@interface GPKGTileReprojection ()

@property (nonatomic, strong) GPKGTileDao *tileDao;

@property (nonatomic, strong) GPKGGeoPackage *geoPackage;

@property (nonatomic, strong) NSString *table;

@property (nonatomic, strong) SFPProjection *projection;

@property (nonatomic, strong) GPKGTileDao *reprojectTileDao;

@property (nonatomic) BOOL replace;

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
        _replace = NO;
        _tileDao = tileDao;
        _geoPackage = geoPackage;
        _table = table;
        _projection = projection;
    }
    return self;
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao toTileDao: (GPKGTileDao *) reprojectTileDao{
    self = [super init];
    if(self != nil){
        _optimize = YES;
        _replace = NO;
        _tileDao = tileDao;
        _reprojectTileDao = reprojectTileDao;
    }
    return self;
}

-(void) initialize{
    if(_reprojectTileDao == nil){
        GPKGBoundingBox *boundingBox = [_tileDao boundingBoxInProjection:_projection];
        GPKGSpatialReferenceSystem *srs = [[_geoPackage spatialReferenceSystemDao] srsWithOrganization:_projection.authority andCoordsysId:[NSNumber numberWithInt:[_projection.code intValue]]];
        if([_tileDao.databaseName isEqualToString:_geoPackage.name] && [_tileDao.tableName caseInsensitiveCompare:_table] == NSOrderedSame){
            int count = 1;
            NSString *tempTable = [NSString stringWithFormat:@"%@_%d", _table, ++count];
            while([GPKGSQLiteMaster countWithConnection:_tileDao.database andQuery:[GPKGSQLiteMasterQuery createWithColumn:GPKG_SMC_NAME andValue:tempTable]] > 0){
                tempTable = [NSString stringWithFormat:@"%@_%d", _table, ++count];
            }
            _table = tempTable;
            _replace = YES;
        }
        GPKGTileTable *tileTable = [_geoPackage createTileTableWithMetadata:[GPKGTileTableMetadata createWithTable:_table andTileBoundingBox:boundingBox andTileSrsId:srs.srsId]];
        _reprojectTileDao = [_geoPackage tileDaoWithTable:tileTable];
    }
}

-(void) finish{
    if(_replace){
        // TODO delete table and rename reprojected table
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
    // TODO optimize
    
    GPKGBoundingBox *bbox = [_reprojectTileDao boundingBox];
    
    double minLongitude = [bbox.minLongitude doubleValue];
    double maxLatitude = [bbox.maxLatitude doubleValue];
    
    double longitudeRange = [bbox longitudeRangeValue];
    double latitudeRange = [bbox latitudeRangeValue];
    
    double pixelXSize = longitudeRange / matrixWidth / [tileWidth intValue];
    double pixelYSize = latitudeRange / matrixHeight / [tileHeight intValue];
    
    GPKGTileMatrix *toTileMatrix = [_reprojectTileDao tileMatrixWithZoomLevel:zoom];
    if(toTileMatrix == nil){
        toTileMatrix = [[GPKGTileMatrix alloc] init];
        [toTileMatrix setTableName:_reprojectTileDao.tableName];
        [toTileMatrix setMatrixHeight:[NSNumber numberWithInt:matrixHeight]];
        [toTileMatrix setMatrixWidth:[NSNumber numberWithInt:matrixWidth]];
        [toTileMatrix setTileHeight:tileHeight];
        [toTileMatrix setTileWidth:tileWidth];
        [toTileMatrix setPixelXSizeValue:pixelXSize];
        [toTileMatrix setPixelYSizeValue:pixelYSize];
        [toTileMatrix setZoomLevel:[NSNumber numberWithInt:zoom]];
        [[_reprojectTileDao tileMatrixDao] create:toTileMatrix];
    }else{
        // TODO validate the bounds matches
    }
    
    GPKGTileCreator *tileCreator = [[GPKGTileCreator alloc] initWithTileDao:_tileDao andWidth:tileWidth andHeight:tileHeight andProjection:_reprojectTileDao.projection];
    
    for(int tileRow = 0; tileRow < matrixHeight; tileRow++){
        
        double tileMaxLatitude = maxLatitude - ((tileRow / (double) matrixHeight) * latitudeRange);
        double tileMinLatitude = maxLatitude - (((tileRow + 1) / (double) matrixHeight) * latitudeRange);
        
        for(int tileColumn = 0; tileColumn < matrixWidth; tileColumn++){
            
            double tileMinLongitude = minLongitude + ((tileColumn / (double) matrixWidth) * longitudeRange);
            double tileMaxLongitude = minLongitude + (((tileColumn + 1) / (double) matrixWidth) * longitudeRange);
            
            GPKGBoundingBox *tileBounds = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:tileMinLongitude andMinLatitudeDouble:tileMinLatitude andMaxLongitudeDouble:tileMaxLongitude andMaxLatitudeDouble:tileMaxLatitude];
            
            GPKGGeoPackageTile *tile = [tileCreator tileWithBoundingBox:tileBounds];
            
            if(tile != nil){
                
                GPKGTileRow *row = [_reprojectTileDao newRow];
                [row setTileColumn:tileColumn];
                [row setTileRow:tileRow];
                [row setZoomLevel:zoom];
                [row setTileData:tile.data];
                
                [_reprojectTileDao create:row];
                tiles++;
            }
        }
        
    }
    
    return tiles;
}

@end
