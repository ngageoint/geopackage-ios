//
//  GPKGColorUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/14/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGColorUtils.h"

NSString *const hexColorPattern = @"^#?(([0-9a-fA-F]{3}){1,2}|([0-9a-fA-F]{4}){1,2})$";
NSString *const hexSingleColorPattern = @"^[0-9a-fA-F]{1,2}$";

@implementation GPKGColorUtils

static NSRegularExpression *hexColorExpression;
static NSRegularExpression *hexSingleColorExpression;

+(void) initialize{
    if(hexColorExpression == nil){
        NSError  *error = nil;
        hexColorExpression = [NSRegularExpression regularExpressionWithPattern:hexColorPattern options:0 error:&error];
        if(error){
            [NSException raise:@"Hex Color Regular Expression" format:@"Failed to create hex color regular expression with error: %@", error];
        }
    }
    if(hexSingleColorExpression == nil){
        NSError  *error = nil;
        hexSingleColorExpression = [NSRegularExpression regularExpressionWithPattern:hexSingleColorPattern options:0 error:&error];
        if(error){
            [NSException raise:@"Hex Single Color Regular Expression" format:@"Failed to create hex single color regular expression with error: %@", error];
        }
    }
}

+(NSString *) toColorFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue{
    return [self toColorWithAlphaFromHexRed:red andGreen:green andBlue:blue andAlpha:nil];
}

+(NSString *) toColorShorthandFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue{
    return [self shorthandHex:[self toColorFromHexRed:red andGreen:green andBlue:blue]];
}

+(NSString *) toColorWithAlphaFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue{
    NSString *defaultAlpha = @"FF";
    if(red != nil && red.length > 0 && [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[red characterAtIndex:0]]){
        defaultAlpha = [defaultAlpha lowercaseString];
    }
    return [self toColorWithAlphaFromHexRed:red andGreen:green andBlue:blue andAlpha:defaultAlpha];
}

+(NSString *) toColorShorthandWithAlphaFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue{
    return [self shorthandHex:[self toColorWithAlphaFromHexRed:red andGreen:green andBlue:blue]];
}

+(NSString *) toColorWithAlphaFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue andAlpha: (NSString *) alpha{
    [self validateHexSingle:red];
    [self validateHexSingle:green];
    [self validateHexSingle:blue];
    NSMutableString *color = [NSMutableString stringWithString:@"#"];
    if(alpha != nil){
        [color appendString:[self expandShorthandHexSingle:alpha]];
    }
    [color appendString:[self expandShorthandHexSingle:red]];
    [color appendString:[self expandShorthandHexSingle:green]];
    [color appendString:[self expandShorthandHexSingle:blue]];
    return color;
}

+(NSString *) toColorShorthandWithAlphaFromHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue andAlpha: (NSString *) alpha{
    return [self shorthandHex:[self toColorWithAlphaFromHexRed:red andGreen:green andBlue:blue andAlpha:alpha]];
}

+(int) toColorFromRed: (int) red andGreen: (int) green andBlue: (int) blue{
    return [self toColorWithAlphaFromRed:red andGreen:green andBlue:blue andAlpha:-1];
}

+(unsigned int) toUnsignedColorFromRed: (int) red andGreen: (int) green andBlue: (int) blue{
    return (unsigned int) [self toColorFromRed:red andGreen:green andBlue:blue];
}

+(int) toColorWithAlphaFromRed: (int) red andGreen: (int) green andBlue: (int) blue{
    return [self toColorWithAlphaFromRed:red andGreen:green andBlue:blue andAlpha:255];
}

+(unsigned int) toUnsignedColorWithAlphaFromRed: (int) red andGreen: (int) green andBlue: (int) blue{
    return (unsigned int) [self toColorWithAlphaFromRed:red andGreen:green andBlue:blue];
}

+(int) toColorWithAlphaFromRed: (int) red andGreen: (int) green andBlue: (int) blue andAlpha: (int) alpha{
    [self validateRGB:red];
    [self validateRGB:green];
    [self validateRGB:blue];
    int color = (red & 0xff) << 16 | (green & 0xff) << 8 | (blue & 0xff);
    if(alpha != -1){
        [self validateRGB:alpha];
        color = (alpha & 0xff) << 24 | color;
    }
    return color;
}

