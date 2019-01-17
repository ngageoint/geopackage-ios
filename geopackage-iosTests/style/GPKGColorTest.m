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
#import "GPKGColorConstants.h"

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
    [self validateColor:color withInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    
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

    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_BLACK] withInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_BLUE] withInt:255 andHex:@"#0000FF" andHexShorthand:@"#00F" andRed:0 andGreen:0 andBlue:255 andHue:240.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_BROWN] withInt:10824234 andHex:@"#A52A2A" andHexShorthand:@"#A52A2A" andRed:165 andGreen:42 andBlue:42 andHue:0.0f andSaturation:0.59f andLightness:0.41f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_CYAN] withInt:65535 andHex:@"#00FFFF" andHexShorthand:@"#0FF" andRed:0 andGreen:255 andBlue:255 andHue:180.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_DKGRAY] withInt:4473924 andHex:@"#444444" andHexShorthand:@"#444" andRed:68 andGreen:68 andBlue:68 andHue:0.0f andSaturation:0.0f andLightness:0.27f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_GRAY] withInt:8947848 andHex:@"#888888" andHexShorthand:@"#888" andRed:136 andGreen:136 andBlue:136 andHue:0.0f andSaturation:0.0f andLightness:0.53f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_GREEN] withInt:65280 andHex:@"#00FF00" andHexShorthand:@"#0F0" andRed:0 andGreen:255 andBlue:0 andHue:120.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_LTGRAY] withInt:13421772 andHex:@"#CCCCCC" andHexShorthand:@"#CCC" andRed:204 andGreen:204 andBlue:204 andHue:0.0f andSaturation:0.0f andLightness:0.8f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_MAGENTA] withInt:16711935 andHex:@"#FF00FF" andHexShorthand:@"#F0F" andRed:255 andGreen:0 andBlue:255 andHue:300.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_ORANGE] withInt:16753920 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andRed:255 andGreen:165 andBlue:0 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_PINK] withInt:16761035 andHex:@"#FFC0CB" andHexShorthand:@"#FFC0CB" andRed:255 andGreen:192 andBlue:203 andHue:350.0f andSaturation:1.0f andLightness:0.88f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_PURPLE] withInt:8388736 andHex:@"#800080" andHexShorthand:@"#800080" andRed:128 andGreen:0 andBlue:128 andHue:300.0f andSaturation:1.0f andLightness:0.25f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_RED] withInt:16711680 andHex:@"#FF0000" andHexShorthand:@"#F00" andRed:255 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_VIOLET] withInt:15631086 andHex:@"#EE82EE" andHexShorthand:@"#EE82EE" andRed:238 andGreen:130 andBlue:238 andHue:300.0f andSaturation:0.76f andLightness:0.72f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_WHITE] withInt:16777215 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andRed:255 andGreen:255 andBlue:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_YELLOW] withInt:16776960 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andRed:255 andGreen:255 andBlue:0 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_BLACK andOpacity:0.5f] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andOpacity:0.5f andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_ORANGE andOpacity:0.25f] withInt:16753920 andUnsignedInt:16753920 andAlphaInt:1090495744 andAlphaUnsignedInt:1090495744 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andHexAlpha:@"#40FFA500" andHexShorthandAlpha:@"#40FFA500" andRed:255 andGreen:165 andBlue:0 andAlpha:64 andOpacity:0.25f andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_YELLOW andOpacity:0.85f] withInt:16776960 andUnsignedInt:16776960 andAlphaInt:-637534464 andAlphaUnsignedInt:3657432832 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andHexAlpha:@"#D9FFFF00" andHexShorthandAlpha:@"#D9FFFF00" andRed:255 andGreen:255 andBlue:0 andAlpha:217 andOpacity:0.85f andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithHex:@"#80000000"] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithHex:@"#40FFA500"] withInt:16753920 andUnsignedInt:16753920 andAlphaInt:1090495744 andAlphaUnsignedInt:1090495744 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andHexAlpha:@"#40FFA500" andHexShorthandAlpha:@"#40FFA500" andRed:255 andGreen:165 andBlue:0 andAlpha:64 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHex:@"#D9FFFF00"] withInt:16776960 andUnsignedInt:16776960 andAlphaInt:-637534464 andAlphaUnsignedInt:3657432832 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andHexAlpha:@"#D9FFFF00" andHexShorthandAlpha:@"#D9FFFF00" andRed:255 andGreen:255 andBlue:0 andAlpha:217 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
}

/**
 * Test color with integers
 */
