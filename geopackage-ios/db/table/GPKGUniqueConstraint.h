//
//  GPKGUniqueConstraint.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/20/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGConstraint.h"
#import "GPKGUserColumn.h"

/**
 * Unique keyword
 */
extern NSString * const GPKG_UNIQUE;

/**
 * Table unique constraint for one or more columns
 */
@interface GPKGUniqueConstraint : GPKGConstraint

/**
 *  Columns included in the unique constraint
 */
@property (nonatomic, strong) NSMutableArray<GPKGUserColumn *> *columns;

/**
 * Initialize
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param name
 *            constraint name
 */
-(instancetype) initWithName: (NSString *) name;

/**
 * Initialize
 *
 * @param column
 *            column
 */
-(instancetype) initWithColumn: (GPKGUserColumn *) column;

/**
 * Initialize
 *
 * @param columns
 *            columns
 */
-(instancetype) initWithColumns: (NSArray<GPKGUserColumn *> *) columns;

/**
 * Initialize
 *
 * @param name
 *            constraint name
 * @param column
 *            column
 */
-(instancetype) initWithName: (NSString *) name andColumn: (GPKGUserColumn *) column;

/**
 * Initialize
 *
 * @param name
 *            constraint name
 * @param columns
 *            columns
 */
-(instancetype) initWithName: (NSString *) name andColumns: (NSArray<GPKGUserColumn *> *) columns;

/**
 * Add column
 *
 * @param column
 *            column
 */
-(void) addColumn: (GPKGUserColumn *) column;

/**
 * Add columns
 *
 * @param columns
 *            columns
 */
-(void) addColumns: (NSArray<GPKGUserColumn *> *) columns;

@end
