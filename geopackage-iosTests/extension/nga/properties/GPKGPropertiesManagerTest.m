//
//  GPKGPropertiesManagerTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 7/24/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGPropertiesManagerTest.h"
#import "GPKGTestUtils.h"
#import "GPKGPropertiesManager.h"
#import "GPKGPropertyNames.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGTestSetupTeardown.h"

@implementation GPKGPropertiesManagerTest

static int GEOPACKAGE_COUNT = 12;

static int GEOPACKAGE_WITH_PROPERTIES_COUNT = 10;

static int GEOPACKAGE_WITHOUT_PROPERTIES_COUNT;

static NSString *GEOPACKAGE_FILE_NAME = @"GeoPackage";

static NSString *GEOPACKAGE_NAME = @"Name";

static NSString *CREATOR = @"NGA";

static NSString *EVEN_PROPERTY = @"even";

static NSString *ODD_PROPERTY = @"odd";

static NSString *TRUE_VALUE = @"true";
static NSString *FALSE_VALUE = @"false";

static NSString *COLOR_RED = @"Red";
static int COLOR_RED_FREQUENCY = 2;
static int COLOR_RED_COUNT;
static NSString *COLOR_GREEN = @"Green";
static int COLOR_GREEN_FREQUENCY = 3;
static int COLOR_GREEN_COUNT;
static NSString *COLOR_BLUE = @"Blue";
static int COLOR_BLUE_FREQUENCY = 4;
static int COLOR_BLUE_COUNT;

- (void)setUp {
    [super setUp];
    GEOPACKAGE_WITHOUT_PROPERTIES_COUNT = GEOPACKAGE_COUNT - GEOPACKAGE_WITH_PROPERTIES_COUNT;
    COLOR_RED_COUNT = [GPKGPropertiesManagerTest countWithFrequency:COLOR_RED_FREQUENCY];
    COLOR_GREEN_COUNT = [GPKGPropertiesManagerTest countWithFrequency:COLOR_GREEN_FREQUENCY];
    COLOR_BLUE_COUNT = [GPKGPropertiesManagerTest countWithFrequency:COLOR_BLUE_FREQUENCY];
}

+(int) countWithFrequency: (int) frequency{
    return (int) ceil(GEOPACKAGE_WITH_PROPERTIES_COUNT / (double) frequency);
}

/**
 * Test properties extension with cache of GeoPackages
 */
-(void) testPropertiesManagerWithCache{
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory manager];
    GPKGGeoPackageCache *cache = [[GPKGGeoPackageCache alloc] initWithManager:manager];
    
    NSArray<NSString *> *geoPackages = [self createGeoPackageNames];
    
    for (NSString *name in geoPackages) {
        [cache geoPackageOpenName:name];
    }
    
    GPKGPropertiesManager *propertiesManager = [[GPKGPropertiesManager alloc] initWithCache:cache];
    [self testPropertiesManager:propertiesManager];
}

/**
 * Test properties extension with GeoPackages
 */
-(void) testPropertiesManagerWithGeoPackages{
    GPKGPropertiesManager *manager = [[GPKGPropertiesManager alloc] initWithGeoPackages:[self createGeoPackages]];
    [self testPropertiesManager:manager];
}

-(NSArray<GPKGGeoPackage *> *) createGeoPackages{
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory manager];
    
    NSMutableArray<GPKGGeoPackage *> *geoPackages = [NSMutableArray array];
    
    NSArray<NSString *> *geoPackageNames = [self createGeoPackageNames];

    for (NSString *name in geoPackageNames) {
        GPKGGeoPackage *geoPackage = [manager open:name];
        [geoPackages addObject:geoPackage];
    }
    
    return geoPackages;
}

-(NSArray<NSString *> *) createGeoPackageNames{
    
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    
    for(int i = 0; i < GEOPACKAGE_COUNT; i++){
        GPKGGeoPackage *geoPackage = [GPKGTestSetupTeardown setUpCreateWithName:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, i + 1] andFeatures:YES andAllowEmptyFeatures:YES andTiles:YES];
        if(i < GEOPACKAGE_WITH_PROPERTIES_COUNT){
            [self addPropertiesToGeoPackage:geoPackage withIdentifier:i];
        }
        [names addObject:geoPackage.name];
        [geoPackage close];
    }
    
    return names;
}

