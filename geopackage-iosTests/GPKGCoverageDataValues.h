//
//  GPKGCoverageDataValues.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/6/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGCoverageDataValues : NSObject

@property (nonatomic, strong) NSMutableArray *tilePixels;
@property (nonatomic, strong) NSMutableArray *coverageData;
@property (nonatomic, strong) NSMutableArray *tilePixelsFlat;
@property (nonatomic, strong) NSMutableArray *coverageDataFlat;

-(int) width;

-(int) height;

-(int) count;

-(unsigned short) tilePixelAsUnsignedShortWithY: (int) y andX: (int) x;

-(unsigned short) tilePixelFlatAsUnsignedShortWithWidth: (int) width andY: (int) y andX: (int) x;

-(unsigned short) tilePixelFlatAsUnsignedShortWithIndex: (int) index;

-(float) tilePixelAsFloatWithY: (int) y andX: (int) x;

-(float) tilePixelFlatAsFloatWithWidth: (int) width andY: (int) y andX: (int) x;

-(float) tilePixelFlatAsFloatWithIndex: (int) index;

-(NSDecimalNumber *) valueWithY: (int) y andX: (int) x;

-(NSDecimalNumber *) valueFlatWithWidth: (int) width andY: (int) y andX: (int) x;

@end
