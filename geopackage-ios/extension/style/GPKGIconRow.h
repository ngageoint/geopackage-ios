//
//  GPKGIconRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGMediaRow.h"
#import "GPKGIconTable.h"

/**
 * Icon Row containing the values from a single result set row
 */
@interface GPKGIconRow : GPKGMediaRow

/**
 * Initializer to create an empty row
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param table       icon table
 *  @param columns  columns
 *  @param values      values
 *
 *  @return new icon row
 */
-(instancetype) initWithIconTable: (GPKGIconTable *) table andColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table icon table
 *
 *  @return new icon row
 */
-(instancetype) initWithIconTable: (GPKGIconTable *) table;

/**
 *  Get the icon table
 *
 *  @return icon table
 */
-(GPKGIconTable *) iconTable;

/**
 * Get the name column index
 *
 * @return name column index
 */
-(int) nameColumnIndex;

/**
 * Get the name column
 *
 * @return name column
 */
-(GPKGUserCustomColumn *) nameColumn;

/**
 * Get the name
 *
 * @return name
 */
-(NSString *) name;

/**
 * Set the name
 *
 * @param name
 *            Feature Icon name
 */
-(void) setName: (NSString *) name;

/**
 * Get the description column index
 *
 * @return description column index
 */
-(int) descriptionColumnIndex;

/**
 * Get the description column
 *
 * @return description column
 */
-(GPKGUserCustomColumn *) descriptionColumn;

/**
 * Get the description
 *
 * @return description
 */
-(NSString *) description;

/**
 * Set the description
 *
 * @param description Feature Icon description
 */
-(void) setDescription: (NSString *) description;

/**
 * Get the width column index
 *
 * @return width column index
 */
-(int) widthColumnIndex;

/**
 * Get the width column
 *
 * @return width column
 */
-(GPKGUserCustomColumn *) widthColumn;

/**
 * Get the width
 *
 * @return width
 */
-(NSDecimalNumber *) width;

/**
 * Set the width
 *
 * @param width Icon display width, when null use actual icon width
 */
-(void) setWidth: (NSDecimalNumber *) width;

/**
 * Set the width
 *
 * @param width Icon display width, when null use actual icon width
 */
-(void) setWidthValue: (double) width;

/**
 * Get the width or derived width from the icon data and scaled as needed for the height
 *
 * @return derived width
 */
-(double) derivedWidth;

/**
 * Get the height column index
 *
 * @return height column index
 */
-(int) heightColumnIndex;

/**
 * Get the height column
 *
 * @return height column
 */
-(GPKGUserCustomColumn *) heightColumn;

/**
 * Get the height
 *
 * @return height
 */
-(NSDecimalNumber *) height;

/**
 * Set the height
 *
 * @param height Icon display height, when null use actual icon height
 */
-(void) setHeight: (NSDecimalNumber *) height;

/**
 * Set the height
 *
 * @param height Icon display height, when null use actual icon height
 */
-(void) setHeightValue: (double) height;

/**
 * Get the height or derived height from the icon data and scaled as needed for the width
 *
 * @return derived height
 */
-(double) derivedHeight;

/**
 * Get the derived width and height from the values and icon data, scaled as
 * needed
 *
 * @return derived dimensions array with two values, width at index 0, height at index 1
 */
-(double *) derivedDimensions;

/**
 * Get the anchor u column index
 *
 * @return anchor u column index
 */
-(int) anchorUColumnIndex;

/**
 * Get the anchor u column
 *
 * @return anchor u column
 */
-(GPKGUserCustomColumn *) anchorUColumn;

/**
 * Get the anchor u
 *
 * @return anchor u
 */
-(NSDecimalNumber *) anchorU;

/**
 * Set the anchor u
 *
 * @param anchor UV Mapping horizontal anchor distance inclusively between 0.0
 *               and 1.0 from the left edge, when null assume 0.5 (middle of
 *               icon)
 */
-(void) setAnchorU: (NSDecimalNumber *) anchor;

/**
 * Set the anchor u
 *
 * @param anchor UV Mapping horizontal anchor distance inclusively between 0.0
 *               and 1.0 from the left edge, when null assume 0.5 (middle of
 *               icon)
 */
-(void) setAnchorUValue: (double) anchor;

/**
 * Get the anchor u value or the default value of 0.5
 *
 * @return anchor u value
 */
-(double) anchorUOrDefault;

/**
 * Get the anchor v column index
 *
 * @return anchor v column index
 */
-(int) anchorVColumnIndex;

/**
 * Get the anchor v column
 *
 * @return anchor v column
 */
-(GPKGUserCustomColumn *) anchorVColumn;

/**
 * Get the anchor v
 *
 * @return anchor v
 */
-(NSDecimalNumber *) anchorV;

/**
 * Set the anchor v
 *
 * @param anchor UV Mapping vertical anchor distance inclusively between 0.0
 *               and 1.0 from the top edge, when null assume 1.0 (bottom of
 *               icon)
 */
-(void) setAnchorV: (NSDecimalNumber *) anchor;

/**
 * Set the anchor v
 *
 * @param anchor UV Mapping vertical anchor distance inclusively between 0.0
 *               and 1.0 from the top edge, when null assume 1.0 (bottom of
 *               icon)
 */
-(void) setAnchorVValue: (double) anchor;

/**
 * Get the anchor v value or the default value of 1.0
 *
 * @return anchor v value
 */
-(double) anchorVOrDefault;

@end
