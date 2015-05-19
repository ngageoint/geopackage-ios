//
//  GPKGDataColumnsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGDataColumns.h"
#import "GPKGContents.h"

@interface GPKGDataColumnsDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(GPKGContents *) getContents: (GPKGDataColumns *) dataColumns;

-(GPKGResultSet *) queryByConstraintName: (NSString *) constraintName;

@end
