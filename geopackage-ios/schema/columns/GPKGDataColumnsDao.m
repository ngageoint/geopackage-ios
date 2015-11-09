//
//  GPKGDataColumnsDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGDataColumnsDao.h"
#import "GPKGContentsDao.h"
#import "GPKGDataColumnConstraintsDao.h"

@implementation GPKGDataColumnsDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_DC_TABLE_NAME;
        self.idColumns = @[GPKG_DC_COLUMN_PK1, GPKG_DC_COLUMN_PK2];
        self.columns = @[GPKG_DC_COLUMN_TABLE_NAME, GPKG_DC_COLUMN_COLUMN_NAME, GPKG_DC_COLUMN_NAME, GPKG_DC_COLUMN_TITLE, GPKG_DC_COLUMN_DESCRIPTION, GPKG_DC_COLUMN_MIME_TYPE, GPKG_DC_COLUMN_CONSTRAINT_NAME];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGDataColumns alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGDataColumns *setObject = (GPKGDataColumns*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.columnName = (NSString *) value;
            break;
        case 2:
            setObject.name = (NSString *) value;
            break;
        case 3:
            setObject.title = (NSString *) value;
            break;
        case 4:
            setObject.theDescription = (NSString *) value;
            break;
        case 5:
            setObject.mimeType = (NSString *) value;
            break;
        case 6:
            setObject.constraintName = (NSString *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGDataColumns *getObject = (GPKGDataColumns*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.tableName;
            break;
        case 1:
            value = getObject.columnName;
            break;
        case 2:
            value = getObject.name;
            break;
        case 3:
            value = getObject.title;
            break;
        case 4:
            value = getObject.theDescription;
            break;
        case 5:
            value = getObject.mimeType;
            break;
        case 6:
            value = getObject.constraintName;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGProjection *) getProjection: (NSObject *) object{
    GPKGDataColumns *projectionObject = (GPKGDataColumns*) object;
    GPKGContents *contents = [self getContents:projectionObject];
    GPKGContentsDao *contentsDao = [self getContentsDao];
    GPKGProjection * projection = [contentsDao getProjection:contents];
    return projection;
}

-(GPKGContents *) getContents: (GPKGDataColumns *) dataColumns{
    GPKGContentsDao * dao = [self getContentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForIdObject:dataColumns.tableName];
    return contents;
}

-(GPKGResultSet *) queryByConstraintName: (NSString *) constraintName{
    GPKGResultSet * results = [self queryForEqWithField:GPKG_DC_COLUMN_CONSTRAINT_NAME andValue:constraintName];
    return results;
}

-(GPKGContentsDao *) getContentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

-(GPKGDataColumns *) getDataColumnByTableName: tableName andColumnName: columnName {
    if (![self tableExists]) return nil;
    NSString * whereClause = [NSString stringWithFormat:@"%@ and %@",
                              [self buildWhereWithField:GPKG_DC_COLUMN_TABLE_NAME andValue:tableName],
                              [self buildWhereWithField:GPKG_DC_COLUMN_COLUMN_NAME andValue:columnName]];
    NSArray * values = [NSArray arrayWithObjects:tableName, columnName, nil];
                        
    return (GPKGDataColumns *)[self getFirstObject:[self queryWhere: whereClause andWhereArgs: values]];
}

@end