- (void)testColorIntegers{

    [self validateColor:[[GPKGColor alloc] initWithColor:0] withInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:255] withInt:255 andHex:@"#0000FF" andHexShorthand:@"#00F" andRed:0 andGreen:0 andBlue:255 andHue:240.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:10824234] withInt:10824234 andHex:@"#A52A2A" andHexShorthand:@"#A52A2A" andRed:165 andGreen:42 andBlue:42 andHue:0.0f andSaturation:0.59f andLightness:0.41f];
    [self validateColor:[[GPKGColor alloc] initWithColor:65535] withInt:65535 andHex:@"#00FFFF" andHexShorthand:@"#0FF" andRed:0 andGreen:255 andBlue:255 andHue:180.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:4473924] withInt:4473924 andHex:@"#444444" andHexShorthand:@"#444" andRed:68 andGreen:68 andBlue:68 andHue:0.0f andSaturation:0.0f andLightness:0.27f];
    [self validateColor:[[GPKGColor alloc] initWithColor:8947848] withInt:8947848 andHex:@"#888888" andHexShorthand:@"#888" andRed:136 andGreen:136 andBlue:136 andHue:0.0f andSaturation:0.0f andLightness:0.53f];
    [self validateColor:[[GPKGColor alloc] initWithColor:65280] withInt:65280 andHex:@"#00FF00" andHexShorthand:@"#0F0" andRed:0 andGreen:255 andBlue:0 andHue:120.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:13421772] withInt:13421772 andHex:@"#CCCCCC" andHexShorthand:@"#CCC" andRed:204 andGreen:204 andBlue:204 andHue:0.0f andSaturation:0.0f andLightness:0.8f];
    [self validateColor:[[GPKGColor alloc] initWithColor:16711935] withInt:16711935 andHex:@"#FF00FF" andHexShorthand:@"#F0F" andRed:255 andGreen:0 andBlue:255 andHue:300.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:16753920] withInt:16753920 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andRed:255 andGreen:165 andBlue:0 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:16761035] withInt:16761035 andHex:@"#FFC0CB" andHexShorthand:@"#FFC0CB" andRed:255 andGreen:192 andBlue:203 andHue:350.0f andSaturation:1.0f andLightness:0.88f];
    [self validateColor:[[GPKGColor alloc] initWithColor:8388736] withInt:8388736 andHex:@"#800080" andHexShorthand:@"#800080" andRed:128 andGreen:0 andBlue:128 andHue:300.0f andSaturation:1.0f andLightness:0.25f];
    [self validateColor:[[GPKGColor alloc] initWithColor:16711680] withInt:16711680 andHex:@"#FF0000" andHexShorthand:@"#F00" andRed:255 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:15631086] withInt:15631086 andHex:@"#EE82EE" andHexShorthand:@"#EE82EE" andRed:238 andGreen:130 andBlue:238 andHue:300.0f andSaturation:0.76f andLightness:0.72f];
    [self validateColor:[[GPKGColor alloc] initWithColor:16777215] withInt:16777215 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andRed:255 andGreen:255 andBlue:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:16776960] withInt:16776960 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andRed:255 andGreen:255 andBlue:0 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
}

/**
 * Test color with single alpha based integers
 */
- (void)testColorAlphaIntegers{

    [self validateColor:[[GPKGColor alloc] initWithColor:-16777216] withInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-16776961] withInt:255 andHex:@"#0000FF" andHexShorthand:@"#00F" andRed:0 andGreen:0 andBlue:255 andHue:240.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-5952982] withInt:10824234 andHex:@"#A52A2A" andHexShorthand:@"#A52A2A" andRed:165 andGreen:42 andBlue:42 andHue:0.0f andSaturation:0.59f andLightness:0.41f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-16711681] withInt:65535 andHex:@"#00FFFF" andHexShorthand:@"#0FF" andRed:0 andGreen:255 andBlue:255 andHue:180.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-12303292] withInt:4473924 andHex:@"#444444" andHexShorthand:@"#444" andRed:68 andGreen:68 andBlue:68 andHue:0.0f andSaturation:0.0f andLightness:0.27f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-7829368] withInt:8947848 andHex:@"#888888" andHexShorthand:@"#888" andRed:136 andGreen:136 andBlue:136 andHue:0.0f andSaturation:0.0f andLightness:0.53f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-16711936] withInt:65280 andHex:@"#00FF00" andHexShorthand:@"#0F0" andRed:0 andGreen:255 andBlue:0 andHue:120.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-3355444] withInt:13421772 andHex:@"#CCCCCC" andHexShorthand:@"#CCC" andRed:204 andGreen:204 andBlue:204 andHue:0.0f andSaturation:0.0f andLightness:0.8f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-65281] withInt:16711935 andHex:@"#FF00FF" andHexShorthand:@"#F0F" andRed:255 andGreen:0 andBlue:255 andHue:300.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-23296] withInt:16753920 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andRed:255 andGreen:165 andBlue:0 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-16181] withInt:16761035 andHex:@"#FFC0CB" andHexShorthand:@"#FFC0CB" andRed:255 andGreen:192 andBlue:203 andHue:350.0f andSaturation:1.0f andLightness:0.88f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-8388480] withInt:8388736 andHex:@"#800080" andHexShorthand:@"#800080" andRed:128 andGreen:0 andBlue:128 andHue:300.0f andSaturation:1.0f andLightness:0.25f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-65536] withInt:16711680 andHex:@"#FF0000" andHexShorthand:@"#F00" andRed:255 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-1146130] withInt:15631086 andHex:@"#EE82EE" andHexShorthand:@"#EE82EE" andRed:238 andGreen:130 andBlue:238 andHue:300.0f andSaturation:0.76f andLightness:0.72f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-1] withInt:16777215 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andRed:255 andGreen:255 andBlue:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-256] withInt:16776960 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andRed:255 andGreen:255 andBlue:0 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithColor:16777216] withInt:0 andUnsignedInt:0 andAlphaInt:16777216 andAlphaUnsignedInt:16777216 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#01000000" andHexShorthandAlpha:@"#01000000" andRed:0 andGreen:0 andBlue:0 andAlpha:1 andOpacity:0.00392156862f andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:2147483647] withInt:16777215 andUnsignedInt:16777215 andAlphaInt:2147483647 andAlphaUnsignedInt:2147483647 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andHexAlpha:@"#7FFFFFFF" andHexShorthandAlpha:@"#7FFFFFFF" andRed:255 andGreen:255 andBlue:255 andAlpha:127 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-2147483648] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:-1] withInt:16777215 andUnsignedInt:16777215 andAlphaInt:-1 andAlphaUnsignedInt:4294967295 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andHexAlpha:@"#FFFFFFFF" andHexShorthandAlpha:@"#FFFF" andRed:255 andGreen:255 andBlue:255 andAlpha:255 andOpacity:1.0f andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    
}

