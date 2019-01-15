//
//  GPKGColorUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/14/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Color utilities with support for hex, RBG, arithmetic RBG, and integer colors
 */
@interface GPKGColorUtils : NSObject

/**
 * Convert the hex color values to a hex color
 *
 * @param red
 *            red hex color in format RR or R
 * @param green
 *            green hex color in format GG or G
 * @param blue
 *            blue hex color in format BB or B
 *
 * @return hex color in format #RRGGBB
 */
+(NSString *) toColorFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue;

/**
 * Convert the hex color values to a hex color, shorthanded when possible
 *
 * @param red
 *            red hex color in format RR or R
 * @param green
 *            green hex color in format GG or G
 * @param blue
 *            blue hex color in format BB or B
 *
 * @return hex color in format #RGB or #RRGGBB
 */
+(NSString *) toColorShorthandFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue;

/**
 * Convert the hex color values to a hex color including an opaque alpha
 * value of FF
 *
 * @param red
 *            red hex color in format RR or R
 * @param green
 *            green hex color in format GG or G
 * @param blue
 *            blue hex color in format BB or B
 *
 * @return hex color in format #AARRGGBB
 */
+(NSString *) toColorWithAlphaFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue;

/**
 * Convert the hex color values to a hex color including an opaque alpha
 * value of FF or F, shorthanded when possible
 *
 * @param red
 *            red hex color in format RR or R
 * @param green
 *            green hex color in format GG or G
 * @param blue
 *            blue hex color in format BB or B
 *
 * @return hex color in format #ARGB or #AARRGGBB
 */
+(NSString *) toColorShorthandWithAlphaFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue;

/**
 * Convert the hex color values to a hex color
 *
 * @param red
 *            red hex color in format RR or R
 * @param green
 *            green hex color in format GG or G
 * @param blue
 *            blue hex color in format BB or B
 * @param alpha
 *            alpha hex color in format AA or A, null to not include alpha
 *
 * @return hex color in format #AARRGGBB or #RRGGBB
 */
+(NSString *) toColorWithAlphaFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue andAlpha: (NSString *) alpha;

/**
 * Convert the hex color values to a hex color, shorthanded when possible
 *
 * @param red
 *            red hex color in format RR or R
 * @param green
 *            green hex color in format GG or G
 * @param blue
 *            blue hex color in format BB or B
 * @param alpha
 *            alpha hex color in format AA or A, null to not include alpha
 *
 * @return hex color in format #ARGB, #RGB, #AARRGGBB, or #RRGGBB
 */
+(NSString *) toColorShorthandWithAlphaFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue andAlpha: (NSString *) alpha;

/**
 * Convert the RBG values to a color integer
 *
 * @param red
 *            red integer color inclusively between 0 and 255
 * @param green
 *            green integer color inclusively between 0 and 255
 * @param blue
 *            blue integer color inclusively between 0 and 255
 *
 * @return integer color
 */
+(int) toColorFromRed: (int) red andGreen: (int) green andBlue: (int) blue;

/**
 * Convert the RBG values to a color integer including an opaque alpha value
 * of 255
 *
 * @param red
 *            red integer color inclusively between 0 and 255
 * @param green
 *            green integer color inclusively between 0 and 255
 * @param blue
 *            blue integer color inclusively between 0 and 255
 *
 * @return integer color
 */
+(int) toColorWithAlphaFromRed: (int) red andGreen: (int) green andBlue: (int) blue;

/**
 * Convert the RBGA values to a color integer
 *
 * @param red
 *            red integer color inclusively between 0 and 255
 * @param green
 *            green integer color inclusively between 0 and 255
 * @param blue
 *            blue integer color inclusively between 0 and 255
 * @param alpha
 *            alpha integer color inclusively between 0 and 255, -1 to not
 *            include alpha
 *
 * @return integer color
 */
+(int) toColorWithAlphaFromRed: (int) red andGreen: (int) green andBlue: (int) blue andAlpha: (int) alpha;

/**
 * Convert the RGB integer to a hex single color
 *
 * @param color
 *            integer color inclusively between 0 and 255
 * @return hex single color in format FF
 */
