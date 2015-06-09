//
//  GPKGTileDaoUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTileMatrixSet.h"

@interface GPKGTileDaoUtils : NSObject

+(void) adjustTileMatrixLengthsWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray *) tileMatrices;

+(NSNumber *) getZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andLength: (double) length;

@end
