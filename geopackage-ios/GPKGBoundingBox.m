//
//  GPKGBoundingBox.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBoundingBox.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "SFPProjectionConstants.h"

@implementation GPKGBoundingBox

-(instancetype) init{
    self = [self initWithMinLongitude:[[NSDecimalNumber alloc] initWithFloat:-PROJ_WGS84_HALF_WORLD_LON_WIDTH]
                       andMinLatitude:[[NSDecimalNumber alloc] initWithFloat:-PROJ_WGS84_HALF_WORLD_LAT_HEIGHT]
                      andMaxLongitude:[[NSDecimalNumber alloc] initWithFloat:PROJ_WGS84_HALF_WORLD_LON_WIDTH]
                       andMaxLatitude:[[NSDecimalNumber alloc] initWithFloat:PROJ_WGS84_HALF_WORLD_LAT_HEIGHT]];
    return self;
}

-(instancetype) initWithMinLongitude: (NSDecimalNumber *) minLongitude
                      andMinLatitude: (NSDecimalNumber *) minLatitude
                     andMaxLongitude: (NSDecimalNumber *) maxLongitude
                      andMaxLatitude: (NSDecimalNumber *) maxLatitude{
    self = [super init];
    if(self != nil){
        self.minLongitude = minLongitude;
        self.maxLongitude = maxLongitude;
        self.minLatitude = minLatitude;
        self.maxLatitude = maxLatitude;
    }
    return self;
}

-(instancetype) initWithMinLongitudeDouble: (double) minLongitude
                      andMinLatitudeDouble: (double) minLatitude
                     andMaxLongitudeDouble: (double) maxLongitude
                      andMaxLatitudeDouble: (double) maxLatitude{
    return [self initWithMinLongitude:[[NSDecimalNumber alloc] initWithDouble:minLongitude]
                       andMinLatitude:[[NSDecimalNumber alloc] initWithDouble:minLatitude]
                      andMaxLongitude:[[NSDecimalNumber alloc] initWithDouble:maxLongitude]
                       andMaxLatitude:[[NSDecimalNumber alloc] initWithDouble:maxLatitude]];
}

-(instancetype) initWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self initWithMinLongitude:boundingBox.minLongitude andMinLatitude:boundingBox.minLatitude andMaxLongitude:boundingBox.maxLongitude andMaxLatitude:boundingBox.maxLatitude];
}

-(instancetype) initWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self initWithMinLongitude:envelope.minX andMinLatitude:envelope.minY andMaxLongitude:envelope.maxX andMaxLatitude:envelope.maxY];
}

-(NSDecimalNumber *) longitudeRange{
    return [self.maxLongitude decimalNumberBySubtracting:self.minLongitude];
}

-(double) longitudeRangeValue{
    return [[self longitudeRange] doubleValue];
}

-(NSDecimalNumber *) latitudeRange{
    return [self.maxLatitude decimalNumberBySubtracting:self.minLatitude];
}

-(double) latitudeRangeValue{
    return [[self latitudeRange] doubleValue];
}

-(SFGeometryEnvelope *) buildEnvelope{
    return [GPKGBoundingBox buildEnvelopeFromBoundingBox:self];
}

+(SFGeometryEnvelope *) buildEnvelopeFromBoundingBox: (GPKGBoundingBox *) boundingBox{
    SFGeometryEnvelope * envelope = [[SFGeometryEnvelope alloc] init];
    [envelope setMinX:boundingBox.minLongitude];
    [envelope setMaxX:boundingBox.maxLongitude];
    [envelope setMinY:boundingBox.minLatitude];
    [envelope setMaxY:boundingBox.maxLatitude];
    return envelope;
}

-(BOOL) equals: (GPKGBoundingBox *) boundingBox{
    if(self == boundingBox){
        return YES;
    }
    if(boundingBox == nil){
        return NO;
    }
    if([self.maxLatitude doubleValue] != [boundingBox.maxLatitude doubleValue]){
        return NO;
    }
    if([self.maxLongitude doubleValue] != [boundingBox.maxLongitude doubleValue]){
        return NO;
    }
    if([self.minLatitude doubleValue] != [boundingBox.minLatitude doubleValue]){
        return NO;
    }
    if([self.minLongitude doubleValue] != [boundingBox.minLongitude doubleValue]){
        return NO;
    }
    return YES;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[GPKGBoundingBox class]]) {
        return NO;
    }
    
    return [self equals:(GPKGBoundingBox *)object];
}

