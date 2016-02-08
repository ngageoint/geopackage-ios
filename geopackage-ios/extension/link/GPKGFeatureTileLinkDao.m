//
//  GPKGFeatureTileLinkDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/3/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureTileLinkDao.h"

@implementation GPKGFeatureTileLinkDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_FTL_TABLE_NAME;
        self.idColumns = @[GPKG_FTL_COLUMN_PK1, GPKG_FTL_COLUMN_PK2];
        self.columns = @[GPKG_FTL_COLUMN_FEATURE_TABLE_NAME, GPKG_FTL_COLUMN_TILE_TABLE_NAME];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGFeatureTileLink alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGFeatureTileLink *setObject = (GPKGFeatureTileLink*) object;
    
    switch(columnIndex){
        case 0:
            setObject.featureTableName = (NSString *) value;
            break;
        case 1:
            setObject.tileTableName = (NSString *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGFeatureTileLink *getObject = (GPKGFeatureTileLink*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.featureTableName;
            break;
        case 1:
            value = getObject.tileTableName;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGFeatureTileLink *) queryForFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable{
    NSArray * id = [[NSArray alloc] initWithObjects:featureTable, tileTable, nil];
    GPKGFeatureTileLink * link = (GPKGFeatureTileLink *)[self queryForMultiIdObject:id];
    return link;
}

-(GPKGResultSet *) queryForFeatureTableName: (NSString *) featureTable{
    return [self queryForEqWithField:GPKG_FTL_COLUMN_FEATURE_TABLE_NAME andValue:featureTable];
}

-(GPKGResultSet *) queryForTileTableName: (NSString *) tileTable{
    return [self queryForEqWithField:GPKG_FTL_COLUMN_TILE_TABLE_NAME andValue:tileTable];
}

-(int) deleteByFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable{
    NSArray * id = [[NSArray alloc] initWithObjects:featureTable, tileTable, nil];
    int count = [self deleteByMultiId:id];
    return count;
}

-(int) deleteByTableName: (NSString *) tableName{
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_FTL_COLUMN_FEATURE_TABLE_NAME withValue:tableName];
    [values addColumn:GPKG_FTL_COLUMN_TILE_TABLE_NAME withValue:tableName];
    
    NSString * where = [self buildWhereWithFields:values andOperation:@"or"];
    NSArray * whereArgs = [self buildWhereArgsWithValues:values];
    int count = [self deleteWhere:where andWhereArgs:whereArgs];
    return count;
}

@end
