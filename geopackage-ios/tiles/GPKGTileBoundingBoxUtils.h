//
//  GPKGTileBoundingBoxUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGBoundingBox.h"
#import "GPKGTileGrid.h"
#import "GPKGProjection.h"
#import "GPKGTileMatrix.h"

@interface GPKGTileBoundingBoxUtils : NSObject

+(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2;

+(GPKGBoundingBox *) unionWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2;

+(double) getXPixelWithWidth: (int) width andBoundingBox: (GPKGBoundingBox *) boundingBox andLongitude: (double) longitude;

+(double) getLongitudeFromPixelWithWidth: (int) width andBoundingBox: (GPKGBoundingBox *) boundingBox andPixel: (double) pixel;

+(double) getYPixelWithHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andLatitude: (double) latitude;

+(double) getLatitudeFromPixelWithHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andPixel: (double) pixel;

+(GPKGBoundingBox *) getBoundingBoxWithX: (int) x andY: (int) y andZoom: (int) zoom;

+(GPKGBoundingBox *) getWebMercatorBoundingBoxWithX: (int) x andY: (int) y andZoom: (int) zoom;

+(GPKGBoundingBox *) getWebMercatorBoundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

+(GPKGBoundingBox *) getProjectedBoundingBoxWithProjectionEpsg: (NSNumber *) projectionEpsg andX: (int) x andY: (int) y andZoom: (int) zoom;

+(GPKGBoundingBox *) getProjectedBoundingBoxWithProjection: (GPKGProjection *) projection andX: (int) x andY: (int) y andZoom: (int) zoom;

+(GPKGBoundingBox *) getProjectedBoundingBoxWithProjectionEpsg: (NSNumber *) projectionEpsg andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

+(GPKGBoundingBox *) getProjectedBoundingBoxWithProjection: (GPKGProjection *) projection andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

+(GPKGTileGrid *) getTileGridWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox andZoom: (int) zoom;

+(GPKGBoundingBox *) toWebMercatorWithBoundingBox: (GPKGBoundingBox *) boundingBox;

+(double) tileSizeWithTilesPerSide: (int) tilesPerSide;

+(double) tileWidthDegreesWithTilesPerSide: (int) tilesPerSide;

+(double) tileHeightDegreesWithTilesPerSide: (int) tilesPerSide;

+(int) tilesPerSideWithZoom: (int) zoom;

+(int) zoomFromTilesPerSide: (int) tilesPerSide;

+(GPKGTileGrid *) getTileGridWithWebMercatorTotalBoundingBox: (GPKGBoundingBox *) webMercatorTotalBox andMatrixWidth: (int) matrixWidth andMatrixHeight: (int) matrixHeight andWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox;

+(int) getTileColumnWithWebMercatorTotalBoundingBox: (GPKGBoundingBox *) webMercatorTotalBox andMatrixWidth: (int) matrixWidth andLongitude: (double) longitude;

+(int) getTileRowWithWebMercatorTotalBoundingBox: (GPKGBoundingBox *) webMercatorTotalBox andMatrixHeight: (int) matrixHeight andLatitude: (double) latitude;

+(GPKGBoundingBox *) getWebMercatorBoundingBoxWithWebMercatorTotalBoundingBox: (GPKGBoundingBox *) webMercatorTotalBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andTileColumn: (int) tileColumn andTileRow: (int) tileRow;

+(int) getZoomLevelWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox;

+(CLLocationCoordinate2D) locationWithBearing: (double) bearing andDistance: (double) meters fromLocation: (CLLocationCoordinate2D) location;

+(double) bearingFromLocation: (CLLocationCoordinate2D) from andToLocation: (CLLocationCoordinate2D) to;

+(double) distanceBetweenLocation: (CLLocationCoordinate2D) location1 andLocation: (CLLocationCoordinate2D) location2;

+(CLLocationCoordinate2D) pointBetweenFromLocation: (CLLocationCoordinate2D) from andToLocation: (CLLocationCoordinate2D) to;

+(GPKGBoundingBox *) boundWgs84BoundingBoxWithWebMercatorLimits: (GPKGBoundingBox *) boundingBox;

@end
