//
//  GPKGUserCustomRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserRow.h"
#import "GPKGUserCustomTable.h"

/**
 * User Custom Row containing the values from a single cursor row
 */
@interface GPKGUserCustomRow : GPKGUserRow

/**
 *  Initialize
 *
 *  @param table       user custom table
 *  @param columns   columns
 *  @param values      values
 *
 *  @return new user custom row
 */
-(instancetype) initWithUserCustomTable: (GPKGUserCustomTable *) table andColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table user custom table
 *
 *  @return new user custom row
 */
-(instancetype) initWithUserCustomTable: (GPKGUserCustomTable *) table;

/**
 * Copy Initialize
 *
 * @param userCustomRow
 *            user custom row to copy
 *
 *  @return new user custom row
 */
-(instancetype) initWithUserCustomRow: (GPKGUserCustomRow *) userCustomRow;

/**
 *  Get the user custom table
 *
 *  @return user custom table
 */
-(GPKGUserCustomTable *) table;

@end
