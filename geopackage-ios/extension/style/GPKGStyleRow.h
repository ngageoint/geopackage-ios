//
//  GPKGStyleRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGAttributesRow.h"
#import "GPKGStyleTable.h"
#import "GPKGColor.h"

@interface GPKGStyleRow : GPKGAttributesRow

/**
 * Initializer to create an empty row
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param table       style table
 *  @param columns   columns
 *  @param values      values
 *
 *  @return new style row
 */
-(instancetype) initWithStyleTable: (GPKGStyleTable *) table andColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table style table
 *
 *  @return new style row
 */
-(instancetype) initWithStyleTable: (GPKGStyleTable *) table;

/**
 *  Get the style table
 *
 *  @return style table
 */
-(GPKGStyleTable *) table;

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
-(GPKGAttributesColumn *) nameColumn;

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
-(GPKGAttributesColumn *) descriptionColumn;

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
 * Get the color column index
 *
 * @return color column index
 */
-(int) colorColumnIndex;

/**
 * Get the color column
 *
 * @return color column
 */
-(GPKGAttributesColumn *) colorColumn;

/**
 * Get the style color
 *
 * @return color
 */
-(GPKGColor *) color;

/**
 * Check if the style has a color
 *
 * @return true if has a color
 */
-(BOOL) hasColor;

/**
 * Get the color
 *
 * @return color
 */
-(NSString *) hexColor;

/**
 * Set the color
 *
 * @param color color
 */
-(void) setColor: (GPKGColor *) color;

/**
 * Set the color
 *
 * @param color Geometry color in hex format #RRGGBB or #RGB
 */
-(void) setHexColor: (NSString *) color;

/**
 * Get the color or default value
 *
 * @return color
 */
-(GPKGColor *) colorOrDefault;

/**
 * Get the color or default value
 *
 * @return color
 */
-(NSString *) hexColorOrDefault;

/**
 * Get the opacity column index
 *
 * @return opacity column index
 */
-(int) opacityColumnIndex;

/**
 * Get the opacity column
 *
 * @return opacity column
 */
-(GPKGAttributesColumn *) opacityColumn;

/**
 * Get the opacity
 *
 * @return opacity
 */
-(NSDecimalNumber *) opacity;

/**
 * Set the opacity
 *
 * @param opacity Geometry color opacity inclusively between 0.0 and 1.0
 */
-(void) setOpacity: (NSDecimalNumber *) opacity;

/**
 * Set the opacity
 *
 * @param opacity Geometry color opacity inclusively between 0.0 and 1.0
 */
-(void) setOpactiyValue: (double) opacity;

/**
 * Get the opacity or default value
 *
 * @return opacity
 */
-(double) opacityOrDefault;

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
-(GPKGAttributesColumn *) widthColumn;

/**
 * Get the width
 *
 * @return width
 */
-(NSDecimalNumber *) width;

/**
 * Set the width
 *
 * @param width Geometry line stroke or point width greater than or equal to
 *              0.0
 */
-(void) setWidth: (NSDecimalNumber *) width;

/**
 * Set the width
 *
 * @param width Geometry line stroke or point width greater than or equal to
 *              0.0
 */
-(void) setWidthValue: (double) width;

/**
 * Get the width value or default width
 *
 * @return width
 */
-(double) widthOrDefault;

/**
 * Get the fill color column index
 *
 * @return fill color column index
 */
-(int) fillColorColumnIndex;

/**
 * Get the fill color column
 *
 * @return fill color column
 */
-(GPKGAttributesColumn *) fillColorColumn;

/**
 * Get the style fill color
 *
 * @return fill color
 */
-(GPKGColor *) fillColor;

/**
 * Check if the style has a fill color
 *
 * @return true if has a fill color
 */
-(BOOL) hasFillColor;

/**
 * Get the fill color
 *
 * @return fill color
 */
-(NSString *) fillHexColor;

/**
 * Set the fill color
 *
 * @param color color
 */
-(void) setFillColor: (GPKGColor *) color;

/**
 * Set the fill color
 *
 * @param fillColor Closed geometry fill color in hex format #RRGGBB or #RGB
 */
-(void) setFillHexColor: (NSString *) fillColor;

/**
 * Get the fill opacity column index
 *
 * @return fill opacity column index
 */
-(int) fillOpacityColumnIndex;

/**
 * Get the fill opacity column
 *
 * @return fill opacity column
 */
-(GPKGAttributesColumn *) fillOpacityColumn;

/**
 * Get the fill opacity
 *
 * @return fill opacity
 */
-(NSDecimalNumber *) fillOpacity;

/**
 * Set the fill opacity
 *
 * @param fillOpacity Closed geometry fill color opacity inclusively between 0.0 and
 *                    1.0
 */
-(void) setFillOpacity: (NSDecimalNumber *) fillOpacity;

/**
 * Set the fill opacity
 *
 * @param fillOpacity Closed geometry fill color opacity inclusively between 0.0 and
 *                    1.0
 */
-(void) setFillOpacityValue: (double) fillOpacity;

/**
 * Get the fill opacity or default value
 *
 * @return fill opacity
 */
-(double) fillOpacityOrDefault;

@end
