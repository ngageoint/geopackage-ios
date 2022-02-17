//
//  GPKGUserCustomDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomDao.h"
#import "GPKGUserCustomTableReader.h"

@implementation GPKGUserCustomDao

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGUserCustomTable *) table{
    self = [super initWithDatabase:database andTable:table];
    return self;
}

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao{
    return [self initWithDatabase:dao.database andTable:[dao userCustomTable]];
}

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao andTable: (GPKGUserCustomTable *) table{
    return [self initWithDatabase:dao.database andTable:table];
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGUserCustomTable *) userCustomTable{
    return (GPKGUserCustomTable *) super.table;
}

-(GPKGUserCustomRow *) row: (GPKGResultSet *) results{
    return (GPKGUserCustomRow *) [super row:results];
}

-(GPKGUserCustomRow *) rowWithRow: (GPKGRow *) row{
    return (GPKGUserCustomRow *) [super rowWithRow:row];
}

-(GPKGUserRow *) newRowWithColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    return [[GPKGUserRow alloc] initWithTable:[self table] andColumns:columns andValues:values];
}

-(GPKGUserCustomRow *) newRow{
    return [[GPKGUserCustomRow alloc] initWithUserCustomTable:[self userCustomTable]];
}

-(int) countOfResultSet: (GPKGResultSet *) resultSet{
    int count = 0;
    @try {
        count = resultSet.count;
    } @finally {
        [resultSet close];
    }
    return count;
}

+(GPKGUserCustomDao *) readTableWithDatabase: (NSString *) database andConnection: (GPKGConnection *) connection andTable: (NSString *) tableName{
    GPKGUserCustomTable *userCustom = [GPKGUserCustomTableReader readTableWithConnection:connection andTableName:tableName];
    GPKGUserCustomDao *dao = [[GPKGUserCustomDao alloc] initWithDatabase:connection andTable:userCustom];
    return dao;
}

-(GPKGBoundingBox *) boundingBox{
    [NSException raise:@"Not Supported" format:@"Bounding Box not supported for User Custom"];
    return nil;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (PROJProjection *) projection{
    [NSException raise:@"Not Supported" format:@"Bounding Box not supported for User Custom"];
    return nil;
}

@end
