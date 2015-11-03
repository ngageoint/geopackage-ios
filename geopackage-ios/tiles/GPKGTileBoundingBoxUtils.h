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
#import "WKBPoint.h"

/**
 *  Tile Bounding Box utility methods
 */
@interface GPKGTileBoundingBoxUtils : NSObject

/**
 *  Get the overlapping bounding box between the two bounding boxes
 *
 *  @param boundingBox  bounding box
 *  @param boundingBox2 bounding box 2
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2;

/**
 *  Get the union bounding box combining the two bounding boxes
 *
 *  @param boundingBox  bounding box
 *  @param boundingBox2 bounding box 2
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) unionWithBoundingBox: (GPKGBoundingBox *) boundingBox andBoundingBox: (GPKGBoundingBox *) boundingBox2;

/**
 *  Get the X pixel for where the longitude fits into the bounding box
 *
 *  @param width       width
 *  @param boundingBox bounding box
 *  @param longitude   longitude
 *
 *  @return x pixel
 */
+(double) getXPixelWithWidth: (int) width andBoundingBox: (GPKGBoundingBox *) boundingBox andLongitude: (double) longitude;

/**
 *  Get the longitude from the pixel location, bounding box, and image width
 *
 *  @param width       width
 *  @param boundingBox bounding box
 *  @param pixel       x pixel
 *
 *  @return longitude
 */
+(double) getLongitudeFromPixelWithWidth: (int) width andBoundingBox: (GPKGBoundingBox *) boundingBox andPixel: (double) pixel;

/**
 *  Get the Y pixel for where the latitude fits into the bounding box
 *
 *  @param height      height
 *  @param boundingBox bounding box
 *  @param latitude    latitude
 *
 *  @return y pixel
 */
+(double) getYPixelWithHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andLatitude: (double) latitude;

/**
 *  Get the latitude from the pixel location, bounding box, and image height
 *
 *  @param height      height
 *  @param boundingBox bounding box
 *  @param pixel       y pixel
 *
 *  @return latitude
 */
+(double) getLatitudeFromPixelWithHeight: (int) height andBoundingBox: (GPKGBoundingBox *) boundingBox andPixel: (double) pixel;

/**
 * Get the tile bounding box from the Standard Maps API tile coordinates and
 * zoom level
 *
 *  @param x    x
 *  @param y    y
 *  @param zoom zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) getBoundingBoxWithX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 * Get the Web Mercator tile bounding box from the Standard Maps API tile
 * coordinates and zoom level
 *
 *  @param x    x
 *  @param y    y
 *  @param zoom zoom level
 *
 *  @return web mercator bounding box
 */
+(GPKGBoundingBox *) getWebMercatorBoundingBoxWithX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 * Get the Web Mercator tile bounding box from the Standard Maps API tile grid
 * and zoom level
 *
 *  @param tileGrid tile grid
 *  @param zoom     zoom
 *
 *  @return web mercator bounding box
 */
+(GPKGBoundingBox *) getWebMercatorBoundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

/**
 * Get the Projected tile bounding box from the Standard Maps API tile
 * coordinates and zoom level
 *
 *  @param projectionEpsg projection epsg code
 *  @param x              x
 *  @param y              y
 *  @param zoom           zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) getProjectedBoundingBoxWithProjectionEpsg: (NSNumber *) projectionEpsg andX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 * Get the Projected tile bounding box from the Standard Maps API tile
 * coordinates and zoom level
 *
 *  @param projection     projection
 *  @param x              x
 *  @param y              y
 *  @param zoom           zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) getProjectedBoundingBoxWithProjection: (GPKGProjection *) projection andX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 * Get the Projected tile bounding box from the Standard Maps API tile
 * tileGrid and zoom level
 *
 *  @param projectionEpsg projection epsg code
 *  @param tileGrid       tile grid
 *  @param zoom           zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) getProjectedBoundingBoxWithProjectionEpsg: (NSNumber *) projectionEpsg andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

/**
 * Get the Projected tile bounding box from the Standard Maps API tile
 * tileGrid and zoom level
 *
 *  @param projection projection
 *  @param tileGrid   tile grid
 *  @param zoom       zoom level
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) getProjectedBoundingBoxWithProjection: (GPKGProjection *) projection andTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

/**
 *  Get the tile grid for the location specified as WGS84
 *
 *  @param point  WGS84 point
 *  @param zoom   zoom level
 *
 *  @return tile grid
 */
+(GPKGTileGrid *) getTileGridFromWGS84Point: (WKBPoint *) point andZoom: (int) zoom;

/**
 *  Get the tile grid for the location specified as the projection
 *
 *  @param point        point
 *  @param zoom         zoom level
 *  @param projection   point projection
 *
 *  @return tile grid
 */
+(GPKGTileGrid *) getTileGridFromPoint: (WKBPoint *) point andZoom: (int) zoom andProjection: (GPKGProjection *) projection;

/**
 *  Get the tile grid that includes the entire tile bounding box
 *
 *  @param webMercatorBoundingBox web mercator bounding box
 *  @param zoom                   zoom level
 *
 *  @return tile grid
 */
