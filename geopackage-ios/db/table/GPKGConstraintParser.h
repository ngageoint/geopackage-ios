//
//  GPKGConstraintParser.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGTableConstraints.h"
/**
 * SQL constraint parser from create table statements
 */
@interface GPKGConstraintParser : NSObject

/**
 * Get the constraints for the table SQL
 *
 * @param tableSql
 *            table SQL
 * @return constraints
 */
+(GPKGTableConstraints *) tableConstraintsForSQL: (NSString *) tableSql;

/**
 * Attempt to get column constraints by parsing the SQL statement
 *
 * @param constraintSql
 *            constraint SQL statement
 * @return constraints
 */
+(GPKGColumnConstraints *) columnConstraintsForSQL: (NSString *) constraintSql;

/**
 * Attempt to get a table constraint by parsing the SQL statement
 *
 * @param constraintSql
 *            constraint SQL statement
 * @return constraint or null
 */
+(GPKGConstraint *) tableConstraintForSQL: (NSString *) constraintSql;

/**
 * Check if the SQL is a table type constraint
 *
 * @param constraintSql
 *            constraint SQL statement
 * @return true if a table constraint
 */
+(BOOL) isTableConstraint: (NSString *) constraintSql;

/**
 * Get the table constraint type of the constraint SQL
 *
 * @param constraintSql
 *            constraint SQL
 * @return constraint type or null
 */
+(enum GPKGConstraintType) tableTypeForSQL: (NSString *) constraintSql;

/**
 * Determine if the table constraint SQL is the constraint type
 *
 * @param constraintSql
 *            constraint SQL
 * @param type
 *            constraint type
 * @return true if the constraint type
 */
+(BOOL) isTableSQL: (NSString *) constraintSql type: (enum GPKGConstraintType) type;

/**
 * Attempt to get a column constraint by parsing the SQL statement
 *
 * @param constraintSql
 *            constraint SQL statement
 * @return constraint or null
 */
+(GPKGConstraint *) columnConstraintForSQL: (NSString *) constraintSql;

/**
 * Check if the SQL is a column type constraint
 *
 * @param constraintSql
 *            constraint SQL statement
 * @return true if a column constraint
 */
+(BOOL) isColumnConstraint: (NSString *) constraintSql;

/**
 * Get the column constraint type of the constraint SQL
 *
 * @param constraintSql
 *            constraint SQL
 * @return constraint type or null
 */
+(enum GPKGConstraintType) columnTypeForSQL: (NSString *) constraintSql;

/**
 * Determine if the column constraint SQL is the constraint type
 *
 * @param constraintSql
 *            constraint SQL
 * @param type
 *            constraint type
 * @return true if the constraint type
 */
+(BOOL) isColumnSQL: (NSString *) constraintSql type: (enum GPKGConstraintType) type;

/**
 * Attempt to get a constraint by parsing the SQL statement
 *
 * @param constraintSql
 *            constraint SQL statement
 * @return constraint or null
 */
+(GPKGConstraint *) constraintForSQL: (NSString *) constraintSql;

/**
 * Check if the SQL is a constraint
 *
 * @param constraintSql
 *            constraint SQL statement
 * @return true if a constraint
 */
+(BOOL) isConstraint: (NSString *) constraintSql;

/**
 * Get the constraint type of the constraint SQL
 *
 * @param constraintSql
 *            constraint SQL
 * @return constraint type or null
 */
+(enum GPKGConstraintType) typeForSQL: (NSString *) constraintSql;

/**
 * Determine if the constraint SQL is the constraint type
 *
 * @param type
 *            constraint type
 * @param constraintSql
 *            constraint SQL
 * @return true if the constraint type
 */
+(BOOL) isSQL: (NSString *) constraintSql type: (enum GPKGConstraintType) type;

/**
 * Get the constraint name if it has one
 *
 * @param constraintSql
 *            constraint SQL
 * @return constraint name or null
 */
+(NSString *) nameForSQL: (NSString *) constraintSql;

/**
 * Get the constraint name and remaining definition
 *
 * @param constraintSql
 *            constraint SQL
 * @return array with name or null at index 0, definition at index 1
 */
+(NSArray<NSString *> *) nameAndDefinitionForSQL: (NSString *) constraintSql;

@end
