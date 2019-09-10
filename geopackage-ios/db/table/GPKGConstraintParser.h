//
//  GPKGConstraintParser.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConstraintTypes.h"
#import "GPKGTableConstraints.h"

@interface GPKGConstraintParser : NSObject

// TODO

/**
 * Get the constraints for the table SQL
 *
 * @param tableSql
 *            table SQL
 * @return constraints
 */
+(GPKGTableConstraints *) constraintsForSQL: (NSString *) tableSql;

/**
 * Get the constraint type of the constraint SQL
 *
 * @param constraintSql
 *            constraint SQL
 * @return constraint type or null
 */
+(enum GPKGConstraintType) typeForSQL: (NSString *) constraintSql;

/**
 * Get the constraint name if it has one
 *
 * @param constraintSql
 *            constraint SQL
 * @return constraint name or null
 */
+(NSString *) nameForSQL: (NSString *) constraintSql;

@end
