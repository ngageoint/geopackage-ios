//
//  GPKGConnectionFunction.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/7/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  GeoPackage connection function wrapper
 */
@interface GPKGConnectionFunction : NSObject

/**
 *  Initialize
 *
 *  @param function connection function
 *  @param name function name
 *  @param numArgs number of function arguments
 *
 *  @return new connection function
 */
-(instancetype)initWithFunction: (void *) function withName: (NSString *) name andNumArgs: (int) numArgs;

/**
 *  Initialize
 *
 *  @param function connection function
 *  @param name function name
 *  @param numArgs number of function arguments
 *  @param userData user data
 *
 *  @return new connection function
 */
-(instancetype)initWithFunction: (void *) function withName: (NSString *) name andNumArgs: (int) numArgs andUserData: (NSObject *) userData;

/**
 *  Get the function
 *
 *  @return function
 */
-(void *) function;

/**
 *  Get the function name
 *
 *  @return function name
 */
-(NSString *) name;

/**
 *  Get the number of function arguments
 *
 *  @return function arguments count
 */
-(int) numArgs;

/**
 *  Get the user data
 *
 *  @return user data
 */
-(NSObject *) userData;

@end