-(MKMapRect) mapRect{
    MKMapPoint lowerLeft = MKMapPointForCoordinate (CLLocationCoordinate2DMake([self.minLatitude doubleValue], [self.minLongitude doubleValue]));
    MKMapPoint upperRight = MKMapPointForCoordinate (CLLocationCoordinate2DMake([self.maxLatitude doubleValue], [self.maxLongitude doubleValue]));
    MKMapRect mapRect = MKMapRectNull;
    mapRect = MKMapRectUnion(mapRect, MKMapRectMake(lowerLeft.x, lowerLeft.y, 0, 0));
    mapRect= MKMapRectUnion(mapRect, MKMapRectMake(upperRight.x, upperRight.y, 0, 0));
    return mapRect;
}

-(MKCoordinateRegion) coordinateRegion{
    MKCoordinateSpan span = [self span];
    CLLocationCoordinate2D center = [self center];
    MKCoordinateRegion coordRegion = MKCoordinateRegionMake(center, span);
    return coordRegion;
}

-(MKCoordinateSpan) span{
    MKCoordinateSpan span = MKCoordinateSpanMake([self.maxLatitude doubleValue] - [self.minLatitude doubleValue], [self.maxLongitude doubleValue] - [self.minLongitude doubleValue]);
    return span;
}

-(CLLocationCoordinate2D) center{
    double minLongitude = [self.minLongitude doubleValue];
    double maxLongitude = [self.maxLongitude doubleValue];
    CLLocationCoordinate2D lowerLeft = CLLocationCoordinate2DMake([self.minLatitude doubleValue], minLongitude);
    CLLocationCoordinate2D upperRight = CLLocationCoordinate2DMake([self.maxLatitude doubleValue], maxLongitude);
    CLLocationCoordinate2D center = [GPKGTileBoundingBoxUtils pointBetweenFromLocation:lowerLeft andToLocation:upperRight];
    if(minLongitude + (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH) == maxLongitude){
        center = CLLocationCoordinate2DMake(center.latitude, maxLongitude - PROJ_WGS84_HALF_WORLD_LON_WIDTH);
    }
    if(center.longitude > PROJ_WGS84_HALF_WORLD_LON_WIDTH){
        center.longitude -= (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH);
    }else if(center.longitude < -PROJ_WGS84_HALF_WORLD_LON_WIDTH){
        center.longitude += (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH);
    }
    return center;
}

-(struct GPKGBoundingBoxSize) sizeInMeters{
    
    CLLocationCoordinate2D center = [self center];
    
    CLLocationCoordinate2D left = CLLocationCoordinate2DMake(center.latitude, [self.minLongitude doubleValue]);
    CLLocationCoordinate2D right = CLLocationCoordinate2DMake(center.latitude, [self.maxLongitude doubleValue]);
    double width1 = [GPKGTileBoundingBoxUtils distanceBetweenLocation:left andLocation:center];
    double width2 = [GPKGTileBoundingBoxUtils distanceBetweenLocation:center andLocation:right];
    
    CLLocationCoordinate2D upper = CLLocationCoordinate2DMake([self.maxLatitude doubleValue], center.longitude);
    CLLocationCoordinate2D lower = CLLocationCoordinate2DMake([self.minLatitude doubleValue], center.longitude);
    double height = [GPKGTileBoundingBoxUtils distanceBetweenLocation:lower andLocation:upper];
    
    struct GPKGBoundingBoxSize size;
    size.width = width1 + width2;
    size.height = height;
    
    return size;
}

-(GPKGBoundingBox *) complementaryWithMaxLongitude: (double) maxProjectionLongitude{
    
    GPKGBoundingBox * complementary = nil;
    
    NSDecimalNumber *adjust = nil;
    
    if([self.maxLongitude doubleValue] > maxProjectionLongitude){
        if([self.minLongitude doubleValue] >= -maxProjectionLongitude){
            adjust = [[NSDecimalNumber alloc] initWithDouble:-2 * maxProjectionLongitude];
        }
    }else if([self.minLongitude doubleValue] < -maxProjectionLongitude){
        if([self.maxLongitude doubleValue] <= maxProjectionLongitude){
            adjust = [[NSDecimalNumber alloc] initWithDouble:2 * maxProjectionLongitude];
        }
    }
    
    if(adjust != nil){
        complementary = [[GPKGBoundingBox alloc] initWithBoundingBox:self];
        [complementary setMinLongitude:[complementary.minLongitude decimalNumberByAdding:adjust]];
        [complementary setMaxLongitude:[complementary.maxLongitude decimalNumberByAdding:adjust]];
    }
            
    return complementary;
}

