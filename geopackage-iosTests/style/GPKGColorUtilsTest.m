//
//  GPKGColorUtilsTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 1/16/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GPKGTestUtils.h"
#import "GPKGColorUtils.h"

@interface GPKGColorUtilsTest : XCTestCase

@end

@implementation GPKGColorUtilsTest

/**
 * Test color valid checks
 */
- (void)testValid {

    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"000000"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"#000000"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"00000000"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"#00000000"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"000"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"#000"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"0000"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"#0000"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"FFFFFF"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"#FFFFFF"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"FFFFFFFF"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"#ffffffff"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"FfF"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"#fFf"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"ffff"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHex:@"#fFfF"]];
    
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:nil]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@""]];
   
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"00000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"0000000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#00000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#0000000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"000000000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#000000000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"00"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#00"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"FFFFF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"FFFFFFF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#FFFFF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#FFFFFFF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"FFFFFFFFF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#FFFFFFFFF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"FF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#FF"]];
  
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"G00000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#00000H"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"000i0000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#0000J000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"00K"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#0l0"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"0M00"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#n000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"FFGFFF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#FFFHFF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"iFFFFFFF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#FFFFFFFj"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"FFK"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#LFF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"FFmF"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHex:@"#FnFF"]];
    
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHexSingle:@"00"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHexSingle:@"FF"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHexSingle:@"ff"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHexSingle:@"aB"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHexSingle:@"C5"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHexSingle:@"d"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHexSingle:@"E"]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHexSingle:@"4"]];
    
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHexSingle:nil]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHexSingle:@""]];
    
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHexSingle:@"000"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHexSingle:@"0ff"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHexSingle:@"G0"]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHexSingle:@"#00"]];
    
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidRGB:-1]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidRGB:0]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidRGB:128]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidRGB:255]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidRGB:256]];
    
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidArithmeticRGB:0.0f - .0000001f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidArithmeticRGB:0.0f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidArithmeticRGB:0.5f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidArithmeticRGB:1.0f]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidArithmeticRGB:1.0f + .0000001f]];
    
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHue:-0.0001f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHue:0.0f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHue:180.0f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidHue:360.0f]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidHue:360.0001f]];
    
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidSaturation:-0.0001f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidSaturation:0.0f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidSaturation:0.5f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidSaturation:1.0f]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidSaturation:1.0001f]];
    
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidLightness:-0.0001f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidLightness:0.0f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidLightness:0.5f]];
    [GPKGTestUtils assertTrue:[GPKGColorUtils isValidLightness:1.0f]];
    [GPKGTestUtils assertFalse:[GPKGColorUtils isValidLightness:1.0001f]];

}

/**
 * Test color utilities
 */