/**
 * Test color with single alpha based unsigned integers
 */
- (void)testColorAlphaUnsignedIntegers{
    
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4278190080] withInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4278190335] withInt:255 andHex:@"#0000FF" andHexShorthand:@"#00F" andRed:0 andGreen:0 andBlue:255 andHue:240.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4289014314] withInt:10824234 andHex:@"#A52A2A" andHexShorthand:@"#A52A2A" andRed:165 andGreen:42 andBlue:42 andHue:0.0f andSaturation:0.59f andLightness:0.41f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4278255615] withInt:65535 andHex:@"#00FFFF" andHexShorthand:@"#0FF" andRed:0 andGreen:255 andBlue:255 andHue:180.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4282664004] withInt:4473924 andHex:@"#444444" andHexShorthand:@"#444" andRed:68 andGreen:68 andBlue:68 andHue:0.0f andSaturation:0.0f andLightness:0.27f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4287137928] withInt:8947848 andHex:@"#888888" andHexShorthand:@"#888" andRed:136 andGreen:136 andBlue:136 andHue:0.0f andSaturation:0.0f andLightness:0.53f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4278255360] withInt:65280 andHex:@"#00FF00" andHexShorthand:@"#0F0" andRed:0 andGreen:255 andBlue:0 andHue:120.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4291611852] withInt:13421772 andHex:@"#CCCCCC" andHexShorthand:@"#CCC" andRed:204 andGreen:204 andBlue:204 andHue:0.0f andSaturation:0.0f andLightness:0.8f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4294902015] withInt:16711935 andHex:@"#FF00FF" andHexShorthand:@"#F0F" andRed:255 andGreen:0 andBlue:255 andHue:300.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4294944000] withInt:16753920 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andRed:255 andGreen:165 andBlue:0 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4294951115] withInt:16761035 andHex:@"#FFC0CB" andHexShorthand:@"#FFC0CB" andRed:255 andGreen:192 andBlue:203 andHue:350.0f andSaturation:1.0f andLightness:0.88f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4286578816] withInt:8388736 andHex:@"#800080" andHexShorthand:@"#800080" andRed:128 andGreen:0 andBlue:128 andHue:300.0f andSaturation:1.0f andLightness:0.25f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4294901760] withInt:16711680 andHex:@"#FF0000" andHexShorthand:@"#F00" andRed:255 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4293821166] withInt:15631086 andHex:@"#EE82EE" andHexShorthand:@"#EE82EE" andRed:238 andGreen:130 andBlue:238 andHue:300.0f andSaturation:0.76f andLightness:0.72f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4294967295] withInt:16777215 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andRed:255 andGreen:255 andBlue:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4294967040] withInt:16776960 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andRed:255 andGreen:255 andBlue:0 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:16777216] withInt:0 andUnsignedInt:0 andAlphaInt:16777216 andAlphaUnsignedInt:16777216 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#01000000" andHexShorthandAlpha:@"#01000000" andRed:0 andGreen:0 andBlue:0 andAlpha:1 andOpacity:0.00392156862f andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:2147483647] withInt:16777215 andUnsignedInt:16777215 andAlphaInt:2147483647 andAlphaUnsignedInt:2147483647 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andHexAlpha:@"#7FFFFFFF" andHexShorthandAlpha:@"#7FFFFFFF" andRed:255 andGreen:255 andBlue:255 andAlpha:127 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:2147483648] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithUnsignedColor:4294967295] withInt:16777215 andUnsignedInt:16777215 andAlphaInt:-1 andAlphaUnsignedInt:4294967295 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andHexAlpha:@"#FFFFFFFF" andHexShorthandAlpha:@"#FFFF" andRed:255 andGreen:255 andBlue:255 andAlpha:255 andOpacity:1.0f andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    
}

/**
 * Test color hex integers
 */
