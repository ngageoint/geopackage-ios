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

+(NSNumber *) getZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andLength: (double) length{
    
    NSNumber * zoomLevel = nil;
    
    NSDecimalNumber * lengthNumber = [[NSDecimalNumber alloc] initWithDouble:length];
    
    // Find where the width and height fit in
    int widthIndex = (int)[widths indexOfObject:lengthNumber
                                        inSortedRange:NSMakeRange(0, [widths count])
                                              options:NSBinarySearchingInsertionIndex
                                      usingComparator:^(id obj1, id obj2)
                            {
                                return [obj1 compare:obj2];
                            }];
    int heightIndex = (int)[heights indexOfObject:lengthNumber
                                    inSortedRange:NSMakeRange(0, [heights count])
                                          options:NSBinarySearchingInsertionIndex
                                  usingComparator:^(id obj1, id obj2)
                             {
                                 return [obj1 compare:obj2];
                             }];
    
    // Find the closest width or verify it isn't too small or large
    if (widthIndex == 0) {
        if (length < [self getMinLength:widths]) {
            widthIndex = -1;
        }
    } else if (widthIndex == [widths count]) {
        if (length >= [self getMaxLength:widths]) {
            widthIndex = -1;
        } else {
            widthIndex = widthIndex - 1;
        }
    } else if (length - [(NSDecimalNumber *)[widths objectAtIndex:widthIndex-1] doubleValue] <
               [(NSDecimalNumber *)[widths objectAtIndex:widthIndex] doubleValue] - length) {
        widthIndex--;
    }
    
    // Find the closest height or verify it isn't too small or large
    if (heightIndex == 0) {
        if (length < [self getMinLength:heights]) {
            heightIndex = -1;
        }
    } else if (heightIndex == [heights count]) {
        if (length >= [self getMaxLength:heights]) {
            heightIndex = -1;
        } else {
            heightIndex = heightIndex - 1;
        }
    } else if (length - [(NSDecimalNumber *)[heights objectAtIndex:heightIndex-1] doubleValue] <
               [(NSDecimalNumber *)[heights objectAtIndex:heightIndex] doubleValue] - length) {
        heightIndex--;
    }
    
    if(widthIndex >= 0 && heightIndex >= 0){
        
        // Use one zoom size smaller if possible
        
        int index = widthIndex < heightIndex ? widthIndex : heightIndex;
        if (index >= 0) {
            
            GPKGTileMatrix * tileMatrix = [tileMatrices objectAtIndex:[tileMatrices count]
                                                     - index - 1];
            zoomLevel = tileMatrix.zoomLevel;
        }
    }
    
    return zoomLevel;
}

+(double) getMaxLengthWithWidths: (NSArray *) widths andHeights: (NSArray *) heights{
    double maxWidth = [self getMaxLength:widths];
    double maxHeight = [self getMaxLength:heights];
    double maxLength = MIN(maxWidth, maxHeight);
    return maxLength;
}

+(double) getMinLengthWithWidths: (NSArray *) widths andHeights: (NSArray *) heights{
    double minWidth = [self getMinLength:widths];
    double minHeight = [self getMinLength:heights];
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
+(double) getMaxLength: (NSArray *) lengths{
    return [(NSDecimalNumber *)lengths[lengths.count - 1] doubleValue] / .51;
}

/**
 *  Get the min length distance value from the sorted array of lengths
 *
 *  @param lengths sorted tile matrix lengths
 *
 *  @return min length
 */
+(double) getMinLength: (NSArray *) lengths{
    return [(NSDecimalNumber *)lengths[0] doubleValue] * .51;
}

@end