+(unsigned int) toUnsignedColorWithAlphaFromRed: (int) red andGreen: (int) green andBlue: (int) blue andAlpha: (int) alpha{
    return (unsigned int) [self toColorWithAlphaFromRed:red andGreen:green andBlue:blue andAlpha:alpha];
}

+(NSString *) toHexFromRGB: (int) color{
    [self validateRGB:color];
    NSString *hex = [[NSString stringWithFormat:@"%x", color] uppercaseString];
    if(hex.length == 1){
        hex = [NSString stringWithFormat:@"0%@", hex];
    }
    return hex;
}

+(NSString *) toHexFromArithmeticRGB: (float) color{
    return [self toHexFromRGB:[self toRGBFromArithmeticRGB:color]];
}

+(int) toRGBFromHex: (NSString *) color{
    [self validateHexSingle:color];
    if(color.length == 1){
        color = [NSString stringWithFormat:@"%@%@", color, color];
    }
    unsigned int rgb;
    [[NSScanner scannerWithString:color] scanHexInt:&rgb];
    return rgb;
}

+(int) toRGBFromArithmeticRGB: (float) color{
    [self validateArithmeticRGB:color];
    return (int)lroundf(255 * color);
}

+(float) toArithmeticRGBFromHex: (NSString *) color{
    return [self toArithmeticRGBFromRGB:[self toRGBFromHex:color]];
}

+(float) toArithmeticRGBFromRGB: (int) color{
    [self validateRGB:color];
    return color / 255.0f;
}

+(float *) toHSLFromArithmeticRed: (float) red andGreen: (float) green andBlue: (float) blue{
    
    [self validateArithmeticRGB:red];
    [self validateArithmeticRGB:green];
    [self validateArithmeticRGB:blue];
    
    float min = MIN(MIN(red, green), blue);
    float max = MAX(MAX(red, green), blue);
    
    float range = max - min;
    
    float hue = 0.0f;
    if (range > 0.0f) {
        if (red >= green && red >= blue) {
            hue = (green - blue) / range;
        } else if (green >= blue) {
            hue = 2 + (blue - red) / range;
        } else {
            hue = 4 + (red - green) / range;
        }
    }
    
    hue *= 60.0f;
    if (hue < 0.0f) {
        hue += 360.0f;
    }
    
    float sum = min + max;
    
    float lightness = sum / 2.0f;
    
    float saturation;
    if (min == max) {
        saturation = 0.0f;
    } else {
        if (lightness < 0.5f) {
            saturation = range / sum;
        } else {
            saturation = range / (2.0f - max - min);
        }
    }
    
    float *hsl = calloc(3, sizeof(float));
    hsl[0] = hue;
    hsl[1] = saturation;
    hsl[2] = lightness;
    
    return hsl;
}

+(float *) toHSLFromRed: (int) red andGreen: (int) green andBlue: (int) blue{
    return [self toHSLFromArithmeticRed:[self toArithmeticRGBFromRGB:red] andGreen:[self toArithmeticRGBFromRGB:green] andBlue:[self toArithmeticRGBFromRGB:blue]];
}

+(float *) toArithmeticRGBFromHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness{
    
    [self validateHue:hue];
    [self validateSaturation:saturation];
    [self validateLightness:lightness];
    
    hue /= 60.0f;
    float t2;
    if (lightness <= 0.5f) {
        t2 = lightness * (saturation + 1);
    } else {
        t2 = lightness + saturation - (lightness * saturation);
    }
    float t1 = lightness * 2.0f - t2;
    
    float red = [self hslConvertT1:t1 andT2:t2 andHue:hue + 2];
    float green = [self hslConvertT1:t1 andT2:t2 andHue:hue];
    float blue = [self hslConvertT1:t1 andT2:t2 andHue:hue - 2];
    
    float *rgb = calloc(3, sizeof(float));
    rgb[0] = red;
    rgb[1] = green;
    rgb[2] = blue;
    
    return rgb;
}

