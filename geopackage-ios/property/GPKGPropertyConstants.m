//
//  GPKGPropertyConstants.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGPropertyConstants.h"

NSString * const GPKG_PROP_DIVIDER = @".";
NSString * const GPKG_PROP_DIR_GEOPACKAGE = @"geopackage.dir.geopackage";
NSString * const GPKG_PROP_DIR_DATABASE = @"geopackage.dir.geopackage.database";
NSString * const GPKG_PROP_DIR_METADATA = @"geopackage.dir.geopackage.metadata";
NSString * const GPKG_PROP_DIR_METADATA_FILE_DB = @"geopackage.dir.geopackage.metadata.file.db";
NSString * const GPKG_PROP_SRS_WGS_84 = @"geopackage.srs.wgs84";
NSString * const GPKG_PROP_SRS_UNDEFINED_CARTESIAN = @"geopackage.srs.undefined_cartesian";
NSString * const GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC = @"geopackage.srs.undefined_geographic";
NSString * const GPKG_PROP_SRS_WEB_MERCATOR = @"geopackage.srs.web_mercator";
NSString * const GPKG_PROP_SRS_SRS_NAME = @"srs_name";
NSString * const GPKG_PROP_SRS_SRS_ID = @"srs_id";
NSString * const GPKG_PROP_SRS_ORGANIZATION = @"organization";
NSString * const GPKG_PROP_SRS_ORGANIZATION_COORDSYS_ID = @"organization_coordsys_id";
NSString * const GPKG_PROP_SRS_DEFINITION = @"definition";
NSString * const GPKG_PROP_SRS_DESCRIPTION = @"description";
NSString * const GPKG_PROP_TILE_GENERATOR_VARIABLE = @"geopackage.tile_generator.variable";
NSString * const GPKG_PROP_TILE_GENERATOR_VARIABLE_Z = @"z";
NSString * const GPKG_PROP_TILE_GENERATOR_VARIABLE_X = @"x";
NSString * const GPKG_PROP_TILE_GENERATOR_VARIABLE_Y = @"y";
NSString * const GPKG_PROP_TILE_GENERATOR_VARIABLE_MIN_LAT = @"min_lat";
NSString * const GPKG_PROP_TILE_GENERATOR_VARIABLE_MAX_LAT = @"max_lat";
NSString * const GPKG_PROP_TILE_GENERATOR_VARIABLE_MIN_LON = @"min_lon";
NSString * const GPKG_PROP_TILE_GENERATOR_VARIABLE_MAX_LON = @"max_lon";
NSString * const GPKG_PROP_FEATURE_TILES = @"geopackage.feature_tiles";
NSString * const GPKG_PROP_FEATURE_TILES_WIDTH = @"width";
NSString * const GPKG_PROP_FEATURE_TILES_HEIGHT = @"height";
NSString * const GPKG_PROP_FEATURE_TILES_COMPRESS_FORMAT = @"compress_format";
NSString * const GPKG_PROP_FEATURE_POINT_RADIUS = @"point_radius";
NSString * const GPKG_PROP_FEATURE_LINE_STROKE_WIDTH = @"line_stroke_width";
NSString * const GPKG_PROP_FEATURE_POLYGON_STROKE_WIDTH = @"polygon_stroke_width";
NSString * const GPKG_PROP_FEATURE_POLYGON_FILL = @"polygon_fill";
NSString * const GPKG_PROP_DATETIME_FORMATS = @"geopackage.datetime.formats";
NSString * const GPKG_PROP_FEATURE_OVERLAY_QUERY = @"geopackage.feature_overlay_query";
NSString * const GPKG_PROP_FEATURE_QUERY_SCREEN_CLICK_PERCENTAGE = @"screen_click_percentage";
NSString * const GPKG_PROP_FEATURE_QUERY_MAX_FEATURES_INFO = @"max_features_info";
NSString * const GPKG_PROP_FEATURE_QUERY_FEATURES_INFO = @"features_info";
NSString * const GPKG_PROP_FEATURE_QUERY_MAX_POINT_DETAILED_INFO = @"max_point_detailed_info";
NSString * const GPKG_PROP_FEATURE_QUERY_MAX_FEATURE_DETAILED_INFO = @"max_feature_detailed_info";
NSString * const GPKG_PROP_FEATURE_QUERY_DETAILED_INFO_PRINT_POINTS = @"detailed_info_print_points";
NSString * const GPKG_PROP_FEATURE_QUERY_DETAILED_INFO_PRINT_FEATURES = @"detailed_info_print_features";
NSString * const GPKG_PROP_MAX_ZOOM_LEVEL = @"geopackage.max_zoom_level";
NSString * const GPKG_PROP_CONNECTION_POOL = @"geopackage.connection_pool";
NSString * const GPKG_PROP_CONNECTION_POOL_OPEN_CONNECTIONS_PER_POOL = @"open_connections_per_pool";
NSString * const GPKG_PROP_CONNECTION_POOL_CHECK_CONNECTIONS = @"check_connections";
NSString * const GPKG_PROP_CONNECTION_POOL_CHECK_CONNECTIONS_FREQUENCY = @"check_connections_frequency";
NSString * const GPKG_PROP_CONNECTION_POOL_CHECK_CONNECTIONS_WARNING_TIME = @"check_connections_warning_time";
NSString * const GPKG_PROP_CONNECTION_POOL_MAINTAIN_STACK_TRACES = @"maintain_stack_traces";
NSString * const GPKG_PROP_COLORS_RED = @"red";
NSString * const GPKG_PROP_COLORS_GREEN = @"green";
NSString * const GPKG_PROP_COLORS_BLUE = @"blue";
NSString * const GPKG_PROP_COLORS_ALPHA = @"alpha";
NSString * const GPKG_PROP_COLORS_WHITE = @"white";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES = @"geopackage.number_feature_tiles";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_TEXT_FONT = @"text_font";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_TEXT_FONT_SIZE = @"text_font_size";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_TEXT_COLOR = @"text_color";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_DRAW_CIRCLE = @"draw_circle";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_CIRCLE_COLOR = @"circle_color";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_CIRCLE_STROKE_WIDTH = @"circle_stroke_width";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_FILL_CIRCLE = @"fill_circle";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_CIRCLE_FILL_COLOR = @"circle_fill_color";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_DRAW_TILE_BORDER = @"draw_tile_border";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_TILE_BORDER_COLOR = @"tile_border_color";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_TILE_BORDER_STROKE_WIDTH = @"tile_border_stroke_width";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_FILL_TILE = @"fill_tile";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_TILE_FILL_COLOR = @"tile_fill_color";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_CIRCLE_PADDING_PERCENTAGE = @"circle_padding_percentage";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_DRAW_UNINDEXED_TILES = @"draw_unindexed_tiles";
NSString * const GPKG_PROP_NUMBER_FEATURE_TILES_UNINDEXED_TEXT = @"unindexed_text";

@implementation GPKGPropertyConstants

@end