- (void)testColorHexIntegers{

    [self validateColor:[[GPKGColor alloc] initWithColor:0x000000] withInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0x0000FF] withInt:255 andHex:@"#0000FF" andHexShorthand:@"#00F" andRed:0 andGreen:0 andBlue:255 andHue:240.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xA52A2A] withInt:10824234 andHex:@"#A52A2A" andHexShorthand:@"#A52A2A" andRed:165 andGreen:42 andBlue:42 andHue:0.0f andSaturation:0.59f andLightness:0.41f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0x00FFFF] withInt:65535 andHex:@"#00FFFF" andHexShorthand:@"#0FF" andRed:0 andGreen:255 andBlue:255 andHue:180.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0x444444] withInt:4473924 andHex:@"#444444" andHexShorthand:@"#444" andRed:68 andGreen:68 andBlue:68 andHue:0.0f andSaturation:0.0f andLightness:0.27f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0x888888] withInt:8947848 andHex:@"#888888" andHexShorthand:@"#888" andRed:136 andGreen:136 andBlue:136 andHue:0.0f andSaturation:0.0f andLightness:0.53f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0x00FF00] withInt:65280 andHex:@"#00FF00" andHexShorthand:@"#0F0" andRed:0 andGreen:255 andBlue:0 andHue:120.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xCCCCCC] withInt:13421772 andHex:@"#CCCCCC" andHexShorthand:@"#CCC" andRed:204 andGreen:204 andBlue:204 andHue:0.0f andSaturation:0.0f andLightness:0.8f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xFF00FF] withInt:16711935 andHex:@"#FF00FF" andHexShorthand:@"#F0F" andRed:255 andGreen:0 andBlue:255 andHue:300.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xFFA500] withInt:16753920 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andRed:255 andGreen:165 andBlue:0 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xFFC0CB] withInt:16761035 andHex:@"#FFC0CB" andHexShorthand:@"#FFC0CB" andRed:255 andGreen:192 andBlue:203 andHue:350.0f andSaturation:1.0f andLightness:0.88f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0x800080] withInt:8388736 andHex:@"#800080" andHexShorthand:@"#800080" andRed:128 andGreen:0 andBlue:128 andHue:300.0f andSaturation:1.0f andLightness:0.25f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xFF0000] withInt:16711680 andHex:@"#FF0000" andHexShorthand:@"#F00" andRed:255 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xEE82EE] withInt:15631086 andHex:@"#EE82EE" andHexShorthand:@"#EE82EE" andRed:238 andGreen:130 andBlue:238 andHue:300.0f andSaturation:0.76f andLightness:0.72f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xFFFFFF] withInt:16777215 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andRed:255 andGreen:255 andBlue:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xFFFF00] withInt:16776960 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andRed:255 andGreen:255 andBlue:0 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithColor:0x80000000] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0x40FFA500] withInt:16753920 andUnsignedInt:16753920 andAlphaInt:1090495744 andAlphaUnsignedInt:1090495744 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andHexAlpha:@"#40FFA500" andHexShorthandAlpha:@"#40FFA500" andRed:255 andGreen:165 andBlue:0 andAlpha:64 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xD9FFFF00] withInt:16776960 andUnsignedInt:16776960 andAlphaInt:-637534464 andAlphaUnsignedInt:3657432832 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andHexAlpha:@"#D9FFFF00" andHexShorthandAlpha:@"#D9FFFF00" andRed:255 andGreen:255 andBlue:0 andAlpha:217 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithColor:0x80000000] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0x40FFA500] withInt:16753920 andUnsignedInt:16753920 andAlphaInt:1090495744 andAlphaUnsignedInt:1090495744 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andHexAlpha:@"#40FFA500" andHexShorthandAlpha:@"#40FFA500" andRed:255 andGreen:165 andBlue:0 andAlpha:64 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithColor:0xD9FFFF00] withInt:16776960 andUnsignedInt:16776960 andAlphaInt:-637534464 andAlphaUnsignedInt:3657432832 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andHexAlpha:@"#D9FFFF00" andHexShorthandAlpha:@"#D9FFFF00" andRed:255 andGreen:255 andBlue:0 andAlpha:217 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
}

/**
 * Test color with RGB integer values
 */
