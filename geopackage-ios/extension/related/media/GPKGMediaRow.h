//
//  GPKGMediaRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomRow.h"
#import "GPKGMediaTable.h"
#import "GPKGCompressFormats.h"

/**
 * User Media Row containing the values from a single result set row
 */
@interface GPKGMediaRow : GPKGUserCustomRow

/**
 *  Initialize
 *
 *  @param table       media table
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return new media row
 */
-(instancetype) initWithMediaTable: (GPKGMediaTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table media table
 *
 *  @return new media row
 */
-(instancetype) initWithMediaTable: (GPKGMediaTable *) table;

/**
 *  Get the media table
 *
 *  @return media table
 */
-(GPKGMediaTable *) table;

/**
 * Get the data column index
 *
 * @return data column index
 */
-(int) dataColumnIndex;

/**
 * Get the data column
 *
 * @return data column
 */
-(GPKGUserCustomColumn *) dataColumn;

/**
 * Get the data
 *
 * @return data
 */
-(NSData *) data;

/**
 * Set the data
 *
 * @param data
 *            data
 */
-(void) setData: (NSData *) data;

/**
 *  Get the properties that apply to the data image source
 *
 *  See: https://developer.apple.com/documentation/imageio/cgimageproperties/individual_image_properties
 *  kCGImagePropertyPixelWidth, kCGImagePropertyPixelHeight, etc
 *
 *  @return Image Source Container Properties
 */
-(NSDictionary *) dataImageSourceProperties;

/**
 *  Get the data image
 *
 *  @return data image
 */
-(UIImage *) dataImage;

/**
 *  Get the data as a scaled image
 *
 *  @param scale scale, 0.0 to 1.0
 *
 *  @return data image
 */
-(UIImage *) dataImageWithScale: (CGFloat) scale;

/**
 *  Set the data from a full quality image
 *
 *  @param image  image
 *  @param format image format
 */
-(void) setDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format;

/**
 *  Set the data from an image
 *
 *  @param image  image
 *  @param format image format
 *  @param quality compression quality, 0.0 to 1.0, used only for GPKG_CF_JPEG
 */
-(void) setDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format andQuality: (CGFloat) quality;

/**
 * Get the content type column index
 *
 * @return content type column index
 */
-(int) contentTypeColumnIndex;

/**
 * Get the content type column
 *
 * @return content type column
 */
-(GPKGUserCustomColumn *) contentTypeColumn;

/**
 * Get the content type
 *
 * @return content type
 */
-(NSString *) contentType;

/**
 * Set the content type
 *
 * @param contentType
 *            content type
 */
-(void) setContentType: (NSString *) contentType;

@end
