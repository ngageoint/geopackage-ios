//
//  GPKGDataColumnConstraintsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGDataColumnConstraints.h"

@interface GPKGDataColumnConstraintsDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(int) deleteCascade: (GPKGDataColumnConstraints *) constraints;

-(int) deleteCascadeWithCollection: (NSArray *) constraintsCollection;

-(int) deleteCascadeWhere: (NSString *) where;

-(int) deleteByIdCascade: (NSNumber *) id;

-(int) deleteIdsCascade: (NSArray *) idCollection;

-(GPKGResultSet *) queryByConstraintName: (NSString *) constraintName;

-(GPKGDataColumnConstraints *) queryByUniqueConstraintName: (NSString *) constraintName
                                      andConstraintType: (enum GPKGDataColumnConstraintType) constraintType
                                      andValue: (NSString *) value;

@end
