//
//  GPKGCoverageDataValues.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/6/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataValues.h"

@implementation GPKGCoverageDataValues

-(int) width{
    return (int)((NSArray *)[self.coverageData objectAtIndex:0]).count;
}

-(int) height{
    return (int)self.coverageData.count;
}

-(int) count{
    return (int)self.coverageDataFlat.count;
}

-(unsigned short) tilePixelAsUnsignedShortWithY: (int) y andX: (int) x{
    return [((NSNumber *) [((NSArray *)[self.tilePixels objectAtIndex:y]) objectAtIndex:x]) unsignedShortValue];
}

-(unsigned short) tilePixelFlatAsUnsignedShortWithWidth: (int) width andY: (int) y andX: (int) x{
    return [((NSNumber *) [self.tilePixelsFlat objectAtIndex:(y * width) + x]) unsignedShortValue];
}

-(unsigned short) tilePixelFlatAsUnsignedShortWithIndex: (int) index{
    return [((NSNumber *) [self.tilePixelsFlat objectAtIndex:index]) unsignedShortValue];
}

-(float) tilePixelAsFloatWithY: (int) y andX: (int) x{
    return [((NSDecimalNumber *) [((NSArray *)[self.tilePixels objectAtIndex:y]) objectAtIndex:x]) floatValue];
}

-(float) tilePixelFlatAsFloatWithWidth: (int) width andY: (int) y andX: (int) x{
    return [((NSDecimalNumber *) [self.tilePixelsFlat objectAtIndex:(y * width) + x]) floatValue];
}

-(float) tilePixelFlatAsFloatWithIndex: (int) index{
    return [((NSDecimalNumber *) [self.tilePixelsFlat objectAtIndex:index]) floatValue];
}

-(NSDecimalNumber *) valueWithY: (int) y andX: (int) x{
    return ((NSDecimalNumber *) [((NSArray *)[self.coverageData objectAtIndex:y]) objectAtIndex:x]);
}

-(NSDecimalNumber *) valueFlatWithWidth: (int) width andY: (int) y andX: (int) x{
    return ((NSDecimalNumber *) [self.coverageDataFlat objectAtIndex:(y * width) + x]);
}

@end
