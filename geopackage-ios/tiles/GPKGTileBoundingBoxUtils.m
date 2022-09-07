//
//  GPKGTileBoundingBoxUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileBoundingBoxUtils.h"
#import "PROJProjectionConstants.h"
#import "PROJProjectionFactory.h"
#import "SFPGeometryTransform.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"

#define degreesToRadians(x) (M_PI * x / PROJ_WGS84_HALF_WORLD_LON_WIDTH)
#define radiansToDegrees(x) (x * PROJ_WGS84_HALF_WORLD_LON_WIDTH / M_PI)

@implementation GPKGTileBoundingBoxUtils

+(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2{
    return [boundingBox overlap:boundingBox2];
}

+(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2 andAllowEmpty: (BOOL) allowEmpty{
    return [boundingBox overlap:boundingBox2 withAllowEmpty:allowEmpty];
}

+(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2 withMaxLongitude: (double) maxLongitude{
    return [self overlapWithBoundingBox:boundingBox andBoundingBox:boundingBox2 withMaxLongitude:maxLongitude andAllowEmpty:NO];
}

+(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2 withMaxLongitude: (double) maxLongitude andAllowEmpty: (BOOL) allowEmpty{
    
    GPKGBoundingBox *bbox2 = boundingBox2;
    
    double adjustment = 0.0;
    
    if(maxLongitude > 0){
        if([boundingBox.minLongitude compare:boundingBox2.maxLongitude] == NSOrderedDescending){
            adjustment = maxLongitude * 2.0;
        } else if([boundingBox.maxLongitude compare:boundingBox2.minLongitude] == NSOrderedAscending){
            adjustment = maxLongitude * -2.0;
        }
    }
    
    if(adjustment != 0.0){
        bbox2 = [boundingBox2 mutableCopy];
        NSDecimalNumber *adjustmentDecimal = [[NSDecimalNumber alloc] initWithDouble:adjustment];
        [bbox2 setMinLongitude:[bbox2.minLongitude decimalNumberByAdding:adjustmentDecimal]];
        [bbox2 setMaxLongitude:[bbox2.maxLongitude decimalNumberByAdding:adjustmentDecimal]];
    }
    
    return [self overlapWithBoundingBox:boundingBox andBoundingBox:bbox2 andAllowEmpty:allowEmpty];
}

+(BOOL) isPoint: (SFPoint *) point inBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGBoundingBox *pointBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitude:point.x andMinLatitude:point.y andMaxLongitude:point.x andMaxLatitude:point.y];
    return [boundingBox intersects:pointBoundingBox withAllowEmpty:YES];
}

+(BOOL) isPoint: (SFPoint *) point inBoundingBox: (GPKGBoundingBox *) boundingBox withMaxLongitude: (double) maxLongitude{
    GPKGBoundingBox *pointBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitude:point.x andMinLatitude:point.y andMaxLongitude:point.x andMaxLatitude:point.y];
    GPKGBoundingBox *overlap = [self overlapWithBoundingBox:boundingBox andBoundingBox:pointBoundingBox withMaxLongitude:maxLongitude andAllowEmpty:YES];
    return overlap != nil;
}

+(GPKGBoundingBox *) unionWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2{
    return [boundingBox union:boundingBox2];
}

+(double) xPixelWithWidth: (int) width andBoundingBox: (GPKGBoundingBox *) boundingBox andLongitude: (double) longitude{
    
    double boxWidth = [boundingBox.maxLongitude doubleValue] - [boundingBox.minLongitude doubleValue];
    double offset = longitude - [boundingBox.minLongitude doubleValue];
    double percentage = offset / boxWidth;
    double pixel = percentage * width;
    
    return pixel;
}

+(double) longitudeFromPixelWithWidth: (int) width andBoundingBox: (GPKGBoundingBox *) boundingBox andPixel: (double) pixel{
    return [self longitudeFromPixelWithWidth:width andBoundingBox:boundingBox andTileBoundingBox:boundingBox andPixel:pixel];
}

+(double) longitudeFromPixelWithWidth: (int) width andBoundingBox: (GPKGBoundingBox *) boundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andPixel: (double) pixel{
    
    double boxWidth = [tileBoundingBox.maxLongitude doubleValue] - [tileBoundingBox.minLongitude doubleValue];
    double percentage = pixel / width;
    double offset = percentage * boxWidth;
    double longitude = offset + [boundingBox.minLongitude doubleValue];
    
    return longitude;
}

+(double) yPixelWithHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andLatitude: (double) latitude{
    
    double boxHeight = [boundingBox.maxLatitude doubleValue] - [boundingBox.minLatitude doubleValue];
    double offset = [boundingBox.maxLatitude doubleValue] - latitude;
    double percentage = offset / boxHeight;
    double pixel = percentage * height;
    
    return pixel;
}

+(double) latitudeFromPixelWithHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andPixel: (double) pixel{
    return [self latitudeFromPixelWithHeight:height andBoundingBox:boundingBox andTileBoundingBox:boundingBox andPixel:pixel];
}

+(double) latitudeFromPixelWithHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andPixel: (double) pixel{
    
    double boxHeight = [tileBoundingBox.maxLatitude doubleValue] - [tileBoundingBox.minLatitude doubleValue];
    double percentage = pixel / height;
    double offset = percentage * boxHeight;
    double latitude = [boundingBox.maxLatitude doubleValue] - offset;
    
    return latitude;
}

+(GPKGBoundingBox *) boundingBoxWithX: (int) x andY: (int) y andZoom: (int) zoom{
    
    int tilesPerSide = [self tilesPerSideWithZoom:zoom];
    double tileWidthDegrees = [self tileWidthDegreesWithTilesPerSide:tilesPerSide];
    double tileHeightDegrees = [self tileHeightDegreesWithTilesPerSide:tilesPerSide];
    
    double minLon = -PROJ_WGS84_HALF_WORLD_LON_WIDTH + (x * tileWidthDegrees);
    double maxLon = minLon + tileWidthDegrees;
    
    double maxLat = PROJ_WGS84_HALF_WORLD_LAT_HEIGHT - (y * tileHeightDegrees);
    double minLat = maxLat - tileHeightDegrees;
    
    GPKGBoundingBox * box = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLon andMinLatitudeDouble:minLat andMaxLongitudeDouble:maxLon andMaxLatitudeDouble:maxLat];
    
    return box;
}

