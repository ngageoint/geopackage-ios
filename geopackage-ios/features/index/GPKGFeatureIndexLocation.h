//
//  GPKGFeatureIndexLocation.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/5/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureIndexManager.h"

/**
 * Feature Index Location to iterate over indexed feature index types
 */
@interface GPKGFeatureIndexLocation : NSObject <NSFastEnumeration>

/**
 *  Initialize
 *
 *  @param manager feature index manager
 *
 *  @return new feature index location
 */
-(instancetype) initWithFeatureIndexManager: (GPKGFeatureIndexManager *) manager;

@end
