//
//  GPKGDgiwgFile.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGDgiwgFileName.h"

/**
 * DGIWG (Defence Geospatial Information Working Group) GeoPackage File
 */
@interface GPKGDgiwgFile : NSObject

/**
 *  GeoPackage File
 */
@property (nonatomic, strong) NSString *file;

/**
 *  DGIWG File Name
 */
@property (nonatomic, strong) GPKGDgiwgFileName *fileName;

/**
 *  Initialize
 *
 *  @param file GeoPackage file name or path
 *
 *  @return new file
 */
-(instancetype) initWithFile: (NSString *) file;

/**
 *  Initialize
 *
 *  @param file GeoPackage file name or path
 *  @param fileName DGIWG file name
 *
 *  @return new file
 */
-(instancetype) initWithFile: (NSString *) file andFileName: (GPKGDgiwgFileName *) fileName;

/**
 *  Initialize
 *
 *  @param file GeoPackage file name or path
 *  @param fileName file name
 *
 *  @return new file
 */
-(instancetype) initWithFile: (NSString *) file andName: (NSString *) fileName;

/**
 * Get the file name
 *
 * @return file name
 */
-(NSString *) name;

/**
 * Set the DGIWG file name
 *
 * @param file
 *            GeoPackage file
 */
-(void) setFileNameFromFile: (NSString *) file;

@end