+(int *) toRGBFromHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness{
    float *arithmeticRGB = [self toArithmeticRGBFromHue:hue andSaturation:saturation andLightness:lightness];
    
    int *rgb = calloc(3, sizeof(int));
    rgb[0] = [self toRGBFromArithmeticRGB:arithmeticRGB[0]];
    rgb[1] = [self toRGBFromArithmeticRGB:arithmeticRGB[1]];
    rgb[2] = [self toRGBFromArithmeticRGB:arithmeticRGB[2]];
    
    return rgb;
}

/**
 * HSL convert helper method
 *
 * @param t1
 *            t1
 * @param t2
 *            t2
 * @param hue
 *            hue
 * @return arithmetic RBG value
 */
+(float) hslConvertT1: (float) t1 andT2: (float) t2 andHue: (float) hue{
    float value;
    if (hue < 0) {
        hue += 6;
    }
    if (hue >= 6) {
        hue -= 6;
    }
    if (hue < 1) {
        value = (t2 - t1) * hue + t1;
    } else if (hue < 3) {
        value = t2;
    } else if (hue < 4) {
        value = (t2 - t1) * (4 - hue) + t1;
    } else {
        value = t1;
    }
    return value;
}

+(NSString *) redHexFromHex: (NSString *) hex{
    return [self hexSingleFromHex:hex andColorIndex:0];
}

+(NSString *) greenHexFromHex: (NSString *) hex{
    return [self hexSingleFromHex:hex andColorIndex:1];
}

+(NSString *) blueHexFromHex: (NSString *) hex{
    return [self hexSingleFromHex:hex andColorIndex:2];
}

+(NSString *) alphaHexFromHex: (NSString *) hex{
    return [self hexSingleFromHex:hex andColorIndex:-1];
}

/**
 * Get the hex single color
 *
 * @param hex
 *            hex color
 * @param colorIndex
 *            red=0, green=1, blue=2, alpha=-1
 * @return hex single color in format FF or null
 */
+(NSString *) hexSingleFromHex: (NSString *) hex andColorIndex: (int) colorIndex{
    [self validateHex:hex];
    
    if([hex hasPrefix:@"#"]){
        hex = [hex substringFromIndex:1];
    }
    
    int colorCharacters = 1;
    int numColors = (int)hex.length;
    if (numColors > 4) {
        colorCharacters++;
        numColors /= 2;
    }
    
    NSString *color = nil;
    if (colorIndex >= 0 || numColors > 3) {
        if (numColors > 3) {
            colorIndex++;
        }
        int startIndex = colorIndex;
        if (colorCharacters > 1) {
            startIndex *= 2;
        }
        color = [hex substringWithRange:NSMakeRange(startIndex, colorCharacters)];
        color = [self expandShorthandHexSingle:color];
    }
    
    return color;
}

+(int) redFromColor: (int) color{
    return (color >> 16) & 0xff;
}

+(int) redFromUnsignedColor: (unsigned int) color{
    return [self redFromColor:color];
}

+(int) greenFromColor: (int) color{
    return (color >> 8) & 0xff;
}

+(int) greenFromUnsignedColor: (unsigned int) color{
    return [self greenFromColor:color];
}

+(int) blueFromColor: (int) color{
    return color & 0xff;
}

+(int) blueFromUnsignedColor: (unsigned int) color{
    return [self blueFromColor:color];
}

+(int) alphaFromColor: (int) color{
    return (color >> 24) & 0xff;
}

+(int) alphaFromUnsignedColor: (unsigned int) color{
    return [self alphaFromColor:color];
}

+(NSString *) shorthandHex: (NSString *) color{
    [self validateHex:color];
    if(color.length > 5){
        NSMutableString *shorthandColor = [NSMutableString string];
        int startIndex = 0;
        if([color hasPrefix:@"#"]){
            [shorthandColor appendString:@"#"];
            startIndex++;
        }
        for (; startIndex < color.length; startIndex += 2) {
            NSString *shorthand = [self shorthandHexSingle:[color substringWithRange:NSMakeRange(startIndex, 2)]];
            if(shorthand.length > 1){
                shorthandColor = nil;
                break;
            }
            [shorthandColor appendString:shorthand];
        }
        if(shorthandColor != nil){
            color = shorthandColor;
        }
    }
    
    return color;
}

