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
 *  User Custom Table
 */
@property (nonatomic, strong) GPKGUserCustomTable *userCustomTable;

/**
 *  Initialize
 *
 *  @param table       user custom table
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return new user custom row
 */
-(instancetype) initWithUserCustomTable: (GPKGUserCustomTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

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

@end