- (void)testColorRGB{
    
    [self validateColor:[[GPKGColor alloc] initWithRed:0 andGreen:0 andBlue:0] withInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithRed:0 andGreen:0 andBlue:255] withInt:255 andHex:@"#0000FF" andHexShorthand:@"#00F" andRed:0 andGreen:0 andBlue:255 andHue:240.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithRed:165 andGreen:42 andBlue:42] withInt:10824234 andHex:@"#A52A2A" andHexShorthand:@"#A52A2A" andRed:165 andGreen:42 andBlue:42 andHue:0.0f andSaturation:0.59f andLightness:0.41f];
    [self validateColor:[[GPKGColor alloc] initWithRed:0 andGreen:255 andBlue:255] withInt:65535 andHex:@"#00FFFF" andHexShorthand:@"#0FF" andRed:0 andGreen:255 andBlue:255 andHue:180.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithRed:68 andGreen:68 andBlue:68] withInt:4473924 andHex:@"#444444" andHexShorthand:@"#444" andRed:68 andGreen:68 andBlue:68 andHue:0.0f andSaturation:0.0f andLightness:0.27f];
    [self validateColor:[[GPKGColor alloc] initWithRed:136 andGreen:136 andBlue:136] withInt:8947848 andHex:@"#888888" andHexShorthand:@"#888" andRed:136 andGreen:136 andBlue:136 andHue:0.0f andSaturation:0.0f andLightness:0.53f];
    [self validateColor:[[GPKGColor alloc] initWithRed:0 andGreen:255 andBlue:0] withInt:65280 andHex:@"#00FF00" andHexShorthand:@"#0F0" andRed:0 andGreen:255 andBlue:0 andHue:120.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithRed:204 andGreen:204 andBlue:204] withInt:13421772 andHex:@"#CCCCCC" andHexShorthand:@"#CCC" andRed:204 andGreen:204 andBlue:204 andHue:0.0f andSaturation:0.0f andLightness:0.8f];
    [self validateColor:[[GPKGColor alloc] initWithRed:255 andGreen:0 andBlue:255] withInt:16711935 andHex:@"#FF00FF" andHexShorthand:@"#F0F" andRed:255 andGreen:0 andBlue:255 andHue:300.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithRed:255 andGreen:165 andBlue:0] withInt:16753920 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andRed:255 andGreen:165 andBlue:0 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithRed:255 andGreen:192 andBlue:203] withInt:16761035 andHex:@"#FFC0CB" andHexShorthand:@"#FFC0CB" andRed:255 andGreen:192 andBlue:203 andHue:350.0f andSaturation:1.0f andLightness:0.88f];
    [self validateColor:[[GPKGColor alloc] initWithRed:128 andGreen:0 andBlue:128] withInt:8388736 andHex:@"#800080" andHexShorthand:@"#800080" andRed:128 andGreen:0 andBlue:128 andHue:300.0f andSaturation:1.0f andLightness:0.25f];
    [self validateColor:[[GPKGColor alloc] initWithRed:255 andGreen:0 andBlue:0] withInt:16711680 andHex:@"#FF0000" andHexShorthand:@"#F00" andRed:255 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithRed:238 andGreen:130 andBlue:238] withInt:15631086 andHex:@"#EE82EE" andHexShorthand:@"#EE82EE" andRed:238 andGreen:130 andBlue:238 andHue:300.0f andSaturation:0.76f andLightness:0.72f];
    [self validateColor:[[GPKGColor alloc] initWithRed:255 andGreen:255 andBlue:255] withInt:16777215 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andRed:255 andGreen:255 andBlue:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithRed:255 andGreen:255 andBlue:0] withInt:16776960 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andRed:255 andGreen:255 andBlue:0 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithRed:0 andGreen:0 andBlue:0 andAlpha:128] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithRed:255 andGreen:165 andBlue:0 andAlpha:64] withInt:16753920 andUnsignedInt:16753920 andAlphaInt:1090495744 andAlphaUnsignedInt:1090495744 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andHexAlpha:@"#40FFA500" andHexShorthandAlpha:@"#40FFA500" andRed:255 andGreen:165 andBlue:0 andAlpha:64 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithRed:255 andGreen:255 andBlue:0 andAlpha:217] withInt:16776960 andUnsignedInt:16776960 andAlphaInt:-637534464 andAlphaUnsignedInt:3657432832 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andHexAlpha:@"#D9FFFF00" andHexShorthandAlpha:@"#D9FFFF00" andRed:255 andGreen:255 andBlue:0 andAlpha:217 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithRed:0 andGreen:0 andBlue:0 andOpacity:0.5f] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andOpacity:0.5f andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithRed:255 andGreen:165 andBlue:0 andOpacity:0.25f] withInt:16753920 andUnsignedInt:16753920 andAlphaInt:1090495744 andAlphaUnsignedInt:1090495744 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andHexAlpha:@"#40FFA500" andHexShorthandAlpha:@"#40FFA500" andRed:255 andGreen:165 andBlue:0 andAlpha:64 andOpacity:0.25f andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithRed:255 andGreen:255 andBlue:0 andOpacity:0.85f] withInt:16776960 andUnsignedInt:16776960 andAlphaInt:-637534464 andAlphaUnsignedInt:3657432832 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andHexAlpha:@"#D9FFFF00" andHexShorthandAlpha:@"#D9FFFF00" andRed:255 andGreen:255 andBlue:0 andAlpha:217 andOpacity:0.85f andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
}

/**
 * Test color with arithmetic values
 */
