//
//  GPKGConstraint.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/16/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConstraintTypes.h"

/**
 * Constraint keyword
 */
extern NSString * const GPKG_CONSTRAINT;

/**
 * User table constraint
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

@end
