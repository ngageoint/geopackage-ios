//
//  GPKGOAPIFeatureGenerator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGOAPIFeatureGenerator.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionConstants.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "GPKGDateTimeUtils.h"
#import "SFGFeature.h"
#import "OAFCrs.h"
#import "OAFFeaturesConverter.h"

/**
 * OGC CRS Version
 */
NSString * const OGC_VERSION = @"1.3";

/**
 * EPSG CRS Version
 */
NSString * const EPSG_VERSION = @"0";

/**
 * Limit pattern
 */
NSString * const LIMIT_PATTERN = @"limit=\\d+";

@interface GPKGOAPIFeatureGenerator()

/**
 * Base server url
 */
@property (nonatomic, strong) NSString *server;

/**
 * Identifier (name) of a specific collection
 */
@property (nonatomic, strong) NSString *id;

@end

@implementation GPKGOAPIFeatureGenerator

static int HTTP_OK = 200;
static int HTTP_MOVED_PERM = 301;
static int HTTP_MOVED_TEMP = 302;
static int HTTP_SEE_OTHER = 303;

/**
 * Limit expression
 */
static NSRegularExpression *limitExpression = nil;

/**
 * OGC CRS84 Projection
 */
static SFPProjection *OGC_CRS84 = nil;

/**
 * Default projections
 */
static SFPProjections *defaultProjections;

+(void) initialize{
    if(limitExpression == nil){
        NSError  *error = nil;
        limitExpression = [NSRegularExpression regularExpressionWithPattern:LIMIT_PATTERN options:0 error:&error];
        if(error){
            [NSException raise:@"Limit Regular Expression" format:@"Failed to create limit regular expression with error: %@", error];
        }
    }
    if(OGC_CRS84 == nil){
        OGC_CRS84 = [SFPProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_OGC andCode:PROJ_OGC_CRS84];
    }
    if(defaultProjections == nil){
        defaultProjections = [[SFPProjections alloc] init];
        [defaultProjections addProjection:OGC_CRS84];
        [defaultProjections addProjection:[self epsgWGS84]];
    }
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) tableName andServer: (NSString *) server andId: (NSString *) id{
    self = [super initWithGeoPackage:geoPackage andTable:tableName];
    if(self != nil){
        self.server = server;
        self.id = id;
        self.downloadAttempts = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_FEATURE_GENERATOR andProperty:GPKG_PROP_FEATURE_GENERATOR_DOWNLOAD_ATTEMPTS] intValue];
    }
    return self;
}

-(NSString *) server{
    return _server;
}

-(NSString *) id{
    return _id;
}

-(void) setTimeFromDate: (NSDate *) time{
    if (time != nil) {
        self.time = [GPKGDateTimeUtils convertToStringWithDate:time withFormat:GPKG_DTU_DATETIME_FORMAT2];
    } else {
        self.time = nil;
    }
}

-(void) setPeriodFromDate: (NSDate *) period{
    if (period != nil) {
        self.period = [GPKGDateTimeUtils convertToStringWithDate:period withFormat:GPKG_DTU_DATETIME_FORMAT2];
    } else {
        self.period = nil;
    }
}

-(SFPProjection *) srsProjection{
    SFPProjection *srsProjection = nil;
    if (self.projection != nil && [OGC_CRS84 isEqualToProjection:self.projection]) {
        srsProjection = [GPKGFeatureGenerator epsgWGS84];
    }else{
        srsProjection = [super srsProjection];
    }
    return srsProjection;
}

/**
 * Create the feature
 *
 * @param feature
 *            feature
 * @throws SQLException
 *             upon error
 */
-(void) createFeature: (SFGFeature *) feature{
    [super createFeatureWithGeometry:[feature simpleGeometry] andProperties:[feature properties]];
}