+(NSString *) toHexFromRGB: (int) color;

/**
 * Convert the arithmetic RGB float to a hex single color
 *
 * @param color
 *            float color inclusively between 0.0 and 1.0
 * @return hex single color in format FF
 */
+(NSString *) toHexFromArithmeticRGB: (float) color;

/**
 * Convert the hex single color to a RBG integer
 *
 * @param color
 *            hex single color in format FF or F
 *
 * @return integer color inclusively between 0 and 255
 */
+(int) toRGBFromHex: (NSString *) color;

/**
 * Convert the arithmetic RGB float to a RBG integer
 *
 * @param color
 *            float color inclusively between 0.0 and 1.0
 *
 * @return integer color inclusively between 0 and 255
 */
+(int) toRGBFromArithmeticRGB: (float) color;

/**
 * Convert the hex single color to an arithmetic RBG float
 *
 * @param color
 *            hex single color in format FF or F
 * @return float color inclusively between 0.0 and 1.0
 */
+(float) toArithmeticRGBFromHex: (NSString *) color;

/**
 * Convert the RGB integer to an arithmetic RBG float
 *
 * @param color
 *            integer color inclusively between 0 and 255
 * @return float color inclusively between 0.0 and 1.0
 */
+(float) toArithmeticRGBFromRGB: (int) color;

/**
 * Convert red, green, and blue arithmetic values to HSL (hue, saturation,
 * lightness) values
 *
 * @param red
 *            red color inclusively between 0.0 and 1.0
 * @param green
 *            green color inclusively between 0.0 and 1.0
 * @param blue
 *            blue color inclusively between 0.0 and 1.0
 * @return HSL array where: 0 = hue, 1 = saturation, 2 = lightness
 */
+(float *) toHSLFromArithmeticRed: (float) red andGreen: (float) green andBlue: (float) blue;

/**
 * Convert red, green, and blue integer values to HSL (hue, saturation,
 * lightness) values
 *
 * @param red
 *            red color inclusively between 0 and 255
 * @param green
 *            green color inclusively between 0 and 255
 * @param blue
 *            blue color inclusively between 0 and 255
 * @return HSL array where: 0 = hue, 1 = saturation, 2 = lightness
 */
+(float *) toHSLFromRed: (int) red andGreen: (int) green andBlue: (int) blue;

/**
 * Convert HSL (hue, saturation, and lightness) values to RGB arithmetic
 * values
 *
 * @param hue
 *            hue value inclusively between 0.0 and 360.0
 * @param saturation
 *            saturation inclusively between 0.0 and 1.0
 * @param lightness
 *            lightness inclusively between 0.0 and 1.0
 * @return arithmetic RGB array where: 0 = red, 1 = green, 2 = blue
 */
+(float *) toArithmeticRGBFromHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness;

/**
 * Convert HSL (hue, saturation, and lightness) values to RGB integer values
 *
 * @param hue
 *            hue value inclusively between 0.0 and 360.0
 * @param saturation
 *            saturation inclusively between 0.0 and 1.0
 * @param lightness
 *            lightness inclusively between 0.0 and 1.0
 * @return RGB integer array where: 0 = red, 1 = green, 2 = blue
 */
+(int *) toRGBFromHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness;

/**
 * Get the hex red color from the hex string
 *
 * @param hex
 *            hex color
 * @return hex red color in format RR
 */
+(NSString *) redHexFromHex: (NSString *) hex;

/**
 * Get the hex green color from the hex string
 *
 * @param hex
 *            hex color
 * @return hex green color in format GG
 */
+(NSString *) greenHexFromHex: (NSString *) hex;

/**
 * Get the hex blue color from the hex string
 *
 * @param hex
 *            hex color
 * @return hex blue color in format BB
 */
+(NSString *) blueHexFromHex: (NSString *) hex;

/**
 * Get the hex alpha color from the hex string if it exists
 *
 * @param hex
 *            hex color
 * @return hex alpha color in format AA or null
 */
+(NSString *) alphaHexFromHex: (NSString *) hex;

