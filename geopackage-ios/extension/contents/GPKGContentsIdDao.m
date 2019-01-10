//
//  GPKGContentsIdDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGContentsIdDao.h"

@implementation GPKGContentsIdDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_CI_TABLE_NAME;
        self.idColumns = @[GPKG_CI_COLUMN_PK];
        self.columns = @[GPKG_CI_COLUMN_ID, GPKG_CI_COLUMN_TABLE_NAME];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGContentsId alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGContentsId *setObject = (GPKGContentsId*) object;
    
    switch(columnIndex){
        case 0:
            setObject.id = (NSNumber *) value;
            break;
        case 1:
            setObject.tableName = (NSString *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGContentsId *getObject = (GPKGContentsId*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.id;
            break;
        case 1:
            value = getObject.tableName;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGContentsId *) queryForTableName: (NSString *) tableName{
    GPKGResultSet * results = [self queryForEqWithField:GPKG_CI_COLUMN_TABLE_NAME andValue:tableName];
    GPKGContentsId *contentsId = (GPKGContentsId *)[self getFirstObject:results];
    return contentsId;
}

-(int) deleteByTableName: (NSString *) tableName{
    NSString * where = [self buildWhereWithField:GPKG_CI_COLUMN_TABLE_NAME andValue:tableName];
    NSArray * whereArgs = [self buildWhereArgsWithValue:tableName];
    return [self deleteWhere:where andWhereArgs:whereArgs];
}

@end