-(GPKGBoundingBox *) complementaryWgs84{
    return [self complementaryWithMaxLongitude:PROJ_WGS84_HALF_WORLD_LON_WIDTH];
}

-(GPKGBoundingBox *) complementaryWebMercator{
    return [self complementaryWithMaxLongitude:PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH];
}

-(GPKGBoundingBox *) boundCoordinatesWithMaxLongitude: (double) maxProjectionLongitude{

    GPKGBoundingBox *bounded = [[GPKGBoundingBox alloc] initWithBoundingBox:self];
    
    double minLongitude = fmod([self.minLongitude doubleValue] + maxProjectionLongitude, 2 * maxProjectionLongitude)
        - maxProjectionLongitude;
    double maxLongitude = fmod([self.maxLongitude doubleValue] + maxProjectionLongitude, 2 * maxProjectionLongitude)
        - maxProjectionLongitude;

    [bounded setMinLongitude:[[NSDecimalNumber alloc] initWithDouble:minLongitude]];
    [bounded setMaxLongitude:[[NSDecimalNumber alloc] initWithDouble:maxLongitude]];

    return bounded;
}

-(GPKGBoundingBox *) boundWgs84Coordinates{
    return [self boundCoordinatesWithMaxLongitude:PROJ_WGS84_HALF_WORLD_LON_WIDTH];
}

-(GPKGBoundingBox *) boundWebMercatorCoordinates{
    return [self boundCoordinatesWithMaxLongitude:PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH];
}

-(GPKGBoundingBox *) expandCoordinatesWithMaxLongitude: (double) maxProjectionLongitude{
    
    GPKGBoundingBox *expanded = [[GPKGBoundingBox alloc] initWithBoundingBox:self];
    
    double minLongitude = [self.minLongitude doubleValue];
    double maxLongitude = [self.maxLongitude doubleValue];
    
    if (minLongitude > maxLongitude) {
        int worldWraps = 1 + (int) ((minLongitude - maxLongitude) / (2 * maxProjectionLongitude));
        maxLongitude += (worldWraps * 2 * maxProjectionLongitude);
        [expanded setMaxLongitude:[[NSDecimalNumber alloc] initWithDouble:maxLongitude]];
    }
    
    return expanded;
}

-(GPKGBoundingBox *) expandWgs84Coordinates{
    return [self expandCoordinatesWithMaxLongitude:PROJ_WGS84_HALF_WORLD_LON_WIDTH];
}

-(GPKGBoundingBox *) expandWebMercatorCoordinates{
    return [self expandCoordinatesWithMaxLongitude:PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH];
}

-(GPKGBoundingBox *) transform: (SFPProjectionTransform *) transform{
    GPKGBoundingBox *transformed = self;
    if ([transform isSameProjection]) {
        transformed = [[GPKGBoundingBox alloc] initWithBoundingBox:transformed];
    } else {
        if([transform.fromProjection isUnit:SFP_UNIT_DEGREES]){
            transformed = [GPKGTileBoundingBoxUtils boundDegreesBoundingBoxWithWebMercatorLimits:transformed];
        }
        SFGeometryEnvelope *envelope = [GPKGBoundingBox buildEnvelopeFromBoundingBox:transformed];
        SFGeometryEnvelope *transformedEnvelope = [transform transformWithGeometryEnvelope:envelope];
        transformed = [[GPKGBoundingBox alloc] initWithEnvelope:transformedEnvelope];
    }
    return transformed;
}

-(BOOL) intersects: (GPKGBoundingBox *) boundingBox{
    return [self overlap:boundingBox] != nil;
}

-(BOOL) intersects: (GPKGBoundingBox *) boundingBox withAllowEmpty: (BOOL) allowEmpty{
    return [self overlap:boundingBox withAllowEmpty:allowEmpty] != nil;
}

-(GPKGBoundingBox *) overlap: (GPKGBoundingBox *) boundingBox{
    return [self overlap:boundingBox withAllowEmpty:NO];
}

-(GPKGBoundingBox *) overlap: (GPKGBoundingBox *) boundingBox withAllowEmpty: (BOOL) allowEmpty{
    
    double minLongitude = MAX([self.minLongitude doubleValue], [boundingBox.minLongitude doubleValue]);
    double maxLongitude = MIN([self.maxLongitude doubleValue], [boundingBox.maxLongitude doubleValue]);
    double minLatitude = MAX([self.minLatitude doubleValue], [boundingBox.minLatitude doubleValue]);
    double maxLatitude = MIN([self.maxLatitude doubleValue], [boundingBox.maxLatitude doubleValue]);
    
    GPKGBoundingBox * overlap = nil;
    
    if((minLongitude < maxLongitude && minLatitude < maxLatitude) || (allowEmpty && minLongitude <= maxLongitude && minLatitude <= maxLatitude)){
        overlap = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
    }
    
    return overlap;
}

