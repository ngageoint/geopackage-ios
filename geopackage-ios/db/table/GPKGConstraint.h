//
//  GPKGConstraint.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/16/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGConstraintTypes.h"

/**
 * Constraint keyword
 */
extern NSString * const GPKG_CONSTRAINT;

/**
 * Table or column constraint
 */
@interface GPKGConstraint : NSObject <NSMutableCopying>

/**
 *  Optional constraint name
 */
@property (nonatomic, strong) NSString *name;

/**
 *  Constraint type
 */
@property (nonatomic) enum GPKGConstraintType type;

/**
 * Optional order
 */
@property (nonatomic, strong) NSNumber *order;

/**
 * Initialize
 *
 * @param type
 *            constraint type
 */
-(instancetype) initWithType: (enum GPKGConstraintType) type;

/**
 * Initialize
 *
 * @param type
 *            constraint type
 * @param name
 *            constraint name
 */
-(instancetype) initWithType: (enum GPKGConstraintType) type andName: (NSString *) name;

/**
 * Initialize
 *
 * @param type
 *            constraint type
 * @param order
 *            constraint order
 */
-(instancetype) initWithType: (enum GPKGConstraintType) type andOrder: (NSNumber *) order;

/**
 * Initialize
 *
 * @param type
 *            constraint type
 * @param name
 *            constraint name
 * @param order
 *            constraint order
 */
-(instancetype) initWithType: (enum GPKGConstraintType) type andName: (NSString *) name andOrder: (NSNumber *) order;

/**
 * Build the name SQL
 *
 * @return name SQL
 */
-(NSString *) buildNameSql;

/**
 * Build the constraint SQL
 *
 * @return sql constraint
 */
-(NSString *) buildSql;

/**
 * Get the order for maintaining sorted constraints
 *
 * @return sort order
 */
-(int) sortOrder;

@end