- (void)testColorArithmetic{

    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.0f andGreen:0.0f andBlue:0.0f] withInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.0f andGreen:0.0f andBlue:1.0f] withInt:255 andHex:@"#0000FF" andHexShorthand:@"#00F" andRed:0 andGreen:0 andBlue:255 andHue:240.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.64705882352f andGreen:0.16470588235f andBlue:0.16470588235f] withInt:10824234 andHex:@"#A52A2A" andHexShorthand:@"#A52A2A" andRed:165 andGreen:42 andBlue:42 andHue:0.0f andSaturation:0.59f andLightness:0.41f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.0f andGreen:1.0f andBlue:1.0f] withInt:65535 andHex:@"#00FFFF" andHexShorthand:@"#0FF" andRed:0 andGreen:255 andBlue:255 andHue:180.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.26666666666f andGreen:0.26666666666f andBlue:0.26666666666f] withInt:4473924 andHex:@"#444444" andHexShorthand:@"#444" andRed:68 andGreen:68 andBlue:68 andHue:0.0f andSaturation:0.0f andLightness:0.27f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.53333333333f andGreen:0.53333333333f andBlue:0.53333333333f] withInt:8947848 andHex:@"#888888" andHexShorthand:@"#888" andRed:136 andGreen:136 andBlue:136 andHue:0.0f andSaturation:0.0f andLightness:0.53f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.0f andGreen:1.0f andBlue:0.0f] withInt:65280 andHex:@"#00FF00" andHexShorthand:@"#0F0" andRed:0 andGreen:255 andBlue:0 andHue:120.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.8f andGreen:0.8f andBlue:0.8f] withInt:13421772 andHex:@"#CCCCCC" andHexShorthand:@"#CCC" andRed:204 andGreen:204 andBlue:204 andHue:0.0f andSaturation:0.0f andLightness:0.8f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:1.0f andGreen:0.0f andBlue:1.0f] withInt:16711935 andHex:@"#FF00FF" andHexShorthand:@"#F0F" andRed:255 andGreen:0 andBlue:255 andHue:300.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:1.0f andGreen:0.64705882352f andBlue:0.0f] withInt:16753920 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andRed:255 andGreen:165 andBlue:0 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:1.0f andGreen:0.75294117647f andBlue:0.79607843137f] withInt:16761035 andHex:@"#FFC0CB" andHexShorthand:@"#FFC0CB" andRed:255 andGreen:192 andBlue:203 andHue:350.0f andSaturation:1.0f andLightness:0.88f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.50196078431f andGreen:0.0f andBlue:0.50196078431f] withInt:8388736 andHex:@"#800080" andHexShorthand:@"#800080" andRed:128 andGreen:0 andBlue:128 andHue:300.0f andSaturation:1.0f andLightness:0.25f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:1.0f andGreen:0.0f andBlue:0.0f] withInt:16711680 andHex:@"#FF0000" andHexShorthand:@"#F00" andRed:255 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.93333333333f andGreen:0.50980392156f andBlue:0.93333333333f] withInt:15631086 andHex:@"#EE82EE" andHexShorthand:@"#EE82EE" andRed:238 andGreen:130 andBlue:238 andHue:300.0f andSaturation:0.76f andLightness:0.72f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:1.0f andGreen:1.0f andBlue:1.0f] withInt:16777215 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andRed:255 andGreen:255 andBlue:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:1.0f andGreen:1.0f andBlue:0.0f] withInt:16776960 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andRed:255 andGreen:255 andBlue:0 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:0.0f andGreen:0.0f andBlue:0.0f andOpacity:0.50196078431f] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:1.0f andGreen:0.64705882352f andBlue:0.0f andOpacity:0.25098039215f] withInt:16753920 andUnsignedInt:16753920 andAlphaInt:1090495744 andAlphaUnsignedInt:1090495744 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andHexAlpha:@"#40FFA500" andHexShorthandAlpha:@"#40FFA500" andRed:255 andGreen:165 andBlue:0 andAlpha:64 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
   [self validateColor:[[GPKGColor alloc] initWithArithmeticRed:1.0f andGreen:1.0f andBlue:0.0f andOpacity:0.85098039215f] withInt:16776960 andUnsignedInt:16776960 andAlphaInt:-637534464 andAlphaUnsignedInt:3657432832 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andHexAlpha:@"#D9FFFF00" andHexShorthandAlpha:@"#D9FFFF00" andRed:255 andGreen:255 andBlue:0 andAlpha:217 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
}

/**
 * Test color with hex single color values
 */
