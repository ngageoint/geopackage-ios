//
//  GPKGCoverageDataTiffImage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/3/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGCoverageDataImage.h"
#import "GPKGTileRow.h"
#import "TIFFFileDirectory.h"

/**
 * Coverage Data TIFF image
 */
@interface GPKGCoverageDataTiffImage : NSObject<GPKGCoverageDataImage>

/**
 *  Initialize
 *
 *  @param tileRow tile row
 *
 *  @return new instance
 */
-(instancetype) initWithTileRow: (GPKGTileRow *) tileRow;

/**
 *  Initialize
 *
 *  @param directory file directory
 *
 *  @return new instance
 */
-(instancetype) initWithFileDirectory: (TIFFFileDirectory *) directory;

/**
 * Get the image data
 *
 * @return image data
 */
-(NSData *) imageData;

/**
 * Get the file directory
 *
 * @return file directory
 */
-(TIFFFileDirectory *) directory;

/**
 * Get the rasters, read if needed
 *
 * @return rasters
 */
-(TIFFRasters *) rasters;

/**
 * Write the TIFF file to the image bytes
 */
-(void) writeTiff;

/**
 * Get the pixel at the coordinate
 *
 * @param x x coordinate
 * @param y y coordinate
 * @return pixel value
 */
-(float) pixelAtX: (int) x andY: (int) y;

@end