-(void) addPropertiesToGeoPackage: (GPKGGeoPackage *) geoPackage withIdentifier: (int) i{
    
    GPKGPropertiesExtension *properties = [[GPKGPropertiesExtension alloc] initWithGeoPackage:geoPackage];
    
    [properties addValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, i+1] withProperty:GPKG_PE_TITLE];
    [properties addValue:[NSString stringWithFormat:@"%d", i] withProperty:GPKG_PE_IDENTIFIER];
    [properties addValue:(i % 2 == 0 ? TRUE_VALUE : FALSE_VALUE) withProperty:EVEN_PROPERTY];
    if(i % 2 == 1){
        [properties addValue:TRUE_VALUE withProperty:ODD_PROPERTY];
    }
    
    if (i % COLOR_RED_FREQUENCY == 0) {
        [properties addValue:COLOR_RED withProperty:GPKG_PE_TAG];
    }
    if (i % COLOR_GREEN_FREQUENCY == 0) {
        [properties addValue:COLOR_GREEN withProperty:GPKG_PE_TAG];
    }
    if (i % COLOR_BLUE_FREQUENCY == 0) {
        [properties addValue:COLOR_BLUE withProperty:GPKG_PE_TAG];
    }
    
}

-(void) testPropertiesManager: (GPKGPropertiesManager *) manager{

    int numProperties = 5;
    int numTagged = 7;
    
    // names
    NSSet<NSString *> *names = [manager geoPackageNames];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)names.count];
    for (int i = 1; i <= names.count; i++) {
        NSString *name = [NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, i];
        [GPKGTestUtils assertTrue:[names containsObject:name]];
        [GPKGTestUtils assertNotNil:[manager geoPackageWithName:name]];
    }
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:[manager numGeoPackages]];
    
    // numProperties
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:[manager numProperties]];
    
    // properties
    NSSet<NSString *> *properties = [manager properties];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:(int)properties.count];
    [GPKGTestUtils assertTrue:[properties containsObject:GPKG_PE_TITLE]];
    [GPKGTestUtils assertTrue:[properties containsObject:GPKG_PE_IDENTIFIER]];
    [GPKGTestUtils assertTrue:[properties containsObject:EVEN_PROPERTY]];
    [GPKGTestUtils assertTrue:[properties containsObject:ODD_PROPERTY]];
    [GPKGTestUtils assertTrue:[properties containsObject:GPKG_PE_TAG]];
    
    // hasProperty
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT andValue2:(int)[manager hasProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT andValue2:(int)[manager hasProperty:GPKG_PE_IDENTIFIER].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT andValue2:(int)[manager hasProperty:EVEN_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT / 2 andValue2:(int)[manager hasProperty:ODD_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:numTagged andValue2:(int)[manager hasProperty:GPKG_PE_TAG].count];
    
    // missingProperty
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITHOUT_PROPERTIES_COUNT andValue2:(int)[manager missingProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITHOUT_PROPERTIES_COUNT andValue2:(int)[manager missingProperty:GPKG_PE_IDENTIFIER].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITHOUT_PROPERTIES_COUNT andValue2:(int)[manager missingProperty:EVEN_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITHOUT_PROPERTIES_COUNT + GEOPACKAGE_WITH_PROPERTIES_COUNT / 2 andValue2:(int)[manager missingProperty:ODD_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITHOUT_PROPERTIES_COUNT + (GEOPACKAGE_WITH_PROPERTIES_COUNT - numTagged) andValue2:(int)[manager missingProperty:GPKG_PE_TAG].count];
    
    // numValues
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT andValue2:[manager numValuesOfProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT andValue2:[manager numValuesOfProperty:GPKG_PE_IDENTIFIER]];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[manager numValuesOfProperty:EVEN_PROPERTY]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[manager numValuesOfProperty:ODD_PROPERTY]];
    [GPKGTestUtils assertEqualIntWithValue:3 andValue2:[manager numValuesOfProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[manager numValuesOfProperty:GPKG_PE_CREATOR]];
    
    // hasValues
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:GPKG_PE_IDENTIFIER]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:EVEN_PROPERTY]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:ODD_PROPERTY]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertFalse:[manager hasValuesWithProperty:GPKG_PE_CREATOR]];
    
    // values
    NSSet<NSString *> *titles = [manager valuesOfProperty:GPKG_PE_TITLE];
    NSSet<NSString *> *identifiers = [manager valuesOfProperty:GPKG_PE_IDENTIFIER];
    for (int i = 0; i < GEOPACKAGE_WITH_PROPERTIES_COUNT; i++) {
        [GPKGTestUtils assertTrue:[titles containsObject:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, i+1]]];
        [GPKGTestUtils assertTrue:[identifiers containsObject:[NSString stringWithFormat:@"%d", i]]];
    }
    NSSet<NSString *> *evenValues = [manager valuesOfProperty:EVEN_PROPERTY];
    [GPKGTestUtils assertTrue:[evenValues containsObject:TRUE_VALUE]];
    [GPKGTestUtils assertTrue:[evenValues containsObject:FALSE_VALUE]];
    NSSet<NSString *> *oddValues = [manager valuesOfProperty:ODD_PROPERTY];
    [GPKGTestUtils assertTrue:[oddValues containsObject:TRUE_VALUE]];
    NSSet<NSString *> *tags = [manager valuesOfProperty:GPKG_PE_TAG];
    [GPKGTestUtils assertTrue:[tags containsObject:COLOR_RED]];
    [GPKGTestUtils assertTrue:[tags containsObject:COLOR_GREEN]];
    [GPKGTestUtils assertTrue:[tags containsObject:COLOR_BLUE]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager valuesOfProperty:GPKG_PE_CREATOR].count];
    
    // hasValue
    for (int i = 0; i < GEOPACKAGE_WITH_PROPERTIES_COUNT; i++) {
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[manager hasValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, i+1] withProperty:GPKG_PE_TITLE].count];
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[manager hasValue:[NSString stringWithFormat:@"%d", i] withProperty:GPKG_PE_IDENTIFIER].count];
    }
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, GEOPACKAGE_WITH_PROPERTIES_COUNT+1] withProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:[NSString stringWithFormat:@"%d", GEOPACKAGE_WITH_PROPERTIES_COUNT] withProperty:GPKG_PE_IDENTIFIER].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT / 2 andValue2:(int)[manager hasValue:TRUE_VALUE withProperty:EVEN_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT / 2 andValue2:(int)[manager hasValue:FALSE_VALUE withProperty:EVEN_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT / 2 andValue2:(int)[manager hasValue:TRUE_VALUE withProperty:ODD_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:FALSE_VALUE withProperty:ODD_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:COLOR_RED_COUNT andValue2:(int)[manager hasValue:COLOR_RED withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:COLOR_GREEN_COUNT andValue2:(int)[manager hasValue:COLOR_GREEN withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:COLOR_BLUE_COUNT andValue2:(int)[manager hasValue:COLOR_BLUE withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:@"Yellow" withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:CREATOR withProperty:GPKG_PE_CREATOR].count];
    
    // missingValue
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITHOUT_PROPERTIES_COUNT + GEOPACKAGE_WITH_PROPERTIES_COUNT / 2 andValue2:(int)[manager missingValue:TRUE_VALUE withProperty:EVEN_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITHOUT_PROPERTIES_COUNT + GEOPACKAGE_WITH_PROPERTIES_COUNT / 2 andValue2:(int)[manager missingValue:FALSE_VALUE withProperty:EVEN_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITHOUT_PROPERTIES_COUNT + GEOPACKAGE_WITH_PROPERTIES_COUNT / 2 andValue2:(int)[manager missingValue:TRUE_VALUE withProperty:ODD_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingValue:FALSE_VALUE withProperty:ODD_PROPERTY].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - COLOR_RED_COUNT andValue2:(int)[manager missingValue:COLOR_RED withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - COLOR_GREEN_COUNT andValue2:(int)[manager missingValue:COLOR_GREEN withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - COLOR_BLUE_COUNT andValue2:(int)[manager missingValue:COLOR_BLUE withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingValue:@"Yellow" withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingValue:CREATOR withProperty:GPKG_PE_CREATOR].count];
    
    // Add a property value to all GeoPackages
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:[manager addValue:CREATOR withProperty:GPKG_PE_CREATOR]];
    [GPKGTestUtils assertEqualIntWithValue:++numProperties andValue2:[manager numProperties]];
    properties = [manager properties];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:(int)properties.count];
    [GPKGTestUtils assertTrue:[properties containsObject:GPKG_PE_CREATOR]];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager hasProperty:GPKG_PE_CREATOR].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager missingProperty:GPKG_PE_CREATOR].count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[manager numValuesOfProperty:GPKG_PE_CREATOR]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:GPKG_PE_CREATOR]];
    [GPKGTestUtils assertTrue:[[manager valuesOfProperty:GPKG_PE_CREATOR] containsObject:CREATOR]];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager hasValue:CREATOR withProperty:GPKG_PE_CREATOR].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager missingValue:CREATOR withProperty:GPKG_PE_CREATOR].count];

    // Add a property value to a single GeoPackage
    [GPKGTestUtils assertFalse:[manager addValue:CREATOR withProperty:GPKG_PE_CREATOR inGeoPackage:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, GEOPACKAGE_COUNT]]];
    [GPKGTestUtils assertTrue:[manager addValue:CREATOR withProperty:GPKG_PE_CONTRIBUTOR inGeoPackage:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, GEOPACKAGE_COUNT]]];
    [GPKGTestUtils assertEqualIntWithValue:++numProperties andValue2:[manager numProperties]];
    properties = [manager properties];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:(int)properties.count];
    [GPKGTestUtils assertTrue:[properties containsObject:GPKG_PE_CONTRIBUTOR]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[manager hasProperty:GPKG_PE_CONTRIBUTOR].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - 1 andValue2:(int)[manager missingProperty:GPKG_PE_CONTRIBUTOR].count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[manager numValuesOfProperty:GPKG_PE_CONTRIBUTOR]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:GPKG_PE_CONTRIBUTOR]];
    [GPKGTestUtils assertTrue:[[manager valuesOfProperty:GPKG_PE_CONTRIBUTOR] containsObject:CREATOR]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[manager hasValue:CREATOR withProperty:GPKG_PE_CONTRIBUTOR].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - 1 andValue2:(int)[manager missingValue:CREATOR withProperty:GPKG_PE_CONTRIBUTOR].count];
    
    // Add an identifier to GeoPackages without one, one at a time
    NSArray<GPKGGeoPackage *> *missingIdentifiers = [manager missingProperty:GPKG_PE_IDENTIFIER];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITHOUT_PROPERTIES_COUNT andValue2:(int)missingIdentifiers.count];
    int indentifierIndex = 100;
    for(GPKGGeoPackage *missingIdentifierGeoPackage in missingIdentifiers){
        [GPKGTestUtils assertTrue:[manager addValue:[NSString stringWithFormat:@"%d", indentifierIndex++] withProperty:GPKG_PE_IDENTIFIER inGeoPackage:missingIdentifierGeoPackage.name]];
    }
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager hasProperty:GPKG_PE_IDENTIFIER].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager missingProperty:GPKG_PE_IDENTIFIER].count];
    
    // Add an identifier to GeoPackages without one, all at once
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - 1 andValue2:[manager addValue:CREATOR withProperty:GPKG_PE_CONTRIBUTOR]];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager hasProperty:GPKG_PE_CONTRIBUTOR].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager missingProperty:GPKG_PE_CONTRIBUTOR].count];
    
    // Delete a property from all GeoPackages
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:[manager deleteProperty:GPKG_PE_IDENTIFIER]];
    [GPKGTestUtils assertEqualIntWithValue:--numProperties andValue2:[manager numProperties]];
    properties = [manager properties];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:(int)properties.count];
    [GPKGTestUtils assertFalse:[properties containsObject:GPKG_PE_IDENTIFIER]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasProperty:GPKG_PE_IDENTIFIER].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingProperty:GPKG_PE_IDENTIFIER].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[manager numValuesOfProperty:GPKG_PE_IDENTIFIER]];
    [GPKGTestUtils assertFalse:[manager hasValuesWithProperty:GPKG_PE_IDENTIFIER]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager valuesOfProperty:GPKG_PE_IDENTIFIER].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:@"1" withProperty:GPKG_PE_IDENTIFIER].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingValue:@"1" withProperty:GPKG_PE_IDENTIFIER].count];

    // Delete a property from a single GeoPackage
    [GPKGTestUtils assertTrue:[manager deleteProperty:GPKG_PE_TAG inGeoPackage:[NSString stringWithFormat:@"%@1", GEOPACKAGE_NAME]]];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:[manager numProperties]];
    properties = [manager properties];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:(int)properties.count];
    [GPKGTestUtils assertTrue:[properties containsObject:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:--numTagged andValue2:(int)[manager hasProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - numTagged andValue2:(int)[manager missingProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:3 andValue2:[manager numValuesOfProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertTrue:[[manager valuesOfProperty:GPKG_PE_TAG] containsObject:COLOR_RED]];
    [GPKGTestUtils assertEqualIntWithValue:COLOR_RED_COUNT - 1 andValue2:(int)[manager hasValue:COLOR_RED withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - (COLOR_RED_COUNT - 1) andValue2:(int)[manager missingValue:COLOR_RED withProperty:GPKG_PE_TAG].count];

    // Delete a property value from all GeoPackages
    [GPKGTestUtils assertEqualIntWithValue:COLOR_RED_COUNT - 1 andValue2:[manager deleteValue:COLOR_RED withProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:[manager numProperties]];
    properties = [manager properties];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:(int)properties.count];
    [GPKGTestUtils assertTrue:[properties containsObject:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:--numTagged andValue2:(int)[manager hasProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - numTagged andValue2:(int)[manager missingProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[manager numValuesOfProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertFalse:[[manager valuesOfProperty:GPKG_PE_TAG] containsObject:COLOR_RED]];
    [GPKGTestUtils assertTrue:[[manager valuesOfProperty:GPKG_PE_TAG] containsObject:COLOR_GREEN]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:COLOR_RED withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:COLOR_GREEN_COUNT - 1 andValue2:(int)[manager hasValue:COLOR_GREEN withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingValue:COLOR_RED withProperty:GPKG_PE_TAG].count];
    
    // Delete a property value from a single GeoPackage
    [GPKGTestUtils assertTrue:[manager deleteValue:COLOR_GREEN withProperty:GPKG_PE_TAG inGeoPackage:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, COLOR_GREEN_FREQUENCY + 1]]];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:[manager numProperties]];
    properties = [manager properties];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:(int)properties.count];
    [GPKGTestUtils assertTrue:[properties containsObject:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:--numTagged andValue2:(int)[manager hasProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - numTagged andValue2:(int)[manager missingProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[manager numValuesOfProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertTrue:[[manager valuesOfProperty:GPKG_PE_TAG] containsObject:COLOR_GREEN]];
    [GPKGTestUtils assertEqualIntWithValue:COLOR_GREEN_COUNT - 2 andValue2:(int)[manager hasValue:COLOR_GREEN withProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - (COLOR_GREEN_COUNT - 2) andValue2:(int)[manager missingValue:COLOR_GREEN withProperty:GPKG_PE_TAG].count];

    // Delete all properties from a single GeoPackage
    [GPKGTestUtils assertTrue:[manager deleteAllInGeoPackage:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 2]]];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:[manager numProperties]];
    properties = [manager properties];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:(int)properties.count];
    [GPKGTestUtils assertTrue:[properties containsObject:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT - 1 andValue2:(int)[manager hasProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - (GEOPACKAGE_WITH_PROPERTIES_COUNT - 1) andValue2:(int)[manager missingProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT - 1 andValue2:[manager numValuesOfProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertFalse:[[manager valuesOfProperty:GPKG_PE_TITLE] containsObject:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 2]]];
    [GPKGTestUtils assertTrue:[[manager valuesOfProperty:GPKG_PE_TITLE] containsObject:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 3]]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 2] withProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[manager hasValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 3] withProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 2] withProperty:GPKG_PE_TITLE].count];
    
    // Remove the extension from a single GeoPackage
    [manager removeExtensionInGeoPackage:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 4]];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:[manager numProperties]];
    properties = [manager properties];
    [GPKGTestUtils assertEqualIntWithValue:numProperties andValue2:(int)properties.count];
    [GPKGTestUtils assertTrue:[properties containsObject:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT - 2 andValue2:(int)[manager hasProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - (GEOPACKAGE_WITH_PROPERTIES_COUNT - 2) andValue2:(int)[manager missingProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_WITH_PROPERTIES_COUNT - 2 andValue2:[manager numValuesOfProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertTrue:[manager hasValuesWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertFalse:[[manager valuesOfProperty:GPKG_PE_TITLE] containsObject:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 4]]];
    [GPKGTestUtils assertTrue:[[manager valuesOfProperty:GPKG_PE_TITLE] containsObject:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 3]]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 4] withProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[manager hasValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 3] withProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 4] withProperty:GPKG_PE_TITLE].count];
    
    // Delete all properties from all GeoPackages
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT - 2 andValue2:[manager deleteAll]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[manager numProperties]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager properties].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[manager numValuesOfProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertFalse:[manager hasValuesWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager valuesOfProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 3] withProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 3] withProperty:GPKG_PE_TITLE].count];
    
    // Remove the extension from all GeoPackages
    [manager removeExtension];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[manager numProperties]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager properties].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[manager numValuesOfProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertFalse:[manager hasValuesWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager valuesOfProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[manager hasValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 3] withProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertEqualIntWithValue:GEOPACKAGE_COUNT andValue2:(int)[manager missingValue:[NSString stringWithFormat:@"%@%d", GEOPACKAGE_NAME, 3] withProperty:GPKG_PE_TITLE].count];
     
     // Close the GeoPackages
     [manager closeGeoPackages];
     [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[manager numGeoPackages]];
}

@end