- (void)testUtils {
    
    [GPKGTestUtils assertEqualDoubleWithValue:0.37254903 andValue2:[GPKGColorUtils toArithmeticRGBFromRGB:95] andDelta:0.0000001];
    [GPKGTestUtils assertEqualIntWithValue:95 andValue2:[GPKGColorUtils toRGBFromArithmeticRGB:[GPKGColorUtils toArithmeticRGBFromRGB:95]]];
    [GPKGTestUtils assertEqualIntWithValue:95 andValue2:[GPKGColorUtils toRGBFromHex:@"5F"]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.37254903 andValue2:[GPKGColorUtils toArithmeticRGBFromHex:@"5F"] andDelta:0.0000001];
    
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils toRGBFromHex:@"00"]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.0 andValue2:[GPKGColorUtils toArithmeticRGBFromHex:@"00"] andDelta:0.0];
    [GPKGTestUtils assertEqualIntWithValue:128 andValue2:[GPKGColorUtils toRGBFromHex:@"80"]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.5019608 andValue2:[GPKGColorUtils toArithmeticRGBFromHex:@"80"] andDelta:0.0000001];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils toRGBFromHex:@"FF"]];
    [GPKGTestUtils assertEqualDoubleWithValue:1.0 andValue2:[GPKGColorUtils toArithmeticRGBFromHex:@"FF"] andDelta:0.0];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils toRGBFromHex:@"ff"]];
    [GPKGTestUtils assertEqualDoubleWithValue:1.0 andValue2:[GPKGColorUtils toArithmeticRGBFromHex:@"ff"] andDelta:0.0];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils toRGBFromHex:@"f"]];
    [GPKGTestUtils assertEqualDoubleWithValue:1.0 andValue2:[GPKGColorUtils toArithmeticRGBFromHex:@"f"] andDelta:0.0];

    [GPKGTestUtils assertEqualWithValue:@"00" andValue2:[GPKGColorUtils toHexFromRGB:0]];
    [GPKGTestUtils assertEqualWithValue:@"00" andValue2:[GPKGColorUtils toHexFromArithmeticRGB:0.0f]];
    [GPKGTestUtils assertEqualWithValue:@"06" andValue2:[GPKGColorUtils toHexFromRGB:6]];
    [GPKGTestUtils assertEqualWithValue:@"06" andValue2:[GPKGColorUtils toHexFromArithmeticRGB:0.02352941176f]];
    [GPKGTestUtils assertEqualWithValue:@"80" andValue2:[GPKGColorUtils toHexFromRGB:128]];
    [GPKGTestUtils assertEqualWithValue:@"80" andValue2:[GPKGColorUtils toHexFromArithmeticRGB:0.5f]];
    [GPKGTestUtils assertEqualWithValue:@"FF" andValue2:[GPKGColorUtils toHexFromRGB:255]];
    [GPKGTestUtils assertEqualWithValue:@"FF" andValue2:[GPKGColorUtils toHexFromArithmeticRGB:1.0f]];
    
    [GPKGTestUtils assertEqualWithValue:@"A1" andValue2:[GPKGColorUtils redHexFromHex:@"A1B2C3"]];
    [GPKGTestUtils assertEqualWithValue:@"b2" andValue2:[GPKGColorUtils greenHexFromHex:@"a1b2c3"]];
    [GPKGTestUtils assertEqualWithValue:@"C3" andValue2:[GPKGColorUtils blueHexFromHex:@"a1b2C3"]];
    [GPKGTestUtils assertNil:[GPKGColorUtils alphaHexFromHex:@"A1B2C3"]];
    [GPKGTestUtils assertEqualWithValue:@"A1" andValue2:[GPKGColorUtils redHexFromHex:@"D4A1B2C3"]];
    [GPKGTestUtils assertEqualWithValue:@"b2" andValue2:[GPKGColorUtils greenHexFromHex:@"d4a1b2c3"]];
    [GPKGTestUtils assertEqualWithValue:@"C3" andValue2:[GPKGColorUtils blueHexFromHex:@"d4a1b2C3"]];
    [GPKGTestUtils assertEqualWithValue:@"Dd" andValue2:[GPKGColorUtils alphaHexFromHex:@"DdA1B2C3"]];
    
    [GPKGTestUtils assertEqualWithValue:@"A1" andValue2:[GPKGColorUtils redHexFromHex:@"#A1B2C3"]];
    [GPKGTestUtils assertEqualWithValue:@"b2" andValue2:[GPKGColorUtils greenHexFromHex:@"#a1b2c3"]];
    [GPKGTestUtils assertEqualWithValue:@"C3" andValue2:[GPKGColorUtils blueHexFromHex:@"#a1b2C3"]];
    [GPKGTestUtils assertNil:[GPKGColorUtils alphaHexFromHex:@"#A1B2C3"]];
    [GPKGTestUtils assertEqualWithValue:@"A1" andValue2:[GPKGColorUtils redHexFromHex:@"#D4A1B2C3"]];
    [GPKGTestUtils assertEqualWithValue:@"b2" andValue2:[GPKGColorUtils greenHexFromHex:@"#d4a1b2c3"]];
    [GPKGTestUtils assertEqualWithValue:@"C3" andValue2:[GPKGColorUtils blueHexFromHex:@"#d4a1b2C3"]];
    [GPKGTestUtils assertEqualWithValue:@"dD" andValue2:[GPKGColorUtils alphaHexFromHex:@"#dDA1B2C3"]];
    
    [GPKGTestUtils assertEqualWithValue:@"AA" andValue2:[GPKGColorUtils redHexFromHex:@"ABC"]];
    [GPKGTestUtils assertEqualWithValue:@"bb" andValue2:[GPKGColorUtils greenHexFromHex:@"abc"]];
    [GPKGTestUtils assertEqualWithValue:@"CC" andValue2:[GPKGColorUtils blueHexFromHex:@"abC"]];
    [GPKGTestUtils assertNil:[GPKGColorUtils alphaHexFromHex:@"ABC"]];
    [GPKGTestUtils assertEqualWithValue:@"AA" andValue2:[GPKGColorUtils redHexFromHex:@"DABC"]];
    [GPKGTestUtils assertEqualWithValue:@"bb" andValue2:[GPKGColorUtils greenHexFromHex:@"dabc"]];
    [GPKGTestUtils assertEqualWithValue:@"CC" andValue2:[GPKGColorUtils blueHexFromHex:@"dabC"]];
    [GPKGTestUtils assertEqualWithValue:@"DD" andValue2:[GPKGColorUtils alphaHexFromHex:@"DABC"]];
    
    [GPKGTestUtils assertEqualWithValue:@"AA" andValue2:[GPKGColorUtils redHexFromHex:@"#ABC"]];
    [GPKGTestUtils assertEqualWithValue:@"bb" andValue2:[GPKGColorUtils greenHexFromHex:@"#abc"]];
    [GPKGTestUtils assertEqualWithValue:@"CC" andValue2:[GPKGColorUtils blueHexFromHex:@"#abC"]];
    [GPKGTestUtils assertNil:[GPKGColorUtils alphaHexFromHex:@"#ABC"]];
    [GPKGTestUtils assertEqualWithValue:@"AA" andValue2:[GPKGColorUtils redHexFromHex:@"#DABC"]];
    [GPKGTestUtils assertEqualWithValue:@"bb" andValue2:[GPKGColorUtils greenHexFromHex:@"#dabc"]];
    [GPKGTestUtils assertEqualWithValue:@"CC" andValue2:[GPKGColorUtils blueHexFromHex:@"#dabC"]];
    [GPKGTestUtils assertEqualWithValue:@"DD" andValue2:[GPKGColorUtils alphaHexFromHex:@"#DABC"]];
    
    [GPKGTestUtils assertEqualWithValue:@"01" andValue2:[GPKGColorUtils redHexFromHex:@"010203"]];
    [GPKGTestUtils assertEqualWithValue:@"02" andValue2:[GPKGColorUtils greenHexFromHex:@"010203"]];
    [GPKGTestUtils assertEqualWithValue:@"03" andValue2:[GPKGColorUtils blueHexFromHex:@"010203"]];
    [GPKGTestUtils assertNil:[GPKGColorUtils alphaHexFromHex:@"010203"]];
    [GPKGTestUtils assertEqualWithValue:@"01" andValue2:[GPKGColorUtils redHexFromHex:@"04010203"]];
    [GPKGTestUtils assertEqualWithValue:@"02" andValue2:[GPKGColorUtils greenHexFromHex:@"04010203"]];
    [GPKGTestUtils assertEqualWithValue:@"03" andValue2:[GPKGColorUtils blueHexFromHex:@"04010203"]];
    [GPKGTestUtils assertEqualWithValue:@"04" andValue2:[GPKGColorUtils alphaHexFromHex:@"04010203"]];
    
    [GPKGTestUtils assertEqualWithValue:@"01" andValue2:[GPKGColorUtils redHexFromHex:@"#010203"]];
    [GPKGTestUtils assertEqualWithValue:@"02" andValue2:[GPKGColorUtils greenHexFromHex:@"#010203"]];
    [GPKGTestUtils assertEqualWithValue:@"03" andValue2:[GPKGColorUtils blueHexFromHex:@"#010203"]];
    [GPKGTestUtils assertNil:[GPKGColorUtils alphaHexFromHex:@"#010203"]];
    [GPKGTestUtils assertEqualWithValue:@"01" andValue2:[GPKGColorUtils redHexFromHex:@"#04010203"]];
    [GPKGTestUtils assertEqualWithValue:@"02" andValue2:[GPKGColorUtils greenHexFromHex:@"#04010203"]];
    [GPKGTestUtils assertEqualWithValue:@"03" andValue2:[GPKGColorUtils blueHexFromHex:@"#04010203"]];
    [GPKGTestUtils assertEqualWithValue:@"04" andValue2:[GPKGColorUtils alphaHexFromHex:@"#04010203"]];
    
    [GPKGTestUtils assertEqualWithValue:@"11" andValue2:[GPKGColorUtils redHexFromHex:@"123"]];
    [GPKGTestUtils assertEqualWithValue:@"22" andValue2:[GPKGColorUtils greenHexFromHex:@"123"]];
    [GPKGTestUtils assertEqualWithValue:@"33" andValue2:[GPKGColorUtils blueHexFromHex:@"123"]];
    [GPKGTestUtils assertNil:[GPKGColorUtils alphaHexFromHex:@"123"]];
    [GPKGTestUtils assertEqualWithValue:@"11" andValue2:[GPKGColorUtils redHexFromHex:@"4123"]];
    [GPKGTestUtils assertEqualWithValue:@"22" andValue2:[GPKGColorUtils greenHexFromHex:@"4123"]];
    [GPKGTestUtils assertEqualWithValue:@"33" andValue2:[GPKGColorUtils blueHexFromHex:@"4123"]];
    [GPKGTestUtils assertEqualWithValue:@"44" andValue2:[GPKGColorUtils alphaHexFromHex:@"4123"]];
    
    [GPKGTestUtils assertEqualWithValue:@"11" andValue2:[GPKGColorUtils redHexFromHex:@"#123"]];
    [GPKGTestUtils assertEqualWithValue:@"22" andValue2:[GPKGColorUtils greenHexFromHex:@"#123"]];
    [GPKGTestUtils assertEqualWithValue:@"33" andValue2:[GPKGColorUtils blueHexFromHex:@"#123"]];
    [GPKGTestUtils assertNil:[GPKGColorUtils alphaHexFromHex:@"#123"]];
    [GPKGTestUtils assertEqualWithValue:@"11" andValue2:[GPKGColorUtils redHexFromHex:@"#4123"]];
    [GPKGTestUtils assertEqualWithValue:@"22" andValue2:[GPKGColorUtils greenHexFromHex:@"#4123"]];
    [GPKGTestUtils assertEqualWithValue:@"33" andValue2:[GPKGColorUtils blueHexFromHex:@"#4123"]];
    [GPKGTestUtils assertEqualWithValue:@"44" andValue2:[GPKGColorUtils alphaHexFromHex:@"#4123"]];
    
    [GPKGTestUtils assertEqualWithValue:@"11" andValue2:[GPKGColorUtils redHexFromHex:@"112233"]];
    [GPKGTestUtils assertEqualWithValue:@"22" andValue2:[GPKGColorUtils greenHexFromHex:@"112233"]];
    [GPKGTestUtils assertEqualWithValue:@"33" andValue2:[GPKGColorUtils blueHexFromHex:@"112233"]];
    [GPKGTestUtils assertNil:[GPKGColorUtils alphaHexFromHex:@"112233"]];
    [GPKGTestUtils assertEqualWithValue:@"11" andValue2:[GPKGColorUtils redHexFromHex:@"44112233"]];
    [GPKGTestUtils assertEqualWithValue:@"22" andValue2:[GPKGColorUtils greenHexFromHex:@"44112233"]];
    [GPKGTestUtils assertEqualWithValue:@"33" andValue2:[GPKGColorUtils blueHexFromHex:@"44112233"]];
    [GPKGTestUtils assertEqualWithValue:@"44" andValue2:[GPKGColorUtils alphaHexFromHex:@"44112233"]];
    
    [GPKGTestUtils assertEqualWithValue:@"11" andValue2:[GPKGColorUtils redHexFromHex:@"#112233"]];
    [GPKGTestUtils assertEqualWithValue:@"22" andValue2:[GPKGColorUtils greenHexFromHex:@"#112233"]];
    [GPKGTestUtils assertEqualWithValue:@"33" andValue2:[GPKGColorUtils blueHexFromHex:@"#112233"]];
    [GPKGTestUtils assertNil:[GPKGColorUtils alphaHexFromHex:@"#112233"]];
    [GPKGTestUtils assertEqualWithValue:@"11" andValue2:[GPKGColorUtils redHexFromHex:@"#44112233"]];
    [GPKGTestUtils assertEqualWithValue:@"22" andValue2:[GPKGColorUtils greenHexFromHex:@"#44112233"]];
    [GPKGTestUtils assertEqualWithValue:@"33" andValue2:[GPKGColorUtils blueHexFromHex:@"#44112233"]];
    [GPKGTestUtils assertEqualWithValue:@"44" andValue2:[GPKGColorUtils alphaHexFromHex:@"#44112233"]];
    
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils redFromColor:-16711936]];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils greenFromColor:-16711936]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils blueFromColor:-16711936]];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils alphaFromColor:-16711936]];
    
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils redFromColor:0xFF00FF00]];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils greenFromColor:0xff00ff00]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils blueFromColor:0xFF00FF00]];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils alphaFromColor:0xff00ff00]];
    
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils redFromUnsignedColor:4278255360]];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils greenFromUnsignedColor:4278255360]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils blueFromUnsignedColor:4278255360]];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils alphaFromUnsignedColor:4278255360]];
    
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils redFromColor:65280]];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils greenFromColor:65280]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils blueFromColor:65280]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils alphaFromColor:65280]];
    
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils redFromColor:0x00FF00]];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils greenFromColor:0x00ff00]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils blueFromColor:0x00FF00]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils alphaFromColor:0x00ff00]];
    
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils redFromUnsignedColor:65280]];
    [GPKGTestUtils assertEqualIntWithValue:255 andValue2:[GPKGColorUtils greenFromUnsignedColor:65280]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils blueFromUnsignedColor:65280]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[GPKGColorUtils alphaFromUnsignedColor:65280]];
    
    [GPKGTestUtils assertEqualIntWithValue:65280 andValue2:[GPKGColorUtils toColorFromRed:[GPKGColorUtils toRGBFromHex:@"00"] andGreen:[GPKGColorUtils toRGBFromHex:@"FF"] andBlue:[GPKGColorUtils toRGBFromHex:@"00"]]];
    [GPKGTestUtils assertEqualIntWithValue:65280 andValue2:[GPKGColorUtils toUnsignedColorFromRed:[GPKGColorUtils toRGBFromHex:@"00"] andGreen:[GPKGColorUtils toRGBFromHex:@"FF"] andBlue:[GPKGColorUtils toRGBFromHex:@"00"]]];
    [GPKGTestUtils assertEqualIntWithValue:-16711936 andValue2:[GPKGColorUtils toColorWithAlphaFromRed:[GPKGColorUtils toRGBFromHex:@"00"] andGreen:[GPKGColorUtils toRGBFromHex:@"FF"] andBlue:[GPKGColorUtils toRGBFromHex:@"00"]]];
    [GPKGTestUtils assertEqualUnsignedIntWithValue:4278255360 andValue2:[GPKGColorUtils toUnsignedColorWithAlphaFromRed:[GPKGColorUtils toRGBFromHex:@"00"] andGreen:[GPKGColorUtils toRGBFromHex:@"FF"] andBlue:[GPKGColorUtils toRGBFromHex:@"00"]]];
    [GPKGTestUtils assertEqualIntWithValue:-16711936 andValue2:[GPKGColorUtils toColorWithAlphaFromRed:[GPKGColorUtils toRGBFromHex:@"00"] andGreen:[GPKGColorUtils toRGBFromHex:@"FF"] andBlue:[GPKGColorUtils toRGBFromHex:@"00"] andAlpha:[GPKGColorUtils toRGBFromHex:@"fF"]]];
    [GPKGTestUtils assertEqualUnsignedIntWithValue:4278255360 andValue2:[GPKGColorUtils toUnsignedColorWithAlphaFromRed:[GPKGColorUtils toRGBFromHex:@"00"] andGreen:[GPKGColorUtils toRGBFromHex:@"FF"] andBlue:[GPKGColorUtils toRGBFromHex:@"00"] andAlpha:[GPKGColorUtils toRGBFromHex:@"fF"]]];
    
    [GPKGTestUtils assertEqualWithValue:@"#A0B0C0" andValue2:[GPKGColorUtils toColorFromHexRed:@"A0" andGreen:@"B0" andBlue:@"C0"]];
    [GPKGTestUtils assertEqualWithValue:@"#FFA0B0C0" andValue2:[GPKGColorUtils toColorWithAlphaFromHexRed:@"A0" andGreen:@"B0" andBlue:@"C0"]];
    [GPKGTestUtils assertEqualWithValue:@"#A0B0C0" andValue2:[GPKGColorUtils toColorShorthandFromHexRed:@"A0" andGreen:@"B0" andBlue:@"C0"]];
    [GPKGTestUtils assertEqualWithValue:@"#ABC" andValue2:[GPKGColorUtils toColorShorthandFromHexRed:@"AA" andGreen:@"BB" andBlue:@"CC"]];
    [GPKGTestUtils assertEqualWithValue:@"#FFA0B0C0" andValue2:[GPKGColorUtils toColorShorthandWithAlphaFromHexRed:@"A0" andGreen:@"B0" andBlue:@"C0"]];
    [GPKGTestUtils assertEqualWithValue:@"#FABC" andValue2:[GPKGColorUtils toColorShorthandWithAlphaFromHexRed:@"AA" andGreen:@"BB" andBlue:@"CC"]];
    [GPKGTestUtils assertEqualWithValue:@"#D0A0B0C0" andValue2:[GPKGColorUtils toColorWithAlphaFromHexRed:@"A0" andGreen:@"B0" andBlue:@"C0" andAlpha:@"D0"]];
    [GPKGTestUtils assertEqualWithValue:@"#D0A0B0C0" andValue2:[GPKGColorUtils toColorShorthandWithAlphaFromHexRed:@"A0" andGreen:@"B0" andBlue:@"C0" andAlpha:@"D0"]];
    [GPKGTestUtils assertEqualWithValue:@"#D0AABBCC" andValue2:[GPKGColorUtils toColorShorthandWithAlphaFromHexRed:@"AA" andGreen:@"BB" andBlue:@"CC" andAlpha:@"D0"]];
    [GPKGTestUtils assertEqualWithValue:@"#DABC" andValue2:[GPKGColorUtils toColorShorthandWithAlphaFromHexRed:@"AA" andGreen:@"BB" andBlue:@"CC" andAlpha:@"DD"]];
    
    [GPKGTestUtils assertEqualWithValue:@"#a0b0c0" andValue2:[GPKGColorUtils toColorFromHexRed:@"a0" andGreen:@"b0" andBlue:@"c0"]];
    [GPKGTestUtils assertEqualWithValue:@"#ffa0b0c0" andValue2:[GPKGColorUtils toColorWithAlphaFromHexRed:@"a0" andGreen:@"b0" andBlue:@"c0"]];
    [GPKGTestUtils assertEqualWithValue:@"#a0b0c0" andValue2:[GPKGColorUtils toColorShorthandFromHexRed:@"a0" andGreen:@"b0" andBlue:@"c0"]];
    [GPKGTestUtils assertEqualWithValue:@"#abc" andValue2:[GPKGColorUtils toColorShorthandFromHexRed:@"aa" andGreen:@"bb" andBlue:@"cc"]];
    [GPKGTestUtils assertEqualWithValue:@"#ffa0b0c0" andValue2:[GPKGColorUtils toColorShorthandWithAlphaFromHexRed:@"a0" andGreen:@"b0" andBlue:@"c0"]];
    [GPKGTestUtils assertEqualWithValue:@"#fabc" andValue2:[GPKGColorUtils toColorShorthandWithAlphaFromHexRed:@"aa" andGreen:@"bb" andBlue:@"cc"]];
    [GPKGTestUtils assertEqualWithValue:@"#d0a0b0c0" andValue2:[GPKGColorUtils toColorWithAlphaFromHexRed:@"a0" andGreen:@"b0" andBlue:@"c0" andAlpha:@"d0"]];
    [GPKGTestUtils assertEqualWithValue:@"#d0a0b0c0" andValue2:[GPKGColorUtils toColorShorthandWithAlphaFromHexRed:@"a0" andGreen:@"b0" andBlue:@"c0" andAlpha:@"d0"]];
    [GPKGTestUtils assertEqualWithValue:@"#d0aabbcc" andValue2:[GPKGColorUtils toColorShorthandWithAlphaFromHexRed:@"aa" andGreen:@"bb" andBlue:@"cc" andAlpha:@"d0"]];
    [GPKGTestUtils assertEqualWithValue:@"#dabc" andValue2:[GPKGColorUtils toColorShorthandWithAlphaFromHexRed:@"aa" andGreen:@"bb" andBlue:@"cc" andAlpha:@"dd"]];
    
    [GPKGTestUtils assertEqualWithValue:@"10a0d1" andValue2:[GPKGColorUtils shorthandHex:@"10a0d1"]];
    [GPKGTestUtils assertEqualWithValue:@"#10a0d1" andValue2:[GPKGColorUtils shorthandHex:@"#10a0d1"]];
    [GPKGTestUtils assertEqualWithValue:@"0D0A0B0C" andValue2:[GPKGColorUtils shorthandHex:@"0D0A0B0C"]];
    [GPKGTestUtils assertEqualWithValue:@"#0D0a0B0c" andValue2:[GPKGColorUtils shorthandHex:@"#0D0a0B0c"]];
    [GPKGTestUtils assertEqualWithValue:@"1ad" andValue2:[GPKGColorUtils shorthandHex:@"11aadd"]];
    [GPKGTestUtils assertEqualWithValue:@"#1aD" andValue2:[GPKGColorUtils shorthandHex:@"#11aADd"]];
    [GPKGTestUtils assertEqualWithValue:@"DABC" andValue2:[GPKGColorUtils shorthandHex:@"DDAABBCC"]];
    [GPKGTestUtils assertEqualWithValue:@"#dAbC" andValue2:[GPKGColorUtils shorthandHex:@"#dDAabBCc"]];
    
    [GPKGTestUtils assertEqualWithValue:@"10a0d1" andValue2:[GPKGColorUtils expandShorthandHex:@"10a0d1"]];
    [GPKGTestUtils assertEqualWithValue:@"#10a0d1" andValue2:[GPKGColorUtils expandShorthandHex:@"#10a0d1"]];
    [GPKGTestUtils assertEqualWithValue:@"0D0A0B0C" andValue2:[GPKGColorUtils expandShorthandHex:@"0D0A0B0C"]];
    [GPKGTestUtils assertEqualWithValue:@"#0D0a0B0c" andValue2:[GPKGColorUtils expandShorthandHex:@"#0D0a0B0c"]];
    [GPKGTestUtils assertEqualWithValue:@"11aadd" andValue2:[GPKGColorUtils expandShorthandHex:@"1ad"]];
    [GPKGTestUtils assertEqualWithValue:@"#11aaDD" andValue2:[GPKGColorUtils expandShorthandHex:@"#1aD"]];
    [GPKGTestUtils assertEqualWithValue:@"DDAABBCC" andValue2:[GPKGColorUtils expandShorthandHex:@"DABC"]];
    [GPKGTestUtils assertEqualWithValue:@"#ddAAbbCC" andValue2:[GPKGColorUtils expandShorthandHex:@"#dAbC"]];

    [GPKGTestUtils assertEqualWithValue:@"10" andValue2:[GPKGColorUtils shorthandHexSingle:@"10"]];
    [GPKGTestUtils assertEqualWithValue:@"0A" andValue2:[GPKGColorUtils shorthandHexSingle:@"0A"]];
    [GPKGTestUtils assertEqualWithValue:@"d" andValue2:[GPKGColorUtils shorthandHexSingle:@"dd"]];
    [GPKGTestUtils assertEqualWithValue:@"c" andValue2:[GPKGColorUtils shorthandHexSingle:@"cC"]];
    [GPKGTestUtils assertEqualWithValue:@"A" andValue2:[GPKGColorUtils shorthandHexSingle:@"Aa"]];
    [GPKGTestUtils assertEqualWithValue:@"B" andValue2:[GPKGColorUtils shorthandHexSingle:@"BB"]];
    
    [GPKGTestUtils assertEqualWithValue:@"10" andValue2:[GPKGColorUtils expandShorthandHexSingle:@"10"]];
    [GPKGTestUtils assertEqualWithValue:@"0A" andValue2:[GPKGColorUtils expandShorthandHexSingle:@"0A"]];
    [GPKGTestUtils assertEqualWithValue:@"dd" andValue2:[GPKGColorUtils expandShorthandHexSingle:@"d"]];
    [GPKGTestUtils assertEqualWithValue:@"CC" andValue2:[GPKGColorUtils expandShorthandHexSingle:@"C"]];
    
    float *hsl = [GPKGColorUtils toHSLFromRed:0 andGreen:0 andBlue:0];
    [GPKGTestUtils assertEqualDoubleWithValue:0.0f andValue2:hsl[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.0f andValue2:hsl[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.0f andValue2:hsl[2]];
    
    float *arithmeticRGB = [GPKGColorUtils toArithmeticRGBFromHue:0.0f andSaturation:0.0f andLightness:0.0f];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:0] andValue2:arithmeticRGB[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:0] andValue2:arithmeticRGB[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:0] andValue2:arithmeticRGB[2]];
    
    hsl = [GPKGColorUtils toHSLFromRed:255 andGreen:0 andBlue:0];
    [GPKGTestUtils assertEqualDoubleWithValue:0.0f andValue2:hsl[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:1.0f andValue2:hsl[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.5f andValue2:hsl[2]];
    
    arithmeticRGB = [GPKGColorUtils toArithmeticRGBFromHue:0.0f andSaturation:1.0f andLightness:0.5f];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:255] andValue2:arithmeticRGB[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:0] andValue2:arithmeticRGB[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:0] andValue2:arithmeticRGB[2]];
    
    hsl = [GPKGColorUtils toHSLFromRed:0 andGreen:255 andBlue:0];
    [GPKGTestUtils assertEqualDoubleWithValue:120.0f andValue2:hsl[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:1.0f andValue2:hsl[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.5f andValue2:hsl[2]];
    
    arithmeticRGB = [GPKGColorUtils toArithmeticRGBFromHue:120.0f andSaturation:1.0f andLightness:0.5f];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:0] andValue2:arithmeticRGB[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:255] andValue2:arithmeticRGB[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:0] andValue2:arithmeticRGB[2]];
    
    hsl = [GPKGColorUtils toHSLFromRed:0 andGreen:0 andBlue:255];
    [GPKGTestUtils assertEqualDoubleWithValue:240.0f andValue2:hsl[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:1.0f andValue2:hsl[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.5f andValue2:hsl[2]];
    
    arithmeticRGB = [GPKGColorUtils toArithmeticRGBFromHue:240.0f andSaturation:1.0f andLightness:0.5f];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:0] andValue2:arithmeticRGB[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:0] andValue2:arithmeticRGB[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:255] andValue2:arithmeticRGB[2]];
    
    hsl = [GPKGColorUtils toHSLFromRed:255 andGreen:255 andBlue:255];
    [GPKGTestUtils assertEqualDoubleWithValue:0.0f andValue2:hsl[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.0f andValue2:hsl[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:1.0f andValue2:hsl[2]];
    
    arithmeticRGB = [GPKGColorUtils toArithmeticRGBFromHue:0.0f andSaturation:0.0f andLightness:1.0f];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:255] andValue2:arithmeticRGB[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:255] andValue2:arithmeticRGB[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:[GPKGColorUtils toArithmeticRGBFromRGB:255] andValue2:arithmeticRGB[2]];
    
    hsl = [GPKGColorUtils toHSLFromRed:200 andGreen:165 andBlue:10];
    [GPKGTestUtils assertEqualDoubleWithValue:48.94737f andValue2:hsl[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.9047619f andValue2:hsl[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.4117647f andValue2:hsl[2]];
    
    int *rgb = [GPKGColorUtils toRGBFromHue:48.94737f andSaturation:0.9047619f andLightness:0.4117647f];
    [GPKGTestUtils assertEqualIntWithValue:200 andValue2:rgb[0]];
    [GPKGTestUtils assertEqualIntWithValue:165 andValue2:rgb[1]];
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:rgb[2]];
    
    hsl = [GPKGColorUtils toHSLFromRed:52 andGreen:113 andBlue:82];
    [GPKGTestUtils assertEqualDoubleWithValue:149.50821f andValue2:hsl[0]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.36969694f andValue2:hsl[1]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.32352942f andValue2:hsl[2]];
    
    rgb = [GPKGColorUtils toRGBFromHue:149.50821f andSaturation:0.36969694f andLightness:0.32352942f];
    [GPKGTestUtils assertEqualIntWithValue:52 andValue2:rgb[0]];
    [GPKGTestUtils assertEqualIntWithValue:113 andValue2:rgb[1]];
    [GPKGTestUtils assertEqualIntWithValue:82 andValue2:rgb[2]];
    
}

@end
