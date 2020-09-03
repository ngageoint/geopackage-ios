//
//  GPKGConstraintTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Enumeration of constraint types
 */
enum GPKGConstraintType{
    GPKG_CT_PRIMARY_KEY,
    GPKG_CT_UNIQUE,
    GPKG_CT_CHECK,
    GPKG_CT_FOREIGN_KEY,
    GPKG_CT_NOT_NULL,
    GPKG_CT_DEFAULT,
    GPKG_CT_COLLATE,
    GPKG_CT_AUTOINCREMENT
};

/**
 *  Constraint type names
 */
extern NSString * const GPKG_CT_PRIMARY_KEY_NAME;
extern NSString * const GPKG_CT_UNIQUE_NAME;
extern NSString * const GPKG_CT_CHECK_NAME;
extern NSString * const GPKG_CT_FOREIGN_KEY_NAME;
extern NSString * const GPKG_CT_NOT_NULL_NAME;
extern NSString * const GPKG_CT_DEFAULT_NAME;
extern NSString * const GPKG_CT_COLLATE_NAME;
extern NSString * const GPKG_CT_AUTOINCREMENT_NAME;

@interface GPKGConstraintTypes : NSObject

/**
 *  Get the name of the constraint type
 *
 *  @param type constraint type
 *
 *  @return constrainttype name
 */
+(NSString *) name: (enum GPKGConstraintType) type;

/**
 *  Get the constraint type from the constraint type name
 *
 *  @param name constraint type name
 *
 *  @return constraint type
 */
+(enum GPKGConstraintType) fromName: (NSString *) name;

/**
 * Get a matching table constraint type from the value
 *
 * @param value
 *            table constraint name value
 * @return constraint type or null
 */
+(enum GPKGConstraintType) tableTypeOfValue: (NSString *) value;

/**
 * Get a matching column constraint type from the value
 *
 * @param value
 *            column constraint name value
 * @return constraint type or null
 */
+(enum GPKGConstraintType) columnTypeOfValue: (NSString *) value;

/**
 * Get a matching constraint type from the value
 *
 * @param value
 *            constraint name value
 * @return constraint type or null
 */
+(enum GPKGConstraintType) typeOfValue: (NSString *) value;

@end