-(int) generateFeatures{

    NSString *url = [self buildCollectionRequestUrl];
    
    OAFCollection *collection = [self collectionRequestForURL:url];
    
    SFPProjections *projections = [self projectionsForCollection:collection];
    if(self.projection != nil && ![projections hasProjection:self.projection]){
        NSLog(@"The projection is not advertised by the server. Authority: %@, Code: %@", self.projection.authority, self.projection.code);
    }

    NSMutableString *urlValue = [NSMutableString stringWithString:url];
    
    [urlValue appendString:@"/items"];
    
    BOOL params = NO;
    
    if(self.time != nil){
        if (params) {
            [urlValue appendString:@"&"];
        } else {
            [urlValue appendString:@"?"];
            params = YES;
        }
        [urlValue appendString:@"time="];
        [urlValue appendString:self.time];
        if (self.period != nil) {
            [urlValue appendString:@"/"];
            [urlValue appendString:self.period];
        }
    }
    
    if (self.boundingBox != nil) {
        if (params) {
            [urlValue appendString:@"&"];
        } else {
            [urlValue appendString:@"?"];
            params = YES;
        }
        [urlValue appendString:@"bbox="];
        [urlValue appendFormat:@"%f", [self.boundingBox.minLongitude doubleValue]];
        [urlValue appendString:@","];
        [urlValue appendFormat:@"%f", [self.boundingBox.minLatitude doubleValue]];
        [urlValue appendString:@","];
        [urlValue appendFormat:@"%f", [self.boundingBox.maxLongitude doubleValue]];
        [urlValue appendString:@","];
        [urlValue appendFormat:@"%f", [self.boundingBox.maxLatitude doubleValue]];
        
        if([self requestProjection:self.boundingBoxProjection]){
            [urlValue appendString:@"&bbox-crs="];
            [urlValue appendString:[[self crsFromProjection:self.boundingBoxProjection] description]];
        }
    }
    
    if([self requestProjection:self.projection]){
        if(params){
            [urlValue appendString:@"&"];
        }else{
            [urlValue appendString:@"?"];
            params = YES;
        }
        [urlValue appendString:@"crs="];
        [urlValue appendString:[[self crsFromProjection:self.projection] description]];
    }
    
    int count = [self generateFeaturesForURL:urlValue andCount:0];
    
    if (self.progress != nil && ![self.progress isActive] && [self.progress cleanupOnCancel]) {
        [self.geoPackage deleteTableQuietly:self.tableName];
        count = 0;
    }
    
    return count;
}

/**
 * Build the collection request URL
 *
 * @return url
 */
-(NSString *) buildCollectionRequestUrl{
    
    NSMutableString *url = [NSMutableString stringWithString:self.server];
    
    if(![self.server hasSuffix:@"/"]){
        [url appendString:@"/"];
    }
    
    [url appendString:@"collections/"];
    [url appendString:self.id];
    
    return url;
}

-(SFPProjections *) projections{
    return [self projectionsForURL:[self buildCollectionRequestUrl]];
}

-(SFPProjections *) projectionsForURL: (NSString *) url{
    return [self projectionsForCollection:[self collectionRequestForURL:url]];
}

-(SFPProjections *) projectionsForCollection: (OAFCollection *) collection{

    SFPProjections *projections = [[SFPProjections alloc] init];
    
    if (collection != nil) {
        
        for (NSString *crs in collection.crs) {
            
            OAFCrs *crsValue = [[OAFCrs alloc] initWithCrs:crs];
            if([crsValue isValid]){
                [self addProjectionWithAuthority:crsValue.authority andCode:crsValue.code toProjections:projections];
            }
            
        }
        
    }
    
    if([projections isEmpty]){
        projections = defaultProjections;
    } else if([projections hasProjection:OGC_CRS84]){
        [projections addProjection:[GPKGFeatureGenerator epsgWGS84]];
    }
    
    return projections;
}

-(BOOL) requestProjection: (SFPProjection *) projection{
    return projection != nil && ![self isDefaultProjection:projection];
}

-(BOOL) isDefaultProjection: (SFPProjection *) projection{
    return [defaultProjections hasProjection:projection];
}

-(OAFCollection *) collectionRequest{
    return [self collectionRequestForURL:[self buildCollectionRequestUrl]];
}

/**
 * Collection request for the provided URL
 *
 * @param url
 *            url value
 * @return collection
 */
