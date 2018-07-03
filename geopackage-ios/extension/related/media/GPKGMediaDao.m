//
//  GPKGMediaDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGMediaDao.h"

@implementation GPKGMediaDao

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao{
    self = [super initWithDao:dao andTable:[[GPKGMediaTable alloc] initWithTable:[dao table]]];
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGMediaTable *) table{
    return (GPKGMediaTable *)[super table];
}

-(GPKGMediaRow *) row: (GPKGResultSet *) results{
    return (GPKGMediaRow *) [self getRow:results];
}

-(GPKGMediaRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    return [[GPKGMediaRow alloc] initWithMediaTable:[self table] andColumnTypes:columnTypes andValues:values];
}

-(GPKGMediaRow *) newRow{
    return [[GPKGMediaRow alloc] initWithMediaTable:[self table]];
}

-(GPKGMediaRow *) rowFromUserCustomRow: (GPKGUserCustomRow *) row{
    return [[GPKGMediaRow alloc] initWithUserCustomRow:row];
}

-(NSArray<GPKGMediaRow *> *) rowsWithIds: (NSArray<NSNumber *> *) ids{
    NSMutableArray<GPKGMediaRow *> *mediaRows = [[NSMutableArray alloc] init];
    for(NSNumber *id in ids){
        GPKGUserCustomRow *userCustomRow = (GPKGUserCustomRow *)[self queryForIdObject:id];
        if(userCustomRow != nil){
            [mediaRows addObject:[self rowFromUserCustomRow:userCustomRow]];
        }
    }
    return mediaRows;
}

@end
