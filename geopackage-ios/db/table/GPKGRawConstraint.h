//
//  GPKGRawConstraint.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGConstraint.h"

/**
 * Table raw or unparsed constraint
 */
@interface GPKGRawConstraint : GPKGConstraint

/**
 *  SQL statement
 */
@property (nonatomic, strong) NSString *sql;

/**
 * Initialize
 *
 * @param sql
 *            constraint SQL
 */
-(instancetype) initWithSql: (NSString *) sql;

/**
 * Initialize
 *
 * @param type
 *            constraint type
 * @param sql
 *            constraint SQL
 */
-(instancetype) initWithType: (enum GPKGConstraintType) type andSql: (NSString *) sql;

/**
 * Initialize
 *
 * @param type
 *            constraint type
 * @param name
 *            constraint name
 * @param sql
 *            constraint SQL
 */
-(instancetype) initWithType: (enum GPKGConstraintType) type andName: (NSString *) name andSql: (NSString *) sql;

/**
 * Constructor
 *
 * @param order
 *            constraint order
 * @param sql
 *            constraint SQL
 */
-(instancetype) initWithOrder: (NSNumber *) order andSql: (NSString *) sql;

/**
 * Constructor
 *
 * @param type
 *            constraint type
 * @param order
 *            constraint order
 * @param sql
 *            constraint SQL
 */
-(instancetype) initWithType: (enum GPKGConstraintType) type andOrder: (NSNumber *) order andSql: (NSString *) sql;

/**
 * Constructor
 *
 * @param type
 *            constraint type
 * @param name
 *            constraint name
 * @param order
 *            constraint order
 * @param sql
 *            constraint SQL
 */
-(instancetype) initWithType: (enum GPKGConstraintType) type andName: (NSString *) name andOrder: (NSNumber *) order andSql: (NSString *) sql;

/**
 * Set the type from the constraint SQL
 *
 * @param sql
 *            constraint SQL
 */
-(void) setTypeFromSql: (NSString *) sql;

/**
 * Set the name from the constraint SQL
 *
 * @param sql
 *            constraint SQL
 */
-(void) setNameFromSql: (NSString *) sql;

@end
