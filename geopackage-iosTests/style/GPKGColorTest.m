//
//  GPKGColorTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 1/16/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GPKGTestUtils.h"
#import "GPKGColor.h"
#import "GPKGColorUtils.h"

@interface GPKGColorTest : XCTestCase

@end

/**
 * Color Test
 */
@implementation GPKGColorTest

/**
 * Test color creation and setters
 */
- (void)testColorCreation {

    GPKGColor *color = [[GPKGColor alloc] init];
    
    // Default color, opaque black
    [self validateColor:color withInt:0 withUnsignedInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    
    [color setRed:64];
    [self validateColor:color withInt:0x400000 withUnsignedInt:4194304 andHex:@"#400000" andHexShorthand:@"#400000" andRed:64 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.13f];
    [color setRedArithmetic:128 / 255.0f];
    [self validateColor:color withInt:0x800000 withUnsignedInt:8388608 andHex:@"#800000" andHexShorthand:@"#800000" andRed:128 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.25f];
    [color setRedHex:@"C0"];
    [self validateColor:color withInt:0xC00000 withUnsignedInt:12582912 andHex:@"#C00000" andHexShorthand:@"#C00000" andRed:192 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.38f];
    [color setRed:0xFF];
    [self validateColor:color withInt:0xFF0000 withUnsignedInt:16711680 andHex:@"#FF0000" andHexShorthand:@"#F00" andRed:255 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [GPKGTestUtils assertTrue:[color isOpaque]];
    
    [color setGreen:64];
    [self validateColor:color withInt:0xFF4000 withUnsignedInt:16728064 andHex:@"#FF4000" andHexShorthand:@"#FF4000" andRed:255 andGreen:64 andBlue:0 andHue:15.1f andSaturation:1.0f andLightness:0.5f];
    [color setGreenArithmetic:128 / 255.0f];
    [self validateColor:color withInt:0xFF8000 withUnsignedInt:16744448 andHex:@"#FF8000" andHexShorthand:@"#FF8000" andRed:255 andGreen:128 andBlue:0 andHue:30.1f andSaturation:1.0f andLightness:0.5f];
    [color setGreenHex:@"C0"];
    [self validateColor:color withInt:0xFFC000 withUnsignedInt:16760832 andHex:@"#FFC000" andHexShorthand:@"#FFC000" andRed:255 andGreen:192 andBlue:0 andHue:45.2f andSaturation:1.0f andLightness:0.5f];
    [color setGreen:0xFF];
    [self validateColor:color withInt:0xFFFF00 withUnsignedInt:16776960 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andRed:255 andGreen:255 andBlue:0 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    [GPKGTestUtils assertTrue:[color isOpaque]];
    
    [color setBlue:64];
    [self validateColor:color withInt:0xFFFF40 withUnsignedInt:16777024 andHex:@"#FFFF40" andHexShorthand:@"#FFFF40" andRed:255 andGreen:255 andBlue:64 andHue:60.0f andSaturation:1.0f andLightness:0.63f];
    [color setBlueArithmetic:128 / 255.0f];
    [self validateColor:color withInt:0xFFFF80 withUnsignedInt:16777088 andHex:@"#FFFF80" andHexShorthand:@"#FFFF80" andRed:255 andGreen:255 andBlue:128 andHue:60.0f andSaturation:1.0f andLightness:0.75f];
    [color setBlueHex:@"C0"];
    [self validateColor:color withInt:0xFFFFC0 withUnsignedInt:16777152 andHex:@"#FFFFC0" andHexShorthand:@"#FFFFC0" andRed:255 andGreen:255 andBlue:192 andHue:60.0f andSaturation:1.0f andLightness:0.88f];
    [color setBlue:0xFF];
    [self validateColor:color withInt:0xFFFFFF withUnsignedInt:16777215 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andRed:255 andGreen:255 andBlue:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [GPKGTestUtils assertTrue:[color isOpaque]];
    
    [color setAlpha:64];
    [self validateColor:color withInt:0xFFFFFF andUnsignedInt:16777215 andAlphaInt:0x40FFFFFF andAlphaUnsignedInt:1090519039 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andHexAlpha:@"#40FFFFFF" andHexShorthandAlpha:@"#40FFFFFF" andRed:255 andGreen:255 andBlue:255 andAlpha:64 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [GPKGTestUtils assertFalse:[color isOpaque]];
    [color setOpacity:0.5f];
    [self validateColor:color withInt:0xFFFFFF andUnsignedInt:16777215 andAlphaInt:0x80FFFFFF andAlphaUnsignedInt:2164260863 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andHexAlpha:@"#80FFFFFF" andHexShorthandAlpha:@"#80FFFFFF" andRed:255 andGreen:255 andBlue:255 andAlpha:128 andOpacity:0.5f andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [GPKGTestUtils assertFalse:[color isOpaque]];
    [color setAlphaHex:@"C0"];
    [self validateColor:color withInt:0xFFFFFF andUnsignedInt:16777215 andAlphaInt:0xC0FFFFFF andAlphaUnsignedInt:3238002687 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andHexAlpha:@"#C0FFFFFF" andHexShorthandAlpha:@"#C0FFFFFF" andRed:255 andGreen:255 andBlue:255 andAlpha:192 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [GPKGTestUtils assertFalse:[color isOpaque]];
    [color setAlpha:0xFF];
    [self validateColor:color withInt:0xFFFFFF andUnsignedInt:16777215 andAlphaInt:0xFFFFFFFF andAlphaUnsignedInt:4294967295 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andHexAlpha:@"#FFFFFFFF" andHexShorthandAlpha:@"#FFFF" andRed:255 andGreen:255 andBlue:255 andAlpha:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [GPKGTestUtils assertTrue:[color isOpaque]];
    
}

/**
 * Test color hex constants
 */
- (void)testColorHexConstants{
    //TODO
}

/**
 * Test color with integers
 */
- (void)testColorIntegers{
    //TODO
}

/**
 * Test color with single alpha based integers
 */
- (void)testColorAlphaIntegers{
    //TODO
}

/**
 * Test color hex integers
 */
- (void)testColorHexIntegers{
    //TODO
}

/**
 * Test color with RGB integer values
 */
- (void)testColorRGB{
    //TODO
}

/**
 * Test color with arithmetic values
 */
- (void)testColorArithmetic{
    //TODO
}

/**
 * Test color with hex single color values
 */
- (void)testColorHexSingles{
    //TODO
}

/**
 * Test color with HSL values
 */
- (void)testColorHSL{
    //TODO
}

-(void) validateColor: (GPKGColor *) color withInt: (int) colorInt withUnsignedInt: (unsigned int) colorUnsignedInt andHex: (NSString *) hex andHexShorthand: (NSString *) hexShorthand andRed: (int) red andGreen: (int) green andBlue: (int) blue andHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness{
    
    NSString *hexAlpha = [NSString stringWithFormat:@"#FF%@", [hex substringFromIndex:1]];
    NSString *hexShorthandAlpha = nil;
    if(hexShorthand.length <= 4){
        hexShorthandAlpha = [NSString stringWithFormat:@"#F%@", [hexShorthand substringFromIndex:1]];
    }else{
        hexShorthandAlpha = [NSString stringWithFormat:@"#FF%@", [hexShorthand substringFromIndex:1]];
    }
    int alpha = 255;
    double opacity = 1.0f;
    int colorAlphaInt = (alpha & 0xff) << 24 | colorInt;
    unsigned int colorAlphaUnsignedInt = colorAlphaInt;
    
    [self validateColor:color withInt:colorInt andUnsignedInt:colorUnsignedInt andAlphaInt:colorAlphaInt andAlphaUnsignedInt:colorAlphaUnsignedInt andHex:hex andHexShorthand:hexShorthand andHexAlpha:hexAlpha andHexShorthandAlpha:hexShorthandAlpha andRed:red andGreen:green andBlue:blue andAlpha:alpha andOpacity:opacity andHue:hue andSaturation:saturation andLightness:lightness];
}

-(void) validateColor: (GPKGColor *) color withInt: (int) colorInt andUnsignedInt: (unsigned int) colorUnsignedInt andAlphaInt: (int) colorAlphaInt andAlphaUnsignedInt: (unsigned int) colorAlphaUnsignedInt andHex: (NSString *) hex andHexShorthand: (NSString *) hexShorthand andHexAlpha: (NSString *) hexAlpha andHexShorthandAlpha: (NSString *) hexShorthandAlpha andRed: (int) red andGreen: (int) green andBlue: (int) blue andAlpha: (int) alpha andHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness{
    [self validateColor:color withInt:colorInt andUnsignedInt:colorUnsignedInt andAlphaInt:colorAlphaInt andAlphaUnsignedInt:colorAlphaUnsignedInt andHex:hex andHexShorthand:hexShorthand andHexAlpha:hexAlpha andHexShorthandAlpha:hexShorthandAlpha andRed:red andGreen:green andBlue:blue andAlpha:alpha andOpacity:alpha / 255.0f andHue:hue andSaturation:saturation andLightness:lightness];
}

-(void) validateColor: (GPKGColor *) color withInt: (int) colorInt andUnsignedInt: (unsigned int) colorUnsignedInt andAlphaInt: (int) colorAlphaInt andAlphaUnsignedInt: (unsigned int) colorAlphaUnsignedInt andHex: (NSString *) hex andHexShorthand: (NSString *) hexShorthand andHexAlpha: (NSString *) hexAlpha andHexShorthandAlpha: (NSString *) hexShorthandAlpha andRed: (int) red andGreen: (int) green andBlue: (int) blue andAlpha: (int) alpha andOpacity: (double) opacity andHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness{
    
    [GPKGTestUtils assertEqualWithValue:hex andValue2:[color colorHex]];
    [GPKGTestUtils assertEqualWithValue:hexShorthand andValue2:[color colorHexShorthand]];
    [GPKGTestUtils assertEqualWithValue:hexAlpha andValue2:[color colorHexWithAlpha]];
    [GPKGTestUtils assertEqualWithValue:hexShorthandAlpha andValue2:[color colorHexShorthandWithAlpha]];
    
    [GPKGTestUtils assertEqualIntWithValue:colorInt andValue2:[color color]];
    [GPKGTestUtils assertEqualIntWithValue:colorUnsignedInt andValue2:[color unsignedColor]];
    [GPKGTestUtils assertEqualIntWithValue:colorAlphaInt andValue2:[color colorWithAlpha]];
    [GPKGTestUtils assertEqualIntWithValue:colorAlphaUnsignedInt andValue2:[color unsignedColorWithAlpha]];
    
    [GPKGTestUtils assertEqualIntWithValue:red andValue2:[color red]];
    [GPKGTestUtils assertEqualDoubleWithValue:red / 255.0f andValue2:[color redArithmetic] andDelta:0.0000001f];
    NSString *redHex = [hex substringWithRange:NSMakeRange(1, 2)];
    [GPKGTestUtils assertEqualWithValue:redHex andValue2:[color redHex]];
    [GPKGTestUtils assertEqualWithValue:[GPKGColorUtils shorthandHexSingle:redHex] andValue2:[color redHexShorthand]];
    
    [GPKGTestUtils assertEqualIntWithValue:green andValue2:[color green]];
    [GPKGTestUtils assertEqualDoubleWithValue:green / 255.0f andValue2:[color greenArithmetic] andDelta:0.0000001f];
    NSString *greenHex = [hex substringWithRange:NSMakeRange(3, 2)];
    [GPKGTestUtils assertEqualWithValue:greenHex andValue2:[color greenHex]];
    [GPKGTestUtils assertEqualWithValue:[GPKGColorUtils shorthandHexSingle:greenHex] andValue2:[color greenHexShorthand]];
    
    [GPKGTestUtils assertEqualIntWithValue:blue andValue2:[color blue]];
    [GPKGTestUtils assertEqualDoubleWithValue:blue / 255.0f andValue2:[color blueArithmetic] andDelta:0.0000001f];
    NSString *blueHex = [hex substringWithRange:NSMakeRange(5, 2)];
    [GPKGTestUtils assertEqualWithValue:blueHex andValue2:[color blueHex]];
    [GPKGTestUtils assertEqualWithValue:[GPKGColorUtils shorthandHexSingle:blueHex] andValue2:[color blueHexShorthand]];

    [GPKGTestUtils assertEqualDoubleWithValue:opacity andValue2:[color opacity] andDelta:0.0000001f];
    [GPKGTestUtils assertEqualIntWithValue:alpha andValue2:[color alpha]];
    [GPKGTestUtils assertEqualDoubleWithValue:opacity andValue2:[color alphaArithmetic] andDelta:0.0000001f];
    NSString *alphaHex = [hexAlpha substringWithRange:NSMakeRange(1, 2)];
    [GPKGTestUtils assertEqualWithValue:alphaHex andValue2:[color alphaHex]];
    [GPKGTestUtils assertEqualWithValue:[GPKGColorUtils shorthandHexSingle:alphaHex] andValue2:[color alphaHexShorthand]];
    
    float *hsl = [color hsl];
    [GPKGTestUtils assertEqualDoubleWithValue:hue andValue2:hsl[0] andDelta:0.5f];
    [GPKGTestUtils assertEqualDoubleWithValue:saturation andValue2:hsl[1] andDelta:0.01f];
    [GPKGTestUtils assertEqualDoubleWithValue:lightness andValue2:hsl[2] andDelta:0.01f];
    [GPKGTestUtils assertEqualDoubleWithValue:hue andValue2:[color hue] andDelta:0.5f];
    [GPKGTestUtils assertEqualDoubleWithValue:saturation andValue2:[color saturation] andDelta:0.01f];
    [GPKGTestUtils assertEqualDoubleWithValue:lightness andValue2:[color lightness] andDelta:0.01f];
    
}


@end
