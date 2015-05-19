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
        self.tableName = DC_TABLE_NAME;
        self.idColumns = @[DC_COLUMN_PK1, DC_COLUMN_PK2];
        self.columns = @[DC_COLUMN_TABLE_NAME, DC_COLUMN_COLUMN_NAME, DC_COLUMN_NAME, DC_COLUMN_TITLE, DC_COLUMN_DESCRIPTION, DC_COLUMN_MIME_TYPE, DC_COLUMN_CONSTRAINT_NAME];
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

-(GPKGContents *) getContents: (GPKGDataColumns *) dataColumns{
    GPKGContentsDao * dao = [self getContentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForId:dataColumns.tableName];
    return contents;
}

-(GPKGResultSet *) queryByConstraintName: (NSString *) constraintName{
    GPKGResultSet * results = [self queryForEqWithField:DC_COLUMN_CONSTRAINT_NAME andValue:constraintName];
    return results;
}

-(GPKGContentsDao *) getContentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

@end