+(GPKGBoundingBox *) webMercatorBoundingBoxWithX: (int) x andY: (int) y andZoom: (int) zoom{
    return [self webMercatorBoundingBoxWithTileGrid:[[GPKGTileGrid alloc] initWithMinX:x andMinY:y andMaxX:x andMaxY:y] andZoom:zoom];
}

+(GPKGBoundingBox *) webMercatorBoundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    
    double tileSize = [self tileSizeWithZoom:zoom];
    
    double minLon = (-1 * PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH)
				+ (tileGrid.minX * tileSize);
    double maxLon = (-1 * PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH)
				+ ((tileGrid.maxX + 1) * tileSize);
    double minLat = PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH
				- ((tileGrid.maxY + 1) * tileSize);
    double maxLat = PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH
				- (tileGrid.minY * tileSize);
    
    GPKGBoundingBox * box = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLon andMinLatitudeDouble:minLat andMaxLongitudeDouble:maxLon andMaxLatitudeDouble:maxLat];
    
    return box;
}

+(GPKGBoundingBox *) projectedBoundingBoxWithEpsg: (NSNumber *) epsg andX: (int) x andY: (int) y andZoom: (int) zoom{
    return [self projectedBoundingBoxWithAuthority:PROJ_AUTHORITY_EPSG andCode:epsg andX:x andY:y andZoom:zoom];
}

+(GPKGBoundingBox *) projectedBoundingBoxWithAuthority: (NSString *) authority andCode: (NSNumber *) code andX:(int)x andY:(int)y andZoom:(int)zoom{
    
    GPKGBoundingBox *boundingBox = [self webMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    if(code != nil){
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromAuthority:PROJ_AUTHORITY_EPSG andFromIntCode:PROJ_EPSG_WEB_MERCATOR andToAuthority:authority andToIntCode:[code intValue]];
        boundingBox = [boundingBox transform:transform];
    }
    
    return boundingBox;
}

+(GPKGBoundingBox *) projectedBoundingBoxWithProjection: (PROJProjection *) projection andX: (int) x andY: (int) y andZoom: (int) zoom{
    
    GPKGBoundingBox *boundingBox = [self webMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    if(projection != nil){
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromEpsg:PROJ_EPSG_WEB_MERCATOR andToProjection:projection];
        boundingBox = [boundingBox transform:transform];
    }
    
    return boundingBox;
}

+(GPKGBoundingBox *) projectedBoundingBoxWithEpsg: (NSNumber *) epsg andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    return [self projectedBoundingBoxWithAuthority:PROJ_AUTHORITY_EPSG andCode:epsg andTileGrid:tileGrid andZoom:zoom];
}

+(GPKGBoundingBox *) projectedBoundingBoxWithAuthority: (NSString *) authority andCode: (NSNumber *) code andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    
    GPKGBoundingBox *boundingBox = [self webMercatorBoundingBoxWithTileGrid:tileGrid andZoom:zoom];
    
    if(code != nil){
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromAuthority:PROJ_AUTHORITY_EPSG andFromIntCode:PROJ_EPSG_WEB_MERCATOR andToAuthority:authority andToIntCode:[code intValue]];
        boundingBox = [boundingBox transform:transform];
    }
    
    return boundingBox;
}

+(GPKGBoundingBox *) projectedBoundingBoxWithProjection: (PROJProjection *) projection andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    
    GPKGBoundingBox *boundingBox = [self webMercatorBoundingBoxWithTileGrid:tileGrid andZoom:zoom];
    
    if(projection != nil){
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromEpsg:PROJ_EPSG_WEB_MERCATOR andToProjection:projection];
        boundingBox = [boundingBox transform:transform];
    }
    
    return boundingBox;
}

+(GPKGBoundingBox *) boundingBoxAsWGS84WithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    return [self projectedBoundingBoxWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM] andTileGrid:tileGrid andZoom:zoom];
}

+(GPKGBoundingBox *) projectedBoundingBoxFromWGS84WithEpsg: (NSNumber *) epsg andX: (int) x andY: (int) y andZoom: (int) zoom{
    return [self projectedBoundingBoxFromWGS84WithAuthority:PROJ_AUTHORITY_EPSG andCode:epsg andX:x andY:y andZoom:zoom];
}