+(NSString *) expandShorthandHex: (NSString *) color{
    [self validateHex:color];
    if(color.length < 6){
        NSMutableString *expandColor = [NSMutableString string];
        int startIndex = 0;
        if([color hasPrefix:@"#"]){
            [expandColor appendString:@"#"];
            startIndex++;
        }
        for (; startIndex < color.length; startIndex++) {
            NSString *expand = [self expandShorthandHexSingle:[color substringWithRange:NSMakeRange(startIndex, 1)]];
            [expandColor appendString:expand];
        }
        color = expandColor;
    }
    return color;
}

+(NSString *) shorthandHexSingle: (NSString *) color{
    [self validateHexSingle:color];
    if(color.length > 1 && toupper([color characterAtIndex:0]) == toupper([color characterAtIndex:1])){
        color = [color substringToIndex:1];
    }
    return color;
}

+(NSString *) expandShorthandHexSingle: (NSString *) color{
    [self validateHexSingle:color];
    if (color.length == 1) {
        color = [NSString stringWithFormat:@"%@%@", color, color];
    }
    return color;
}

+(BOOL) isValidHex: (NSString *) color{
    return color != nil && [hexColorExpression numberOfMatchesInString:color options:0 range:NSMakeRange(0, color.length)] == 1;
}

+(void) validateHex: (NSString *) color{
    if(![self isValidHex:color]){
        [NSException raise:@"Invalid Hex" format:@"Hex color must be in format #RRGGBB, #RGB, #AARRGGBB, #ARGB, RRGGBB, RGB, AARRGGBB, or ARGB, invalid value: %@", color];
    }
}

+(BOOL) isValidHexSingle: (NSString *) color{
    return color != nil && [hexSingleColorExpression numberOfMatchesInString:color options:0 range:NSMakeRange(0, color.length)] == 1;
}

+(void) validateHexSingle: (NSString *) color{
    if(![self isValidHexSingle:color]){
        [NSException raise:@"Invalid Hex" format:@"Must be in format FF or F, invalid value: %@", color];
    }
}

+(BOOL) isValidRGB: (int) color{
    return color >= 0 && color <= 255;
}

+(void) validateRGB: (int) color{
    if (![self isValidRGB:color]){
        [NSException raise:@"Invalid RGB" format:@"Must be inclusively between 0 and 255, invalid value: %d", color];
    }
}

+(BOOL) isValidArithmeticRGB: (float) color{
    return color >= 0.0 && color <= 1.0;
}

+(void) validateArithmeticRGB: (float) color{
    if (![self isValidArithmeticRGB:color]){
        [NSException raise:@"Invalid Arithmetic RGB" format:@"Must be inclusively between 0.0 and 1.0, invalid value: %f", color];
    }
}

+(BOOL) isValidHue: (float) hue{
    return hue >= 0.0 && hue <= 360.0;
}

+(void) validateHue: (float) hue{
    if (![self isValidHue:hue]) {
        [NSException raise:@"Invalid Hue" format:@"Must be inclusively between 0.0 and 360.0, invalid value: %f", hue];
    }
}

+(BOOL) isValidSaturation: (float) saturation{
    return saturation >= 0.0 && saturation <= 1.0;
}

+(void) validateSaturation: (float) saturation{
    if (![self isValidSaturation:saturation]) {
        [NSException raise:@"Invalid Saturation" format:@"Must be inclusively between 0.0 and 1.0, invalid value: %f", saturation];
    }
}

+(BOOL) isValidLightness: (float) lightness{
    return lightness >= 0.0 && lightness <= 1.0;
}

+(void) validateLightness: (float) lightness{
    if (![self isValidLightness:lightness]) {
        [NSException raise:@"Invalid Lightness" format:@"Must be inclusively between 0.0 and 1.0, invalid value: %f", lightness];
    }
}

@end
