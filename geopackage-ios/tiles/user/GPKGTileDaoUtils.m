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

/**
 * Determine if the length at the index is closer by a factor of two to the
 * next zoomed in level / lower index
 *
 * @param lengths
 *            sorted lengths
 * @param length
 *            current length
 * @param lengthIndex
 *            length index
 * @return true if closer to zoomed in length
 */
+(BOOL) closerToZoomInWithLengths: (NSArray *) lengths andLength: (double) length andLengthIndex: (int) lengthIndex{
    
    // Zoom level distance to the zoomed in length
    double zoomInDistance = log(length / [[lengths objectAtIndex:lengthIndex - 1] doubleValue]) / log(2.0);
    
    // Zoom level distance to the zoomed out length
    double zoomOutDistance = log(length / [[lengths objectAtIndex:lengthIndex] doubleValue]) / log(0.5);
    
    BOOL zoomIn = zoomInDistance < zoomOutDistance;
    
    return zoomIn;
}

/**
 * Get the tile matrix represented by the current length index
 *
 * @param tileMatrices
 *            tile matrices
 * @param index
 *            index location in sorted lengths
 * @return tile matrix
 */
+(GPKGTileMatrix *) tileMatrixFromTileMatrices: (NSArray *) tileMatrices atIndex: (int) index{
    return [tileMatrices objectAtIndex:tileMatrices.count - index - 1];
}

+(NSNumber *) approximateZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andLength: (double) length{
    return [self approximateZoomLevelWithWidths:widths andHeights:heights andTileMatrices:tileMatrices andWidth:length andHeight:length];
}

+(NSNumber *) approximateZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andWidth: (double) width andHeight: (double) height{
    
    NSNumber *widthZoomLevel = [self approximateZoomLevelWithLengths:widths andTileMatrices:tileMatrices andLength:width];
    NSNumber *heightZoomLevel = [self approximateZoomLevelWithLengths:heights andTileMatrices:tileMatrices andLength:height];
    
    NSNumber *expectedZoomLevel;
    if (widthZoomLevel == nil) {
        expectedZoomLevel = heightZoomLevel;
    } else if (heightZoomLevel == nil) {
        expectedZoomLevel = widthZoomLevel;
    } else {
        expectedZoomLevel = [widthZoomLevel compare:heightZoomLevel] == NSOrderedDescending ? widthZoomLevel : heightZoomLevel;
    }
    
    return expectedZoomLevel;
}

/**
 * Get the approximate zoom level for length using the factor of 2 rule
 * between zoom levels
 *
 * @param lengths
 *            sorted lengths
 * @param tileMatrices
 *            tile matrices
 * @param length
 *            length in default units
 * @return approximate zoom level
 */
+(NSNumber *) approximateZoomLevelWithLengths: (NSArray *) lengths andTileMatrices: (NSArray *) tileMatrices andLength: (double) length{
    
    return nil; // TODO
    /*
    Long lengthZoomLevel = null;
    
    double minLength = lengths[0];
    double maxLength = lengths[lengths.length - 1];
    
    // Length is zoomed in further than available tiles
    if (length < minLength) {
        double levelsIn = Math.log(length / minLength) / Math.log(.5);
        long zoomAbove = (long) Math.floor(levelsIn);
        long zoomBelow = (long) Math.ceil(levelsIn);
        double lengthAbove = minLength * Math.pow(.5, zoomAbove);
        double lengthBelow = minLength * Math.pow(.5, zoomBelow);
        lengthZoomLevel = tileMatrices.get(tileMatrices.size() - 1)
        .getZoomLevel();
        if (lengthAbove - length <= length - lengthBelow) {
            lengthZoomLevel += zoomAbove;
        } else {
            lengthZoomLevel += zoomBelow;
        }
    }
    // Length is zoomed out further than available tiles
    else if (length > maxLength) {
        double levelsOut = Math.log(length / maxLength) / Math.log(2);
        long zoomAbove = (long) Math.ceil(levelsOut);
        long zoomBelow = (long) Math.floor(levelsOut);
        double lengthAbove = maxLength * Math.pow(2, zoomAbove);
        double lengthBelow = maxLength * Math.pow(2, zoomBelow);
        lengthZoomLevel = tileMatrices.get(0).getZoomLevel();
        if (length - lengthBelow <= lengthAbove - length) {
            lengthZoomLevel -= zoomBelow;
        } else {
            lengthZoomLevel -= zoomAbove;
        }
    }
    // Length is between the available tiles
    else {
        int lengthIndex = Arrays.binarySearch(lengths, length);
        if (lengthIndex < 0) {
            lengthIndex = (lengthIndex + 1) * -1;
        }
        double zoomDistance = Math.log(length / lengths[lengthIndex])
        / Math.log(.5);
        long zoomLevelAbove = getTileMatrixAtLengthIndex(tileMatrices,
                                                         lengthIndex).getZoomLevel();
        zoomLevelAbove += Math.round(zoomDistance);
        lengthZoomLevel = zoomLevelAbove;
    }
    
    return lengthZoomLevel;
     */
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