+(GPKGBoundingBox *) projectedBoundingBoxFromWGS84WithAuthority: (NSString *) authority andCode: (NSNumber *) code andX:(int)x andY:(int)y andZoom:(int)zoom{
    
    GPKGBoundingBox *boundingBox = [self wgs84BoundingBoxWithX:x andY:y andZoom:zoom];
    
    if(code != nil){
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromAuthority:PROJ_AUTHORITY_EPSG andFromIntCode:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToAuthority:authority andToIntCode:[code intValue]];
        boundingBox = [boundingBox transform:transform];
    }
    
    return boundingBox;
}

+(GPKGBoundingBox *) projectedBoundingBoxFromWGS84WithProjection: (PROJProjection *) projection andX: (int) x andY: (int) y andZoom: (int) zoom{
    
    GPKGBoundingBox *boundingBox = [self wgs84BoundingBoxWithX:x andY:y andZoom:zoom];
    
    if(projection != nil){
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToProjection:projection];
        boundingBox = [boundingBox transform:transform];
    }
    
    return boundingBox;
}

+(GPKGBoundingBox *) projectedBoundingBoxFromWGS84WithEpsg: (NSNumber *) epsg andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    return [self projectedBoundingBoxFromWGS84WithAuthority:PROJ_AUTHORITY_EPSG andCode:epsg andTileGrid:tileGrid andZoom:zoom];
}

+(GPKGBoundingBox *) projectedBoundingBoxFromWGS84WithAuthority: (NSString *) authority andCode: (NSNumber *) code andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    
    GPKGBoundingBox *boundingBox = [self wgs84BoundingBoxWithTileGrid:tileGrid andZoom:zoom];
    
    if(code != nil){
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromAuthority:PROJ_AUTHORITY_EPSG andFromIntCode:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToAuthority:authority andToIntCode:[code intValue]];
        boundingBox = [boundingBox transform:transform];
    }
    
    return boundingBox;
}

+(GPKGBoundingBox *) projectedBoundingBoxFromWGS84WithProjection: (PROJProjection *) projection andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    
    GPKGBoundingBox *boundingBox = [self wgs84BoundingBoxWithTileGrid:tileGrid andZoom:zoom];
    
    if(projection != nil){
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToProjection:projection];
        boundingBox = [boundingBox transform:transform];
    }
    
    return boundingBox;
}

+(GPKGTileGrid *) tileGridFromWGS84Point: (SFPoint *) point andZoom: (int) zoom{
    PROJProjection * projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    return [GPKGTileBoundingBoxUtils tileGridFromPoint:point andZoom:zoom andProjection:projection];
}

+(GPKGTileGrid *) tileGridFromPoint: (SFPoint *) point andZoom: (int) zoom andProjection: (PROJProjection *) projection{
    SFPGeometryTransform *toWebMercator = [SFPGeometryTransform transformFromProjection:projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    SFPoint * webMercatorPoint = [toWebMercator transformPoint:point];
    return [self tileGridFromWebMercatorPoint:webMercatorPoint andZoom:zoom];
}

+(GPKGTileGrid *) tileGridFromWebMercatorPoint: (SFPoint *) point andZoom: (int) zoom{
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitude:point.x andMinLatitude:point.y andMaxLongitude:point.x andMaxLatitude:point.y];
    return [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:boundingBox andZoom:zoom];
}

+(GPKGTileGrid *) tileGridWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox andZoom: (int) zoom{
    
    int tilesPerSide = [self tilesPerSideWithZoom:zoom];
    double tileSize = [self tileSizeWithTilesPerSide:tilesPerSide];
    
    int minX = (int) (([webMercatorBoundingBox.minLongitude doubleValue] + PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH) / tileSize);
    double tempMaxX = ([webMercatorBoundingBox.maxLongitude doubleValue] + PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH) / tileSize;
    int maxX = (int) tempMaxX;
    if(fmod(tempMaxX, 1) == 0) {
        maxX--;
    }
    maxX = MIN(maxX, tilesPerSide - 1);
    
    int minY = (int) ((([webMercatorBoundingBox.maxLatitude doubleValue] - PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH) * -1) / tileSize);
    double tempMaxY = (([webMercatorBoundingBox.minLatitude doubleValue] - PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH) * -1) / tileSize;
    int maxY = (int) tempMaxY;
    if(fmod(tempMaxY, 1) == 0) {
        maxY--;
    }
    maxY = MIN(maxY, tilesPerSide - 1);
    
    GPKGTileGrid * grid = [[GPKGTileGrid alloc] initWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY];
    
    return grid;
}