- (void)testColorHexSingles{

    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"00" andGreen:@"00" andBlue:@"00"] withInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"00" andGreen:@"00" andBlue:@"FF"] withInt:255 andHex:@"#0000FF" andHexShorthand:@"#00F" andRed:0 andGreen:0 andBlue:255 andHue:240.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"a5" andGreen:@"2a" andBlue:@"2a"] withInt:10824234 andHex:@"#A52A2A" andHexShorthand:@"#A52A2A" andRed:165 andGreen:42 andBlue:42 andHue:0.0f andSaturation:0.59f andLightness:0.41f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"00" andGreen:@"FF" andBlue:@"ff"] withInt:65535 andHex:@"#00FFFF" andHexShorthand:@"#0FF" andRed:0 andGreen:255 andBlue:255 andHue:180.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"44" andGreen:@"4" andBlue:@"44"] withInt:4473924 andHex:@"#444444" andHexShorthand:@"#444" andRed:68 andGreen:68 andBlue:68 andHue:0.0f andSaturation:0.0f andLightness:0.27f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"8" andGreen:@"88" andBlue:@"8"] withInt:8947848 andHex:@"#888888" andHexShorthand:@"#888" andRed:136 andGreen:136 andBlue:136 andHue:0.0f andSaturation:0.0f andLightness:0.53f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"00" andGreen:@"ff" andBlue:@"00"] withInt:65280 andHex:@"#00FF00" andHexShorthand:@"#0F0" andRed:0 andGreen:255 andBlue:0 andHue:120.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"c" andGreen:@"C" andBlue:@"c"] withInt:13421772 andHex:@"#CCCCCC" andHexShorthand:@"#CCC" andRed:204 andGreen:204 andBlue:204 andHue:0.0f andSaturation:0.0f andLightness:0.8f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"fF" andGreen:@"00" andBlue:@"Ff"] withInt:16711935 andHex:@"#FF00FF" andHexShorthand:@"#F0F" andRed:255 andGreen:0 andBlue:255 andHue:300.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"F" andGreen:@"A5" andBlue:@"0"] withInt:16753920 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andRed:255 andGreen:165 andBlue:0 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"FF" andGreen:@"C0" andBlue:@"CB"] withInt:16761035 andHex:@"#FFC0CB" andHexShorthand:@"#FFC0CB" andRed:255 andGreen:192 andBlue:203 andHue:350.0f andSaturation:1.0f andLightness:0.88f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"80" andGreen:@"00" andBlue:@"80"] withInt:8388736 andHex:@"#800080" andHexShorthand:@"#800080" andRed:128 andGreen:0 andBlue:128 andHue:300.0f andSaturation:1.0f andLightness:0.25f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"ff" andGreen:@"00" andBlue:@"00"] withInt:16711680 andHex:@"#FF0000" andHexShorthand:@"#F00" andRed:255 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"ee" andGreen:@"82" andBlue:@"ee"] withInt:15631086 andHex:@"#EE82EE" andHexShorthand:@"#EE82EE" andRed:238 andGreen:130 andBlue:238 andHue:300.0f andSaturation:0.76f andLightness:0.72f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"FF" andGreen:@"FF" andBlue:@"FF"] withInt:16777215 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andRed:255 andGreen:255 andBlue:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"f" andGreen:@"f" andBlue:@"0"] withInt:16776960 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andRed:255 andGreen:255 andBlue:0 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"00" andGreen:@"00" andBlue:@"00" andAlpha:@"80"] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"f" andGreen:@"A5" andBlue:@"0" andAlpha:@"40"] withInt:16753920 andUnsignedInt:16753920 andAlphaInt:1090495744 andAlphaUnsignedInt:1090495744 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andHexAlpha:@"#40FFA500" andHexShorthandAlpha:@"#40FFA500" andRed:255 andGreen:165 andBlue:0 andAlpha:64 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"ff" andGreen:@"F" andBlue:@"00" andAlpha:@"D9"] withInt:16776960 andUnsignedInt:16776960 andAlphaInt:-637534464 andAlphaUnsignedInt:3657432832 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andHexAlpha:@"#D9FFFF00" andHexShorthandAlpha:@"#D9FFFF00" andRed:255 andGreen:255 andBlue:0 andAlpha:217 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"00" andGreen:@"00" andBlue:@"00" andOpacity:0.5f] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andOpacity:0.5f andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"ff" andGreen:@"a5" andBlue:@"00" andOpacity:0.25f] withInt:16753920 andUnsignedInt:16753920 andAlphaInt:1090495744 andAlphaUnsignedInt:1090495744 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andHexAlpha:@"#40FFA500" andHexShorthandAlpha:@"#40FFA500" andRed:255 andGreen:165 andBlue:0 andAlpha:64 andOpacity:0.25f andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHexRed:@"FF" andGreen:@"FF" andBlue:@"00" andOpacity:0.85f] withInt:16776960 andUnsignedInt:16776960 andAlphaInt:-637534464 andAlphaUnsignedInt:3657432832 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andHexAlpha:@"#D9FFFF00" andHexShorthandAlpha:@"#D9FFFF00" andRed:255 andGreen:255 andBlue:0 andAlpha:217 andOpacity:0.85f andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
}

/**
 * Test color with HSL values
 */