-(OAFCollection *) collectionRequestForURL: (NSString *) url{

    OAFCollection *collection = nil;
    
    NSString *collectionValue = nil;
    @try {
        collectionValue = [self urlRequestForURL:url];
    } @catch (NSException *exception) {
        NSLog(@"Failed to request the collection. url: %@, error: %@", url, exception);
    }
    
    if (collectionValue != nil) {
        
        @try {
            collection = [OAFFeaturesConverter jsonToCollection:collectionValue];
        } @catch (NSException *exception) {
            NSLog(@"Failed to translate collection. url: %@, error: %@", url, exception);
        }
        
    }
    
    return collection;
}

/**
 * Generate features
 *
 * @param urlString
 *            URL
 * @param currentCount
 *            current count
 * @return current result count
 * @throws SQLException
 *             upon failure
 */
-(int) generateFeaturesForURL: (NSString *) urlString andCount: (int) currentCount{

    NSMutableString *urlValue = [NSMutableString stringWithString:urlString];
    
    NSInteger paramIndex = [urlString rangeOfString:@"?" options:NSBackwardsSearch].location;
    BOOL params = paramIndex != NSNotFound && paramIndex + 1 < urlString.length;
    
    NSNumber *requestLimit = self.limit;
    if (self.totalLimit != nil && [self.totalLimit intValue] - currentCount < (requestLimit != nil ? [requestLimit intValue] : OAF_LIMIT_DEFAULT)) {
            requestLimit = [NSNumber numberWithInt:[self.totalLimit intValue] - currentCount];
    }
    
    NSString *url = urlValue;
    if (requestLimit != nil) {
        NSRange range = [limitExpression rangeOfFirstMatchInString:urlValue options:0 range:NSMakeRange(0, urlValue.length)];
        if(range.location != NSNotFound){
            url = [urlValue stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"limit=%@", requestLimit]];
        }else{
            if (params) {
                [urlValue appendString:@"&"];
            } else {
                [urlValue appendString:@"?"];
                params = YES;
            }
            [urlValue appendString:@"limit="];
            [urlValue appendFormat:@"%@",requestLimit];
        }
    }
    
    NSString *features = nil;
    if([self isActive]){
        features = [self urlRequestForURL:url];
    }
    
    if (features != nil && [self isActive]) {
        
        OAFFeatureCollection *featureCollection = [OAFFeaturesConverter jsonToFeatureCollection:features];
        
        if (currentCount == 0 && self.progress != nil) {
            NSNumber *max = self.totalLimit;
            NSNumber *numberMatched = featureCollection.numberMatched;
            if (numberMatched != nil) {
                if (max == nil) {
                    max = numberMatched;
                } else {
                    max = [NSNumber numberWithInt:MIN([max intValue], [numberMatched intValue])];
                }
            }
            if (max != nil) {
                [self.progress setMax:[max intValue]];
            }
        }
        
        [self createFeaturesWithCollection:featureCollection];
        
        NSNumber *numberReturned = featureCollection.numberReturned;
        if (numberReturned != nil) {
            currentCount += [numberReturned intValue];
        }
        
        NSMutableArray<OAFLink *> *nextLinks = [[featureCollection relationLinks] objectForKey:OAF_LINK_RELATION_NEXT];
        if (nextLinks != nil) {
            for (OAFLink *nextLink in nextLinks) {
                if (self.totalLimit != nil && [self.totalLimit intValue] <= currentCount) {
                    break;
                }
                currentCount = [self generateFeaturesForURL:nextLink.href andCount:currentCount];
            }
        }
    }
    
    return currentCount;
}

/**
 * URL request
 *
 * @param urlValue
 *            URL value
 * @return response string
 */
-(NSString *) urlRequestForURL: (NSString *) urlValue{

    NSString *response = nil;
    
    NSURL *url =  [NSURL URLWithString:urlValue];
    
    int attempt = 1;
    while (true) {
        @try {
            response = [self urlRequestForURLValue:urlValue andURL:url];
            break;
        } @catch (NSException *exception) {
            if (attempt < self.downloadAttempts) {
                NSLog(@"Failed to download features after attempt %d of %d. URL: %@, error: %@", attempt, self.downloadAttempts, urlValue, exception);
                attempt++;
            } else {
                @throw exception;
            }
        }
    }
    
    return response;
}