+(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection andPoint: (SFPoint *) point andZoom: (int) zoom{
    GPKGTileGrid *tileGrid = [self tileGridFromPoint:point andZoom:zoom andProjection:projection];
    return [self projectedBoundingBoxWithProjection:projection andTileGrid:tileGrid andZoom:zoom];
}

+(GPKGBoundingBox *) tileBoundsForWGS84Point: (SFPoint *) point andZoom: (int) zoom{
    PROJProjection *projection = [PROJProjectionFactory projectionWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    return [self tileBoundsInProjection:projection andPoint:point andZoom:zoom];
}

+(GPKGBoundingBox *) tileBoundsForWebMercatorPoint: (SFPoint *) point andZoom: (int) zoom{
    PROJProjection *projection = [PROJProjectionFactory projectionWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    return [self tileBoundsInProjection:projection andPoint:point andZoom:zoom];
}

+(GPKGBoundingBox *) wgs84TileBoundsInProjection: (PROJProjection *) projection andPoint: (SFPoint *) point andZoom: (int) zoom{
    GPKGTileGrid *tileGrid = [self tileGridWGS84FromPoint:point andZoom:zoom andProjection:projection];
    return [self projectedBoundingBoxFromWGS84WithProjection:projection andTileGrid:tileGrid andZoom:zoom];
}

+(GPKGBoundingBox *) wgs84TileBoundsForWGS84Point: (SFPoint *) point andZoom: (int) zoom{
    PROJProjection *projection = [PROJProjectionFactory projectionWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    return [self wgs84TileBoundsInProjection:projection andPoint:point andZoom:zoom];
}

+(GPKGBoundingBox *) wgs84TileBoundsForWebMercatorPoint: (SFPoint *) point andZoom: (int) zoom{
    PROJProjection *projection = [PROJProjectionFactory projectionWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    return [self wgs84TileBoundsInProjection:projection andPoint:point andZoom:zoom];
}

+(GPKGBoundingBox *) toWebMercatorWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    
    double minLatitude = MAX([boundingBox.minLatitude doubleValue], PROJ_WEB_MERCATOR_MIN_LAT_RANGE);
    double maxLatitude = MIN([boundingBox.maxLatitude doubleValue], PROJ_WEB_MERCATOR_MAX_LAT_RANGE);
    
    SFPoint *lowerLeftPoint = [SFPoint pointWithHasZ:NO andHasM:NO andX:boundingBox.minLongitude andY:[[NSDecimalNumber alloc] initWithDouble:minLatitude]];
    SFPoint *upperRightPoint = [SFPoint pointWithHasZ:NO andHasM:NO andX:boundingBox.maxLongitude andY:[[NSDecimalNumber alloc] initWithDouble:maxLatitude]];
    
    SFPGeometryTransform *toWebMercator = [SFPGeometryTransform transformFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    lowerLeftPoint = [toWebMercator transformPoint:lowerLeftPoint];
    upperRightPoint = [toWebMercator transformPoint:upperRightPoint];
    
    GPKGBoundingBox * mercatorBox = [[GPKGBoundingBox alloc] initWithMinLongitude:lowerLeftPoint.x andMinLatitude:lowerLeftPoint.y andMaxLongitude:upperRightPoint.x andMaxLatitude:upperRightPoint.y];
    
    return mercatorBox;
}

+(double) tileSizeWithTilesPerSide: (int) tilesPerSide{
    return [self tileSizeWithTilesPerSide:tilesPerSide andTotalLength:2 * PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH];
}

+(double) zoomLevelOfTileSize: (double) tileSize{
    return [self zoomLevelOfTileSize:tileSize andTotalLength:2 * PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH];
}

+(double) tileSizeWithTilesPerSide: (int) tilesPerSide andTotalLength: (double) totalLength{
    return totalLength / tilesPerSide;
}

+(double) zoomLevelOfTileSize: (double) tileSize andTotalLength: (double) totalLength{
    double tilesPerSide = totalLength / tileSize;
    double zoom = log(tilesPerSide) / log(2);
    return zoom;
}

+(double) tileSizeWithZoom: (int) zoom andTotalLength: (double) totalLength{
    int tilesPerSide = [self tilesPerSideWithZoom:zoom];
    double tileSize = [self tileSizeWithTilesPerSide:tilesPerSide andTotalLength:totalLength];
    return tileSize;
}

+(double) tileWidthDegreesWithTilesPerSide: (int) tilesPerSide{
    return (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH) / tilesPerSide;
}

+(double) tileHeightDegreesWithTilesPerSide: (int) tilesPerSide{
    return PROJ_WGS84_HALF_WORLD_LON_WIDTH / tilesPerSide;
}

+(int) tilesPerSideWithZoom: (int) zoom{
    return (int) pow(2, zoom);
}

+(double) tileSizeWithZoom: (int) zoom{
    int tilesPerSide = [self tilesPerSideWithZoom:zoom];
    double tileSize = [self tileSizeWithTilesPerSide:tilesPerSide];
    return tileSize;
}

+(double) toleranceDistanceWithZoom: (int) zoom andPixels: (int) pixels{
    double tileSize = [self tileSizeWithZoom:zoom];
    double tolerance = tileSize / pixels;
    return tolerance;
}

+(double) toleranceDistanceWithZoom: (int) zoom andPixelWidth: (int) pixelWidth andPixelHeight: (int) pixelHeight{
    return [self toleranceDistanceWithZoom:zoom andPixels:MAX(pixelWidth, pixelHeight)];
}

+(int) yAsOppositeTileFormatWithZoom: (int) zoom andY: (int) y{
    int tilesPerSide = [self tilesPerSideWithZoom:zoom];
    int oppositeY = tilesPerSide - y - 1;
    return oppositeY;
}

+(int) zoomFromTilesPerSide: (int) tilesPerSide{
    return (int) (log(tilesPerSide) / log(2));
}

+(GPKGTileGrid *) tileGridWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andMatrixWidth: (int) matrixWidth andMatrixHeight: (int) matrixHeight andBoundingBox: (GPKGBoundingBox *) boundingBox{
    
    int minColumn = [self tileColumnWithTotalBoundingBox:totalBox andMatrixWidth:matrixWidth andLongitude:[boundingBox.minLongitude doubleValue]];
    int maxColumn = [self tileColumnWithTotalBoundingBox:totalBox andMatrixWidth:matrixWidth andLongitude:[boundingBox.maxLongitude doubleValue]];
    
    if(minColumn < matrixWidth && maxColumn >= 0){
        if(minColumn < 0){
            minColumn = 0;
        }
        if(maxColumn >= matrixWidth){
            maxColumn = matrixWidth - 1;
        }
    }
    
    int maxRow = [self tileRowWithTotalBoundingBox:totalBox andMatrixHeight:matrixHeight andLatitude:[boundingBox.minLatitude doubleValue]];
    int minRow = [self tileRowWithTotalBoundingBox:totalBox andMatrixHeight:matrixHeight andLatitude:[boundingBox.maxLatitude doubleValue]];
    
    if(minRow < matrixHeight && maxRow >= 0){
        if(minRow < 0){
            minRow = 0;
        }
        if(maxRow >= matrixHeight){
            maxRow = matrixHeight - 1;
        }
    }
    
    GPKGTileGrid * tileGrid = [[GPKGTileGrid alloc] initWithMinX:minColumn andMinY:minRow andMaxX:maxColumn andMaxY:maxRow];
    
    return tileGrid;
}

+(int) tileColumnWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andMatrixWidth: (int) matrixWidth andLongitude: (double) longitude{
    
    double minX = [totalBox.minLongitude doubleValue];
    double maxX = [totalBox.maxLongitude doubleValue];
    
    int tileId;
    if(longitude < minX){
        tileId = -1;
    }else if(longitude >= maxX){
        tileId = matrixWidth;
    }else{
        double matrixWidthMeters = maxX - minX;
        double tileWidth = matrixWidthMeters / matrixWidth;
        tileId = (int) ((longitude - minX) / tileWidth);
    }
    
    return tileId;
}

+(int) tileRowWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andMatrixHeight: (int) matrixHeight andLatitude: (double) latitude{
    
    double minY = [totalBox.minLatitude doubleValue];
    double maxY = [totalBox.maxLatitude doubleValue];
    
    int tileId;
    if(latitude < minY){
        tileId = matrixHeight;
    }else if(latitude >= maxY){
        tileId = -1;
    }else{
        double matrixHeightMeters = maxY - minY;
        double tileHeight = matrixHeightMeters / matrixHeight;
        tileId = (int) ((maxY - latitude) / tileHeight);
    }
    
    return tileId;
}

+(GPKGBoundingBox *) boundingBoxWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andTileColumn: (int) tileColumn andTileRow: (int) tileRow{
    return [self boundingBoxWithTotalBoundingBox:totalBox andTileMatrixWidth:[tileMatrix.matrixWidth intValue] andTileMatrixHeight:[tileMatrix.matrixHeight intValue] andTileColumn:tileColumn andTileRow:tileRow];
}

+(GPKGBoundingBox *) boundingBoxWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andTileMatrixWidth: (int) tileMatrixWidth andTileMatrixHeight: (int) tileMatrixHeight andTileColumn: (int) tileColumn andTileRow: (int) tileRow{
    GPKGTileGrid * tileGrid = [[GPKGTileGrid alloc] initWithMinX:tileColumn andMinY:tileRow andMaxX:tileColumn andMaxY:tileRow];
    return [self boundingBoxWithTotalBoundingBox:totalBox andTileMatrixWidth:tileMatrixWidth andTileMatrixHeight:tileMatrixHeight andTileGrid:tileGrid];
}

+(GPKGBoundingBox *) boundingBoxWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andTileGrid: (GPKGTileGrid *) tileGrid{
    return [self boundingBoxWithTotalBoundingBox:totalBox andTileMatrixWidth:[tileMatrix.matrixWidth intValue] andTileMatrixHeight:[tileMatrix.matrixHeight intValue] andTileGrid:tileGrid];
}

+(GPKGBoundingBox *) boundingBoxWithTotalBoundingBox: (GPKGBoundingBox *) totalBox andTileMatrixWidth: (int) tileMatrixWidth andTileMatrixHeight: (int) tileMatrixHeight andTileGrid: (GPKGTileGrid *) tileGrid{
    
    // Get the tile width
    double matrixMinX = [totalBox.minLongitude doubleValue];
    double matrixMaxX = [totalBox.maxLongitude doubleValue];
    double matrixWidth = matrixMaxX - matrixMinX;
    double tileWidth = matrixWidth / tileMatrixWidth;
    
    // Find the longitude range
    double minLon = matrixMinX + (tileWidth * tileGrid.minX);
    double maxLon = matrixMinX + (tileWidth * (tileGrid.maxX + 1));
    
    // Get the tile height
    double matrixMinY = [totalBox.minLatitude doubleValue];
    double matrixMaxY = [totalBox.maxLatitude doubleValue];
    double matrixHeight = matrixMaxY - matrixMinY;
    double tileHeight = matrixHeight / tileMatrixHeight;
    
    // Find the latitude range
    double maxLat = matrixMaxY - (tileHeight * tileGrid.minY);
    double minLat = matrixMaxY - (tileHeight * (tileGrid.maxY + 1));
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLon andMinLatitudeDouble:minLat andMaxLongitudeDouble:maxLon andMaxLatitudeDouble:maxLat];
    
    return boundingBox;
}

+(int) zoomLevelWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox{
    
    double worldLength = PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH * 2;
    
    double longitudeDistance = [webMercatorBoundingBox.maxLongitude doubleValue] - [webMercatorBoundingBox.minLongitude doubleValue];
    double latitudeDistance = [webMercatorBoundingBox.maxLatitude doubleValue] - [webMercatorBoundingBox.minLatitude doubleValue];
    
    int maxZoom = [[GPKGProperties numberValueOfProperty:GPKG_PROP_MAX_ZOOM_LEVEL] intValue];
    
    int zoom;
    if(longitudeDistance > 0 && latitudeDistance > 0){
    
        int widthTiles = (int) (worldLength / longitudeDistance);
        int heightTiles = (int) (worldLength / latitudeDistance);
        
        int tilesPerSide = MIN(widthTiles, heightTiles);
        tilesPerSide = MAX(tilesPerSide, 1);
        
        zoom = [self zoomFromTilesPerSide:tilesPerSide];
        tilesPerSide = MIN(maxZoom, zoom);
    }else{
        zoom = maxZoom;
    }
    
    return zoom;
}

+(CLLocationCoordinate2D) locationWithBearing: (double) bearing andDistance: (double) meters fromLocation: (CLLocationCoordinate2D) location{
    
    const double distRadians = meters / GPKG_EARTH_RADIUS;
    
    double rbearing = degreesToRadians(bearing);
    
    float lat1 = degreesToRadians(location.latitude);
    float lon1 = degreesToRadians(location.longitude);
    
    float lat2 = asin( sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(rbearing));
    float lon2 = lon1 + atan2( sin(rbearing) * sin(distRadians) * cos(lat1),
                              cos(distRadians) - sin(lat1) * sin(lat2) );
    
    CLLocationCoordinate2D newPoint = CLLocationCoordinate2DMake(radiansToDegrees(lat2), radiansToDegrees(lon2));
    
    return newPoint;
}

+(double) bearingFromLocation: (CLLocationCoordinate2D) from andToLocation: (CLLocationCoordinate2D) to{
    double fromLat = degreesToRadians(from.latitude);
    double fromLong = degreesToRadians(from.longitude);
    double toLat = degreesToRadians(to.latitude);
    double toLong = degreesToRadians(to.longitude);
    
    double degree = radiansToDegrees(atan2(sin(toLong-fromLong)*cos(toLat), cos(fromLat)*sin(toLat)-sin(fromLat)*cos(toLat)*cos(toLong-fromLong)));
    
    if(degree < 0){
        degree += 360;
    }
    
    return degree;
}

+(double) distanceBetweenLocation: (CLLocationCoordinate2D) location1 andLocation: (CLLocationCoordinate2D) location2{
    CLLocation * loc1 = [[CLLocation alloc] initWithLatitude:location1.latitude longitude:location1.longitude];
    CLLocation * loc2 = [[CLLocation alloc] initWithLatitude:location2.latitude longitude:location2.longitude];
    double distance = [loc1 distanceFromLocation:loc2];
    return distance;
}

+(CLLocationCoordinate2D) pointBetweenFromLocation: (CLLocationCoordinate2D) from andToLocation: (CLLocationCoordinate2D) to{
    
    CLLocationCoordinate2D point;
    
    double distance = [self distanceBetweenLocation:from andLocation:to];
    if(distance == 0){
        point = CLLocationCoordinate2DMake(from.latitude, from.longitude);
    }else{
        double heading = [self bearingFromLocation:from andToLocation:to];
        point = [self locationWithBearing:heading andDistance:(distance/2.0) fromLocation:from];
    }
    return point;
}

+(GPKGBoundingBox *) boundWebMercatorBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGBoundingBox *bounded = [boundingBox mutableCopy];
    if([bounded.minLongitude doubleValue] < -PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH){
        [bounded setMinLongitude:[[NSDecimalNumber alloc] initWithDouble:-PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH]];
    }
    if([bounded.maxLongitude doubleValue] > PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH){
        [bounded setMaxLongitude:[[NSDecimalNumber alloc] initWithDouble:PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH]];
    }
    if([bounded.minLatitude doubleValue] < -PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH){
        [bounded setMinLatitude:[[NSDecimalNumber alloc] initWithDouble:-PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH]];
    }
    if([bounded.maxLatitude doubleValue] > PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH){
        [bounded setMaxLatitude:[[NSDecimalNumber alloc] initWithDouble:PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH]];
    }
    return bounded;
}

+(GPKGBoundingBox *) boundWgs84BoundingBoxWithWebMercatorLimits: (GPKGBoundingBox *) boundingBox{
    return [self boundDegreesBoundingBoxWithWebMercatorLimits:boundingBox];
}

+(GPKGBoundingBox *) boundDegreesBoundingBoxWithWebMercatorLimits: (GPKGBoundingBox *) boundingBox{
    GPKGBoundingBox * bounded = [boundingBox mutableCopy];
    if([bounded.minLatitude doubleValue] < PROJ_WEB_MERCATOR_MIN_LAT_RANGE){
        [bounded setMinLatitude:[[NSDecimalNumber alloc] initWithDouble:PROJ_WEB_MERCATOR_MIN_LAT_RANGE]];
    }
    if([bounded.maxLatitude doubleValue] < PROJ_WEB_MERCATOR_MIN_LAT_RANGE){
        [bounded setMaxLatitude:[[NSDecimalNumber alloc] initWithDouble:PROJ_WEB_MERCATOR_MIN_LAT_RANGE]];
    }
    if([bounded.maxLatitude doubleValue] > PROJ_WEB_MERCATOR_MAX_LAT_RANGE){
        [bounded setMaxLatitude:[[NSDecimalNumber alloc] initWithDouble:PROJ_WEB_MERCATOR_MAX_LAT_RANGE]];
    }
    if([bounded.minLatitude doubleValue] > PROJ_WEB_MERCATOR_MAX_LAT_RANGE){
        [bounded setMinLatitude:[[NSDecimalNumber alloc] initWithDouble:PROJ_WEB_MERCATOR_MAX_LAT_RANGE]];
    }
    return bounded;
}

+(CGRect) rectangleWithWidth: (int) width andHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andSection: (GPKGBoundingBox *) boundingBoxSection{
    
    double left = [GPKGTileBoundingBoxUtils xPixelWithWidth:width andBoundingBox:boundingBox andLongitude:[boundingBoxSection.minLongitude doubleValue]];
    double right = [GPKGTileBoundingBoxUtils xPixelWithWidth:width andBoundingBox:boundingBox andLongitude:[boundingBoxSection.maxLongitude doubleValue]];
    double top = [GPKGTileBoundingBoxUtils yPixelWithHeight:height andBoundingBox:boundingBox andLatitude:[boundingBoxSection.maxLatitude doubleValue]];
    double bottom = [GPKGTileBoundingBoxUtils yPixelWithHeight:height andBoundingBox:boundingBox andLatitude:[boundingBoxSection.minLatitude doubleValue]];
    
    CGRect rect = CGRectMake(left, top, right - left, bottom - top);
    
    return rect;
}

+(CGRect) roundedRectangleWithWidth: (int) width andHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andSection: (GPKGBoundingBox *) boundingBoxSection{
    
    double left = [GPKGTileBoundingBoxUtils xPixelWithWidth:width andBoundingBox:boundingBox andLongitude:[boundingBoxSection.minLongitude doubleValue]];
    double right = [GPKGTileBoundingBoxUtils xPixelWithWidth:width andBoundingBox:boundingBox andLongitude:[boundingBoxSection.maxLongitude doubleValue]];
    double top = [GPKGTileBoundingBoxUtils yPixelWithHeight:height andBoundingBox:boundingBox andLatitude:[boundingBoxSection.maxLatitude doubleValue]];
    double bottom = [GPKGTileBoundingBoxUtils yPixelWithHeight:height andBoundingBox:boundingBox andLatitude:[boundingBoxSection.minLatitude doubleValue]];
    
    double leftRounded = round(left);
    double rightRounded = round(right);
    double topRounded = round(top);
    double bottomRounded = round(bottom);
    
    CGRect rect = CGRectMake(leftRounded, topRounded, rightRounded - leftRounded, bottomRounded - topRounded);
    
    return rect;
}

+(GPKGTileGrid *) tileGridWGS84FromWGS84Point: (SFPoint *) point andZoom: (int) zoom{
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitude:point.x andMinLatitude:point.y andMaxLongitude:point.x andMaxLatitude:point.y];
    return [self tileGridWithWgs84BoundingBox:boundingBox andZoom:zoom];
}

+(GPKGTileGrid *) tileGridWGS84FromPoint: (SFPoint *) point andZoom: (int) zoom andProjection: (PROJProjection *) projection{
    SFPGeometryTransform *toWGS84 = [SFPGeometryTransform transformFromProjection:projection andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    SFPoint *wgs84Point = [toWGS84 transformPoint:point];
    return [self tileGridWGS84FromWGS84Point:wgs84Point andZoom:zoom];
}

+(GPKGTileGrid *) tileGridWGS84FromWebMercatorPoint: (SFPoint *) point andZoom: (int) zoom{
    PROJProjection *projection = [PROJProjectionFactory projectionWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    return [self tileGridWGS84FromPoint:point andZoom:zoom andProjection:projection];
}

+(GPKGTileGrid *) tileGridWithWgs84BoundingBox: (GPKGBoundingBox *) wgs84BoundingBox andZoom: (int) zoom{
    
    int tilesPerLat = [self tilesPerWgs84LatSideWithZoom:zoom];
    int tilesPerLon = [self tilesPerWgs84LonSideWithZoom:zoom];
    
    double tileSizeLat = [self tileSizeLatWithWgs84TilesPerSide:tilesPerLat];
    double tileSizeLon = [self tileSizeLonWithWgs84TilesPerSide:tilesPerLon];
    
    int minX = (int) (([wgs84BoundingBox.minLongitude doubleValue] + PROJ_WGS84_HALF_WORLD_LON_WIDTH) / tileSizeLon);
    double tempMaxX = ([wgs84BoundingBox.maxLongitude doubleValue] + PROJ_WGS84_HALF_WORLD_LON_WIDTH) / tileSizeLon;
    int maxX = (int) tempMaxX;
    if(fmod(tempMaxX, 1) == 0) {
        maxX--;
    }
    maxX = MIN(maxX, tilesPerLon - 1);
    
    int minY = (int) ((([wgs84BoundingBox.maxLatitude doubleValue] - PROJ_WGS84_HALF_WORLD_LAT_HEIGHT) * -1) / tileSizeLat);
    double tempMaxY = (([wgs84BoundingBox.minLatitude doubleValue] - PROJ_WGS84_HALF_WORLD_LAT_HEIGHT) * -1) / tileSizeLat;
    int maxY = (int) tempMaxY;
    if(fmod(tempMaxY, 1) == 0) {
        maxY--;
    }
    maxY = MIN(maxY, tilesPerLat - 1);
    
    GPKGTileGrid * grid = [[GPKGTileGrid alloc] initWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY];
    
    return grid;
}

+(GPKGBoundingBox *) wgs84BoundingBoxWithX: (int) x andY: (int) y andZoom: (int) zoom{
    return [self wgs84BoundingBoxWithTileGrid:[[GPKGTileGrid alloc] initWithMinX:x andMinY:y andMaxX:x andMaxY:y] andZoom:zoom];
}

+(GPKGBoundingBox *) wgs84BoundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    
    int tilesPerLat = [self tilesPerWgs84LatSideWithZoom:zoom];
    int tilesPerLon = [self tilesPerWgs84LonSideWithZoom:zoom];
    
    double tileSizeLat = [self tileSizeLatWithWgs84TilesPerSide:tilesPerLat];
    double tileSizeLon = [self tileSizeLonWithWgs84TilesPerSide:tilesPerLon];
    
    double minLon = (-1 * PROJ_WGS84_HALF_WORLD_LON_WIDTH)
				+ (tileGrid.minX * tileSizeLon);
    double maxLon = (-1 * PROJ_WGS84_HALF_WORLD_LON_WIDTH)
				+ ((tileGrid.maxX + 1) * tileSizeLon);
    double minLat = PROJ_WGS84_HALF_WORLD_LAT_HEIGHT
				- ((tileGrid.maxY + 1) * tileSizeLat);
    double maxLat = PROJ_WGS84_HALF_WORLD_LAT_HEIGHT
				- (tileGrid.minY * tileSizeLat);
    
    GPKGBoundingBox * box = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLon andMinLatitudeDouble:minLat andMaxLongitudeDouble:maxLon andMaxLatitudeDouble:maxLat];
    
    return box;
}

+(int) tilesPerWgs84LatSideWithZoom: (int) zoom{
    return [self tilesPerSideWithZoom:zoom];
}

+(int) tilesPerWgs84LonSideWithZoom: (int) zoom{
    return 2 * [self tilesPerSideWithZoom:zoom];
}

+(double) tileSizeLatWithWgs84TilesPerSide: (int) tilesPerLat{
    return (2 * PROJ_WGS84_HALF_WORLD_LAT_HEIGHT)
				/ tilesPerLat;
}

+(double) tileSizeLonWithWgs84TilesPerSide: (int) tilesPerLon{
    return (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH)
				/ tilesPerLon;
}

+(GPKGTileGrid *) tileGrid: (GPKGTileGrid *) tileGrid zoomFrom: (int) fromZoom to: (int) toZoom{
    
    GPKGTileGrid *newTileGrid = nil;
    
    int zoomChange = toZoom - fromZoom;
    if(zoomChange > 0){
        newTileGrid = [self tileGrid:tileGrid zoomIncrease:zoomChange];
    }else if(zoomChange < 0){
        zoomChange = abs(zoomChange);
        newTileGrid = [self tileGrid:tileGrid zoomDecrease:zoomChange];
    }else{
        newTileGrid = tileGrid;
    }
    
    return newTileGrid;
}

+(GPKGTileGrid *) tileGrid: (GPKGTileGrid *) tileGrid zoomIncrease: (int) zoomLevels{
    int minX = [self tileGridMin:tileGrid.minX zoomIncrease:zoomLevels];
    int maxX = [self tileGridMax:tileGrid.maxX zoomIncrease:zoomLevels];
    int minY = [self tileGridMin:tileGrid.minY zoomIncrease:zoomLevels];
    int maxY = [self tileGridMax:tileGrid.maxY zoomIncrease:zoomLevels];
    GPKGTileGrid *newTileGrid = [[GPKGTileGrid alloc] initWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY];
    return newTileGrid;
}

+(GPKGTileGrid *) tileGrid: (GPKGTileGrid *) tileGrid zoomDecrease: (int) zoomLevels{
    int minX = [self tileGridMin:tileGrid.minX zoomDecrease:zoomLevels];
    int maxX = [self tileGridMax:tileGrid.maxX zoomDecrease:zoomLevels];
    int minY = [self tileGridMin:tileGrid.minY zoomDecrease:zoomLevels];
    int maxY = [self tileGridMax:tileGrid.maxY zoomDecrease:zoomLevels];
    GPKGTileGrid *newTileGrid = [[GPKGTileGrid alloc] initWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY];
    return newTileGrid;
}

+(int) tileGridMin: (int) min zoomIncrease: (int) zoomLevels{
    return min * pow(2, zoomLevels);
}

+(int) tileGridMax: (int) max zoomIncrease: (int) zoomLevels{
    return (max + 1) * pow(2, zoomLevels) - 1;
}

+(int) tileGridMin: (int) min zoomDecrease: (int) zoomLevels{
    return floor(min / pow(2, zoomLevels));
}

+(int) tileGridMax: (int) max zoomDecrease: (int) zoomLevels{
    return ceil((max + 1) / pow(2, zoomLevels) - 1);
}

@end
