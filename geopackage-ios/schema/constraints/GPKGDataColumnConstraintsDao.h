//
//  GPKGDataColumnConstraintsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGDataColumnConstraints.h"

/**
 *  Data Column Constraints Data Access Object
 */
@interface GPKGDataColumnConstraintsDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new data column constraints dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Delete the Data Columns Constraints, cascading
 *
 *  @param constraints data columns constraints
 *
 *  @return rows deleted
 */
-(int) deleteCascade: (GPKGDataColumnConstraints *) constraints;

/**
 *  Delete the collection of Data Column Constraints, cascading
 *
 *  @param constraintsCollection data columns constraints array
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWithCollection: (NSArray *) constraintsCollection;

/**
 *  Delete the Data Columns Constraints where, cascading
 *
 *  @param where     where clause
 *  @param whereArgs where arge
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Query by the constraint name
 *
 *  @param constraintName constraint name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByConstraintName: (NSString *) constraintName;

/**
 *  Query by the unique column values
 *
 *  @param constraintName constraint name
 *  @param constraintType constraint type
 *  @param value          value
 *
 *  @return data column constraints
 */
-(GPKGDataColumnConstraints *) queryByUniqueConstraintName: (NSString *) constraintName
                                      andConstraintType: (enum GPKGDataColumnConstraintType) constraintType
                                      andValue: (NSString *) value;

@end