/**
 * Perform a URL request
 *
 * @param urlValue
 *            URL string value
 * @param url
 *            URL
 * @return features response
 */
-(NSString *) urlRequestForURLValue: (NSString *) urlValue andURL: (NSURL *) url{

    NSString *response = nil;
    
    NSLog(@"%@", urlValue);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json,application/geo+json" forHTTPHeaderField:@"Accept"];
    
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if(error){
        [NSException raise:@"Failed Request" format:@"Failed request. URL: %@, error: %@", urlValue, error];
    }
    
    int responseCode = (int) urlResponse.statusCode;
    
    if(responseCode == HTTP_MOVED_PERM
       || responseCode == HTTP_MOVED_TEMP
       || responseCode == HTTP_SEE_OTHER){
        
        NSString *redirect = [urlResponse.allHeaderFields objectForKey:@"Location"];
        url =  [NSURL URLWithString:redirect];
        
        urlResponse = nil;
        error = nil;
        data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
        if(error){
            [NSException raise:@"Failed Request" format:@"Failed request. URL: %@, error: %@", urlValue, error];
        }
        
        responseCode = (int) urlResponse.statusCode;
    }
    
    if(responseCode != HTTP_OK){
        [NSException raise:@"Failed Request" format:@"Failed request. URL: %@, Response Code: %d, Response Message: %@, error: %@", urlValue, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode], error];
    }
    
    response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return response;
}

/**
 * Create features in the feature DAO from the features value
 *
 * @param features
 *            features json
 * @return feature collection
 * @throws SQLException
 *             upon error
 */
-(OAFFeatureCollection *) createFeaturesWithJSON: (NSString *) features{
    
    OAFFeatureCollection * featureCollection = [OAFFeaturesConverter jsonToFeatureCollection:features];
    
    [self createFeaturesWithCollection:featureCollection];
    
    return featureCollection;
}

/**
 * Create features from the feature collection
 *
 * @param featureCollection
 *            feature collection
 * @return features created
 */
-(int) createFeaturesWithCollection: (OAFFeatureCollection *) featureCollection{

    int count = 0;
    
    [self.geoPackage beginTransaction];
    @try {
        
        for(SFGFeature *feature in featureCollection.featureCollection.features){
            
            if (![self isActive]) {
                break;
            }
            
            @try {
                [self createFeature:feature];
                count++;
                
                if (self.progress != nil) {
                    [self.progress addProgress:1];
                }
            } @catch (NSException *exception) {
                NSLog(@"Failed to create feature: %@, error: %@", feature.id, exception);
            }
            
            if (count > 0 && count % self.transactionLimit == 0) {
                [self.geoPackage commitTransaction];
                [self.geoPackage beginTransaction];
            }
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create features. error: %@", exception);
        [self.geoPackage rollbackTransaction];
    } @finally {
        [self.geoPackage commitTransaction];
    }
    
    NSNumber *numberReturned = featureCollection.numberReturned;
    if (numberReturned != nil && [numberReturned intValue] != count) {
        NSLog(@"Feature Collection number returned does not match number of features created. Number Returned: %@, Created: %d", numberReturned, count);
    }
    [featureCollection setNumberReturned:[NSNumber numberWithInt:count]];
    
    return count;
}

/**
 * Get the CRS from the projection
 *
 * @param projection
 *            projection
 * @return crs
 */
-(OAFCrs *) crsFromProjection: (SFPProjection *) projection{
    NSString *version = nil;
    if([projection.authority isEqualToString:PROJ_AUTHORITY_OGC]){
        version = OGC_VERSION;
    }else{
        version = EPSG_VERSION;
    }
    return [[OAFCrs alloc] initWithAuthority:projection.authority andVersion:version andCode:projection.code];
}

@end