+(GPKGTileGrid *) getTileGridWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox andZoom: (int) zoom;

/**
 *  Convert the bounding box coordinates to a new web mercator bounding box
 *
 *  @param boundingBox bounding box
 *
 *  @return web mercator bounding box
 */
+(GPKGBoundingBox *) toWebMercatorWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Get the tile size in meters
 *
 *  @param tilesPerSide tiles per side
 *
 *  @return meters
 */
+(double) tileSizeWithTilesPerSide: (int) tilesPerSide;

/**
 *  Get the tile width in degrees
 *
 *  @param tilesPerSide tiles per side
 *
 *  @return degrees
 */
+(double) tileWidthDegreesWithTilesPerSide: (int) tilesPerSide;

/**
 *  Get the tile height in degrees
 *
 *  @param tilesPerSide tiles per side
 *
 *  @return degrees
 */
+(double) tileHeightDegreesWithTilesPerSide: (int) tilesPerSide;

/**
 *  Get the tiles per side, width and height, at the zoom level
 *
 *  @param zoom zoom level
 *
 *  @return tiles per side
 */
+(int) tilesPerSideWithZoom: (int) zoom;

/**
 *  Get the zoom level from the tiles per side
 *
 *  @param tilesPerSide tiles per side
 *
 *  @return zoom level
 */
+(int) zoomFromTilesPerSide: (int) tilesPerSide;

/**
 *  Get the tile grid
 *
 *  @param webMercatorTotalBox    web mercator total bounding box
 *  @param matrixWidth            matrix width
 *  @param matrixHeight           matrix height
 *  @param webMercatorBoundingBox web mercator bounding box
 *
 *  @return tile grid
 */
+(GPKGTileGrid *) getTileGridWithWebMercatorTotalBoundingBox: (GPKGBoundingBox *) webMercatorTotalBox andMatrixWidth: (int) matrixWidth andMatrixHeight: (int) matrixHeight andWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox;

/**
 *  Get the tile column of the longitude in degrees
 *
 *  @param webMercatorTotalBox web mercator total bounding box
 *  @param matrixWidth         matrix width
 *  @param longitude           longitude
 *
 *  @return tile column
 */
+(int) getTileColumnWithWebMercatorTotalBoundingBox: (GPKGBoundingBox *) webMercatorTotalBox andMatrixWidth: (int) matrixWidth andLongitude: (double) longitude;

/**
 *  Get the tile row of the latitude in degrees
 *
 *  @param webMercatorTotalBox web mercator total bounding box
 *  @param matrixHeight        matrix height
 *  @param latitude            latitude
 *
 *  @return tile row
 */
+(int) getTileRowWithWebMercatorTotalBoundingBox: (GPKGBoundingBox *) webMercatorTotalBox andMatrixHeight: (int) matrixHeight andLatitude: (double) latitude;

/**
 * Get the web mercator bounding box of the Tile Row from the Tile Matrix
 * zoom level
 *
 *  @param webMercatorTotalBox web mercator total bounding box
 *  @param tileMatrix          tile matrix
 *  @param tileColumn          tile column
 *  @param tileRow             tile row
 *
 *  @return web mercator bounding box
 */
+(GPKGBoundingBox *) getWebMercatorBoundingBoxWithWebMercatorTotalBoundingBox: (GPKGBoundingBox *) webMercatorTotalBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andTileColumn: (int) tileColumn andTileRow: (int) tileRow;

/**
 * Get the zoom level of where the web mercator bounding box fits into the
 * complete world
 *
 *  @param webMercatorBoundingBox web mercator bounding box
 *
 *  @return zoom level
 */
+(int) getZoomLevelWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox;

/**
 *  Get the location bearing a distance from a current location
 *
 *  @param bearing  bearing
 *  @param meters   meters
 *  @param location from location
 *
 *  @return to location
 */
+(CLLocationCoordinate2D) locationWithBearing: (double) bearing andDistance: (double) meters fromLocation: (CLLocationCoordinate2D) location;

/**
 *  Get the bearing from a location to a location
 *
 *  @param from from location
 *  @param to   to location
 *
 *  @return bearing
 */
+(double) bearingFromLocation: (CLLocationCoordinate2D) from andToLocation: (CLLocationCoordinate2D) to;

/**
 *  Get the distance between two locations
 *
 *  @param location1 location 1
 *  @param location2 location 2
 *
 *  @return distance in meters
 */
+(double) distanceBetweenLocation: (CLLocationCoordinate2D) location1 andLocation: (CLLocationCoordinate2D) location2;

/**
 *  Get the location point between two locations
 *
 *  @param from from location
 *  @param to   to location
 *
 *  @return between point
 */
+(CLLocationCoordinate2D) pointBetweenFromLocation: (CLLocationCoordinate2D) from andToLocation: (CLLocationCoordinate2D) to;

/**
 *  Bound the uppper and lower bounds of the WGS84 bounding box with web mercator limits
 *
 *  @param boundingBox wgs84 bounding box
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) boundWgs84BoundingBoxWithWebMercatorLimits: (GPKGBoundingBox *) boundingBox;

@end