- (void)testColorHSL{

    [self validateColor:[[GPKGColor alloc] initWithHue:0.0f andSaturation:0.0f andLightness:0.0f] withInt:0 andHex:@"#000000" andHexShorthand:@"#000" andRed:0 andGreen:0 andBlue:0 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithHue:240.0f andSaturation:1.0f andLightness:0.5f] withInt:255 andHex:@"#0000FF" andHexShorthand:@"#00F" andRed:0 andGreen:0 andBlue:255 andHue:240.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHue:0.0f andSaturation:0.59420294f andLightness:0.40588236f] withInt:10824234 andHex:@"#A52A2A" andHexShorthand:@"#A52A2A" andRed:165 andGreen:42 andBlue:42 andHue:0.0f andSaturation:0.59f andLightness:0.41f];
    [self validateColor:[[GPKGColor alloc] initWithHue:180.0f andSaturation:1.0f andLightness:0.5f] withInt:65535 andHex:@"#00FFFF" andHexShorthand:@"#0FF" andRed:0 andGreen:255 andBlue:255 andHue:180.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHue:0.0f andSaturation:0.0f andLightness:0.26666668f] withInt:4473924 andHex:@"#444444" andHexShorthand:@"#444" andRed:68 andGreen:68 andBlue:68 andHue:0.0f andSaturation:0.0f andLightness:0.27f];
    [self validateColor:[[GPKGColor alloc] initWithHue:0.0f andSaturation:0.0f andLightness:0.53333336f] withInt:8947848 andHex:@"#888888" andHexShorthand:@"#888" andRed:136 andGreen:136 andBlue:136 andHue:0.0f andSaturation:0.0f andLightness:0.53f];
    [self validateColor:[[GPKGColor alloc] initWithHue:120.0f andSaturation:1.0f andLightness:0.5f] withInt:65280 andHex:@"#00FF00" andHexShorthand:@"#0F0" andRed:0 andGreen:255 andBlue:0 andHue:120.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHue:0.0f andSaturation:0.0f andLightness:0.8f] withInt:13421772 andHex:@"#CCCCCC" andHexShorthand:@"#CCC" andRed:204 andGreen:204 andBlue:204 andHue:0.0f andSaturation:0.0f andLightness:0.8f];
    [self validateColor:[[GPKGColor alloc] initWithHue:300.0f andSaturation:1.0f andLightness:0.5f] withInt:16711935 andHex:@"#FF00FF" andHexShorthand:@"#F0F" andRed:255 andGreen:0 andBlue:255 andHue:300.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHue:38.823532f andSaturation:1.0f andLightness:0.5f] withInt:16753920 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andRed:255 andGreen:165 andBlue:0 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHue:349.5238f andSaturation:1.0f andLightness:0.87647057f] withInt:16761035 andHex:@"#FFC0CB" andHexShorthand:@"#FFC0CB" andRed:255 andGreen:192 andBlue:203 andHue:350.0f andSaturation:1.0f andLightness:0.88f];
    [self validateColor:[[GPKGColor alloc] initWithHue:300.0f andSaturation:1.0f andLightness:0.2509804f] withInt:8388736 andHex:@"#800080" andHexShorthand:@"#800080" andRed:128 andGreen:0 andBlue:128 andHue:300.0f andSaturation:1.0f andLightness:0.25f];
    [self validateColor:[[GPKGColor alloc] initWithHue:0.0f andSaturation:1.0f andLightness:0.5f] withInt:16711680 andHex:@"#FF0000" andHexShorthand:@"#F00" andRed:255 andGreen:0 andBlue:0 andHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHue:300.0f andSaturation:0.76056343f andLightness:0.72156864f] withInt:15631086 andHex:@"#EE82EE" andHexShorthand:@"#EE82EE" andRed:238 andGreen:130 andBlue:238 andHue:300.0f andSaturation:0.76f andLightness:0.72f];
    [self validateColor:[[GPKGColor alloc] initWithHue:0.0f andSaturation:0.0f andLightness:1.0f] withInt:16777215 andHex:@"#FFFFFF" andHexShorthand:@"#FFF" andRed:255 andGreen:255 andBlue:255 andHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [self validateColor:[[GPKGColor alloc] initWithHue:60.0f andSaturation:1.0f andLightness:0.5f] withInt:16776960 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andRed:255 andGreen:255 andBlue:0 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
    [self validateColor:[[GPKGColor alloc] initWithHue:0.0f andSaturation:0.0f andLightness:0.0f andAlpha:0.50196078431f] withInt:0 andUnsignedInt:0 andAlphaInt:-2147483648 andAlphaUnsignedInt:2147483648 andHex:@"#000000" andHexShorthand:@"#000" andHexAlpha:@"#80000000" andHexShorthandAlpha:@"#80000000" andRed:0 andGreen:0 andBlue:0 andAlpha:128 andHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [self validateColor:[[GPKGColor alloc] initWithHue:38.823532f andSaturation:1.0f andLightness:0.5f andAlpha:0.25098039215f] withInt:16753920 andUnsignedInt:16753920 andAlphaInt:1090495744 andAlphaUnsignedInt:1090495744 andHex:@"#FFA500" andHexShorthand:@"#FFA500" andHexAlpha:@"#40FFA500" andHexShorthandAlpha:@"#40FFA500" andRed:255 andGreen:165 andBlue:0 andAlpha:64 andHue:39.0f andSaturation:1.0f andLightness:0.5f];
    [self validateColor:[[GPKGColor alloc] initWithHue:60.0f andSaturation:1.0f andLightness:0.5f andAlpha:0.85098039215f] withInt:16776960 andUnsignedInt:16776960 andAlphaInt:-637534464 andAlphaUnsignedInt:3657432832 andHex:@"#FFFF00" andHexShorthand:@"#FF0" andHexAlpha:@"#D9FFFF00" andHexShorthandAlpha:@"#D9FFFF00" andRed:255 andGreen:255 andBlue:0 andAlpha:217 andHue:60.0f andSaturation:1.0f andLightness:0.5f];
    
}

-(void) validateColor: (GPKGColor *) color withInt: (int) colorInt andHex: (NSString *) hex andHexShorthand: (NSString *) hexShorthand andRed: (int) red andGreen: (int) green andBlue: (int) blue andHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness{
    [self validateColor:color withInt:colorInt withUnsignedInt:colorInt andHex:hex andHexShorthand:hexShorthand andRed:red andGreen:green andBlue:blue andHue:hue andSaturation:saturation andLightness:lightness];
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
