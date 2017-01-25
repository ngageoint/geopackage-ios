//
//  GPKGTileDaoUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileDaoUtils.h"
#import "GPKGTileMatrixSet.h"
#import "GPKGTileMatrix.h"

@implementation GPKGTileDaoUtils

+(void) adjustTileMatrixLengthsWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray *) tileMatrices{
    double tileMatrixWidth = [tileMatrixSet.maxX doubleValue] - [tileMatrixSet.minX doubleValue];
    double tileMatrixHeight = [tileMatrixSet.maxY doubleValue] - [tileMatrixSet.minY doubleValue];
    for(GPKGTileMatrix * tileMatrix in tileMatrices){
        int tempMatrixWidth = (int) (tileMatrixWidth / ([tileMatrix.pixelXSize doubleValue] * [tileMatrix.tileWidth intValue]));
        int tempMatrixHeight = (int) (tileMatrixHeight / ([tileMatrix.pixelYSize doubleValue] * [tileMatrix.tileHeight intValue]));
        if(tempMatrixWidth > [tileMatrix.matrixWidth intValue]){
            tileMatrix.matrixWidth = [NSNumber numberWithInt:tempMatrixWidth];
        }
        if(tempMatrixHeight > [tileMatrix.matrixHeight intValue]){
            tileMatrix.matrixHeight = [NSNumber numberWithInt:tempMatrixHeight];
        }
    }
}

+(NSNumber *) zoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andLength: (double) length{
    return [self zoomLevelWithWidths:widths andHeights:heights andTileMatrices:tileMatrices andLength:length andLengthChecks:true];
}

+(NSNumber *) zoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andWidth: (double) width andHeight: (double) height{
    return [self zoomLevelWithWidths:widths andHeights:heights andTileMatrices:tileMatrices andWidth:width andHeight:height andLengthChecks:true];
}

+(NSNumber *) closestZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andLength: (double) length{
    return [self zoomLevelWithWidths:widths andHeights:heights andTileMatrices:tileMatrices andLength:length andLengthChecks:false];
}

+(NSNumber *) closestZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andWidth: (double) width andHeight: (double) height{
    return [self zoomLevelWithWidths:widths andHeights:heights andTileMatrices:tileMatrices andWidth:width andHeight:height andLengthChecks:false];
}

+(NSNumber *) zoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andLength: (double) length andLengthChecks: (BOOL) lengthChecks{
    return [self zoomLevelWithWidths:widths andHeights:heights andTileMatrices:tileMatrices andWidth:length andHeight:length andLengthChecks:lengthChecks];
}

+(NSNumber *) zoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andWidth: (double) width andHeight: (double) height andLengthChecks: (BOOL) lengthChecks{
    
    NSNumber * zoomLevel = nil;
    
    // Find where the width and height fit in
    NSDecimalNumber * widthNumber = [[NSDecimalNumber alloc] initWithDouble:width];
    int widthIndex = (int)[widths indexOfObject:widthNumber
                                        inSortedRange:NSMakeRange(0, [widths count])
                                              options:NSBinarySearchingInsertionIndex
                                      usingComparator:^(id obj1, id obj2)
                            {
                                return [obj1 compare:obj2];
                            }];
    NSDecimalNumber * heightNumber = [[NSDecimalNumber alloc] initWithDouble:height];
    int heightIndex = (int)[heights indexOfObject:heightNumber
                                    inSortedRange:NSMakeRange(0, [heights count])
                                          options:NSBinarySearchingInsertionIndex
                                  usingComparator:^(id obj1, id obj2)
                             {
                                 return [obj1 compare:obj2];
                             }];
    
    // Find the closest width or verify it isn't too small or large
    if (widthIndex == 0) {
        if (lengthChecks && width < [self minLength:widths]) {
            widthIndex = -1;
        }
    } else if (widthIndex == [widths count]) {
        if (lengthChecks && width >= [self maxLength:widths]) {
            widthIndex = -1;
        } else {
            widthIndex = widthIndex - 1;
        }
    } else if (width - [(NSDecimalNumber *)[widths objectAtIndex:widthIndex-1] doubleValue] <
               [(NSDecimalNumber *)[widths objectAtIndex:widthIndex] doubleValue] - width) {
        widthIndex--;
    }
    
    // Find the closest height or verify it isn't too small or large
    if (heightIndex == 0) {
        if (lengthChecks && height < [self minLength:heights]) {
            heightIndex = -1;
        }
    } else if (heightIndex == [heights count]) {
        if (lengthChecks && height >= [self maxLength:heights]) {
            heightIndex = -1;
        } else {
            heightIndex = heightIndex - 1;
        }
    } else if (height - [(NSDecimalNumber *)[heights objectAtIndex:heightIndex-1] doubleValue] <
               [(NSDecimalNumber *)[heights objectAtIndex:heightIndex] doubleValue] - height) {
        heightIndex--;
    }
    
    if(widthIndex >= 0 || heightIndex >= 0){
        
        // Use one zoom size smaller if possible
        int index;
        if (widthIndex < 0) {
            index = heightIndex;
        } else if (heightIndex < 0) {
            index = widthIndex;
        } else {
            index = widthIndex < heightIndex ? widthIndex : heightIndex;
        }
        
        GPKGTileMatrix * tileMatrix = [tileMatrices objectAtIndex:[tileMatrices count]
                                       - index - 1];
        zoomLevel = tileMatrix.zoomLevel;
    }
    
    return zoomLevel;
}

+(double) maxLengthWithWidths: (NSArray *) widths andHeights: (NSArray *) heights{
    double maxWidth = [self maxLength:widths];
    double maxHeight = [self maxLength:heights];
    double maxLength = MIN(maxWidth, maxHeight);
    return maxLength;
}

+(double) minLengthWithWidths: (NSArray *) widths andHeights: (NSArray *) heights{
    double minWidth = [self minLength:widths];
    double minHeight = [self minLength:heights];
    double minLength = MAX(minWidth, minHeight);
    return minLength;
}

/**
 *  Get the max length distance value from the sorted array of lengths
 *
 *  @param lengths sorted tile matrix lengths
 *
 *  @return max length
 */
+(double) maxLength: (NSArray *) lengths{
    return [(NSDecimalNumber *)lengths[lengths.count - 1] doubleValue] / .51;
}

/**
 *  Get the min length distance value from the sorted array of lengths
 *
 *  @param lengths sorted tile matrix lengths
 *
 *  @return min length
 */
+(double) minLength: (NSArray *) lengths{
    return [(NSDecimalNumber *)lengths[0] doubleValue] * .51;
}

@end