-(GPKGBoundingBox *) union: (GPKGBoundingBox *) boundingBox{
    
    double minLongitude = MIN([self.minLongitude doubleValue], [boundingBox.minLongitude doubleValue]);
    double maxLongitude = MAX([self.maxLongitude doubleValue], [boundingBox.maxLongitude doubleValue]);
    double minLatitude = MIN([self.minLatitude doubleValue], [boundingBox.minLatitude doubleValue]);
    double maxLatitude = MAX([self.maxLatitude doubleValue], [boundingBox.maxLatitude doubleValue]);
    
    GPKGBoundingBox * unionBox = nil;
    
    if(minLongitude < maxLongitude && minLatitude < maxLatitude){
        unionBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
    }
    
    return unionBox;
}

-(BOOL) contains: (GPKGBoundingBox *) boundingBox{
    return [self.minLongitude doubleValue] <= [boundingBox.minLongitude doubleValue]
    && [self.maxLongitude doubleValue] >= [boundingBox.maxLongitude doubleValue]
    && [self.minLatitude doubleValue] <= [boundingBox.minLatitude doubleValue]
    && [self.maxLatitude doubleValue] >= [boundingBox.maxLatitude doubleValue];
}

-(GPKGBoundingBox *) squareExpand{
    return [self squareExpandWithBuffer:0.0];
}

-(GPKGBoundingBox *) squareExpandWithBuffer: (double) bufferPercentage{
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithBoundingBox:self];

    if([boundingBox isPoint] && bufferPercentage > 0.0){

        NSDecimalNumber *expand = [[NSDecimalNumber alloc] initWithDouble:DBL_EPSILON];
        
        [boundingBox setMinLongitude:[boundingBox.minLongitude decimalNumberBySubtracting:expand]];
        [boundingBox setMaxLongitude:[boundingBox.maxLongitude decimalNumberByAdding:expand]];
        
        [boundingBox setMinLatitude:[boundingBox.minLatitude decimalNumberBySubtracting:expand]];
        [boundingBox setMaxLatitude:[boundingBox.maxLatitude decimalNumberByAdding:expand]];

    }

    NSDecimalNumber *lonRange = [boundingBox longitudeRange];
    NSDecimalNumber *latRange = [boundingBox latitudeRange];
    
    NSDecimalNumber *range = lonRange;
    
    NSComparisonResult rangeCompare = [lonRange compare:latRange];
    if(rangeCompare == NSOrderedAscending){
        range = latRange;
        NSDecimalNumber *halfDiff = [[latRange decimalNumberBySubtracting:lonRange] decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithDouble:2.0]];
        [boundingBox setMinLongitude:[boundingBox.minLongitude decimalNumberBySubtracting:halfDiff]];
        [boundingBox setMaxLongitude:[boundingBox.maxLongitude decimalNumberByAdding:halfDiff]];
    }else if(rangeCompare == NSOrderedDescending){
        NSDecimalNumber *halfDiff = [[lonRange decimalNumberBySubtracting:latRange] decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithDouble:2.0]];
        [boundingBox setMinLatitude:[boundingBox.minLatitude decimalNumberBySubtracting:halfDiff]];
        [boundingBox setMaxLatitude:[boundingBox.maxLatitude decimalNumberByAdding:halfDiff]];
    }

    double rangeValue = MAX([range doubleValue], DBL_MIN);
    double bufferValue = ((rangeValue / (1.0 - (2.0 * bufferPercentage))) - rangeValue) / 2.0;
    
    NSDecimalNumber *buffer = [[NSDecimalNumber alloc] initWithDouble:bufferValue];

    [boundingBox setMinLongitude:[boundingBox.minLongitude decimalNumberBySubtracting:buffer]];
    [boundingBox setMinLatitude:[boundingBox.minLatitude decimalNumberBySubtracting:buffer]];
    [boundingBox setMaxLongitude:[boundingBox.maxLongitude decimalNumberByAdding:buffer]];
    [boundingBox setMaxLatitude:[boundingBox.maxLatitude decimalNumberByAdding:buffer]];

    return boundingBox;
}

-(BOOL) isPoint{
    return [self.minLongitude compare:self.maxLongitude] == NSOrderedSame
        && [self.minLatitude compare:self.maxLatitude] == NSOrderedSame;
}

@end
