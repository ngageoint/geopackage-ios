//
//  GPKGDgiwgValidationErrors.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGDgiwgValidationError.h"

/**
 * DGIWG (Defence Geospatial Information Working Group) validation errors
 */
@interface GPKGDgiwgValidationErrors : NSObject

/**
 * Initialize
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param error
 *            validation error
 */
-(instancetype) initWithError: (GPKGDgiwgValidationError *) error;

/**
 * Initialize
 *
 * @param errors
 *            validation errors
 */
-(instancetype) initWithErrors: (NSArray<GPKGDgiwgValidationError *> *) errors;

/**
 * Initialize
 *
 * @param errors
 *            validation errors
 */
-(instancetype) initWithValidationErrors: (GPKGDgiwgValidationErrors *) errors;

/**
 * Add a validation error
 *
 * @param error
 *            validation error
 */
-(void) addError: (GPKGDgiwgValidationError *) error;

/**
 * Add validation errors
 *
 * @param errors
 *            validation errors
 */
-(void) addErrors: (NSArray<GPKGDgiwgValidationError *> *) errors;

/**
 * Add validation errors
 *
 * @param errors
 *            validation errors
 */
-(void) addValidationErrors: (GPKGDgiwgValidationErrors *) errors;

/**
 * Check if valid
 *
 * @return true if valid
 */
-(BOOL) isValid;

/**
 * Has errors
 *
 * @return true if has errors
 */
-(BOOL) hasErrors;

/**
 * Get the number of errors
 *
 * @return error count
 */
-(int) numErrors;

/**
 * Get the validation errors
 *
 * @return errors
 */
-(NSArray<GPKGDgiwgValidationError *> *) errors;

/**
 * Get the validation error at the index
 *
 * @param index
 *            error index
 * @return error
 */
-(GPKGDgiwgValidationError *) errorAtIndex: (int) index;

@end