/**
 * Get the red color from color integer
 *
 * @param color
 *            color integer
 * @return red color
 */
+(int) redFromColor: (int) color;

/**
 * Get the green color from color integer
 *
 * @param color
 *            color integer
 * @return green color
 */
+(int) greenFromColor: (int) color;

/**
 * Get the blue color from color integer
 *
 * @param color
 *            color integer
 * @return blue color
 */
+(int) blueFromColor: (int) color;

/**
 * Get the alpha color from color integer
 *
 * @param color
 *            color integer
 * @return alpha color
 */
+(int) alphaFromColor: (int) color;

/**
 * Shorthand the hex color if possible
 *
 * @param color
 *            hex color
 * @return shorthand hex color or original value
 */
+(NSString *) shorthandHex: (NSString *) color;

/**
 * Expand the hex if it is in shorthand
 *
 * @param color
 *            hex color
 * @return expanded hex color or original value
 */
+(NSString *) expandShorthandHex: (NSString *) color;

/**
 * Shorthand the hex single color if possible
 *
 * @param color
 *            hex single color
 * @return shorthand hex color or original value
 */
+(NSString *) shorthandHexSingle: (NSString *) color;

/**
 * Expand the hex single if it is in shorthand
 *
 * @param color
 *            hex single color
 * @return expanded hex color or original value
 */
+(NSString *) expandShorthandHexSingle: (NSString *) color;

/**
 * Check if the hex color value is valid
 *
 * @param color
 *            hex color
 * @return true if valid
 */
+(BOOL) isValidHex: (NSString *) color;

/**
 * Validate the hex color value
 *
 * @param color
 *            hex color
 */
+(void) validateHex: (NSString *) color;

/**
 * Check if the hex single color value is valid
 *
 * @param color
 *            hex single color
 * @return true if valid
 */
+(BOOL) isValidHexSingle: (NSString *) color;

/**
 * Validate the hex single color value
 *
 * @param color
 *            hex single color
 */
+(void) validateHexSingle: (NSString *) color;

/**
 * Check if the RBG integer color is valid, inclusively between 0 and 255
 *
 * @param color
 *            decimal color
 * @return true if valid
 */
+(BOOL) isValidRGB: (int) color;

/**
 * Validate the RBG integer color is inclusively between 0 and 255
 *
 * @param color
 *            decimal color
 */
+(void) validateRGB: (int) color;

/**
 * Check if the arithmetic RGB float color is valid, inclusively between 0.0
 * and 1.0
 *
 * @param color
 *            decimal color
 * @return true if valid
 */
+(BOOL) isValidArithmeticRGB: (float) color;

/**
 * Validate the arithmetic RGB float color is inclusively between 0.0 and
 * 1.0
 *
 * @param color
 *            decimal color
 */
+(void) validateArithmeticRGB: (float) color;

/**
 * Check if the HSL hue float value is valid, inclusively between 0.0 and
 * 360.0
 *
 * @param hue
 *            hue value
 * @return true if valid
 */
+(BOOL) isValidHue: (float) hue;

/**
 * Validate the HSL hue float value is inclusively between 0.0 and 360.0
 *
 * @param hue
 *            hue value
 */
+(void) validateHue: (float) hue;

/**
 * Check if the HSL saturation float value is valid, inclusively between 0.0
 * and 1.0
 *
 * @param saturation
 *            saturation value
 * @return true if valid
 */
+(BOOL) isValidSaturation: (float) saturation;

/**
 * Validate the HSL saturation float value is inclusively between 0.0 and
 * 1.0
 *
 * @param saturation
 *            saturation value
 */
+(void) validateSaturation: (float) saturation;

/**
 * Check if the HSL lightness float value is valid, inclusively between 0.0
 * and 1.0
 *
 * @param lightness
 *            lightness value
 * @return true if valid
 */
+(BOOL) isValidLightness: (float) lightness;

/**
 * Validate the HSL lightness float value is inclusively between 0.0 and 1.0
 *
 * @param lightness
 *            lightness value
 */
+(void) validateLightness: (float) lightness;

@end
