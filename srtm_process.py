import os
import glob
import math
import numpy
import sqlite3
import requests
from PIL import Image
from io import BytesIO
from datetime import datetime

# A SRTM granule is a square array with this many elements along each axis.
SRTM_GRANULE_SIZE = 3601

# Void values in the SRTM data are flagged with this number.
VOID_RAW = -32768

# This value replaces VOID_RAW when the SRTM data is processed. 
VOID = 127

# One arcsecond in degrees
ARCSECOND = 1 / 3600

# Size in pixels of the tile images.
TILE_SIZE = 256

def tile_latitude(y, z):
    '''Latitude for a given Web Mercator tile origin Y value and zoom level (z).'''
    pi = math.pi
    return 360 * (((math.atan(math.e ** (pi * (1 - (y * (2 ** (1 - z))))))) / pi) - 0.25)

def tile_longitude(x, z):
    '''Longitude for a given Web Mercator tile origin X value and zoom level (z).'''
    return 360 * ((x / (2 ** z)) - 0.5)

def tile_x(longitude, z):
    '''Web Mercator X value for a given longitude (in degrees) and zoom level (z).

    Returns:
    float: The X value for the given longitude, in floating-point format.
           Should be rounded down to find the X value of the tile containing
           the given longitude.
    '''
    return (2 ** z) * ((longitude / 360) + 0.5)

def tile_y(latitude, z):
    '''Web Mercator Y value for a given latitude (in degrees) and zoom level (z).

    Returns:
    float: The Y value for the given latitude, in floating-point format.
           Should be rounded down to find the Y value of the tile containing
           the given latitude.
    '''
    pi = math.pi
    return (2 ** (z - 1) / pi) * (pi - math.log(math.tan(pi * (0.25 + (latitude / 360)))))

def srtm_granule_path(latitude, longitude):
    '''Returns the file name for the SRTM granule at the given
    latitude and longitude, according to the format NASA uses.'''
    latitude_prefix = 'N' if latitude >= 0 else 'S'
    longitude_prefix = 'E' if longitude >= 0 else 'W'
    return '{0}{1:02}{2}{3:03}.hgt'.format(latitude_prefix, abs(latitude), longitude_prefix, abs(longitude))

def srtm_coordinate_range_needed(min_tile_x, max_tile_x, min_tile_y, max_tile_y, z):
    '''Returns the range of latitude and longitude for the SRTM data granules
    needed to create images for the given range of tiles.'''
    min_longitude = math.floor(tile_longitude(min_tile_x, z))
    max_longitude = math.floor(tile_longitude(max_tile_x + 1, z))
    min_latitude = math.floor(tile_latitude(max_tile_y + 1, z))
    max_latitude = math.floor(tile_latitude(min_tile_y, z))
    return (min_longitude, max_longitude, min_latitude, max_latitude)

def load_srtm_data_needed(min_tile_x, max_tile_x, min_tile_y, max_tile_y, z):
    '''Loads the data needed to create the given range of tile images.
    Returns the array of data along with the latitude and longitude
    of the lower left corner of the array.'''
    coordinate_range_tuple = srtm_coordinate_range_needed(min_tile_x, max_tile_x, min_tile_y, max_tile_y, z)
    (min_longitude, max_longitude, min_latitude, max_latitude) = coordinate_range_tuple
    longitude_range = (max_longitude - min_longitude) + 1
    arr = numpy.zeros((0, longitude_range * (SRTM_GRANULE_SIZE - 1)), dtype = numpy.uint8)
    for latitude in range(max_latitude, min_latitude - 1, -1):
        row = numpy.zeros(((SRTM_GRANULE_SIZE - 1), 0), dtype = numpy.uint8)
        for longitude in range(min_longitude, max_longitude + 1):
            granule = process_srtm_granule(latitude, longitude)
            row = numpy.concatenate((row, granule), axis = 1)
        arr = numpy.concatenate((arr, row), axis = 0)
    return (arr, min_latitude, min_longitude)

def process_srtm_granule(latitude, longitude):
    '''Reads the hgt file for the SRTM granule at the given latitude and longitude
    and processes it into a numpy array of integers between 0 and 100.
    Missing data is marked with a value greater than 100.'''
    granule_path = srtm_granule_path(latitude, longitude)
    granule = numpy.fromfile(granule_path, dtype = numpy.dtype('>i2'))
    # Check that the array contains the expected number of values
    if len(granule) != (SRTM_GRANULE_SIZE ** 2):
        print('{0}: Unexpected number of values: {1}'.format(granule_path, len(granule)))
        return
    # Remove the top row of values, which is a duplicate of the bottom row of the granule above
    granule = numpy.delete(granule, range(SRTM_GRANULE_SIZE))
    # Remove the rightmost column of values, which is a duplicate of the leftmost column of the granule to the right
    granule = numpy.delete(granule, range(SRTM_GRANULE_SIZE - 1, len(granule) + 1, SRTM_GRANULE_SIZE))
    # Find voids (missing data)
    voids = numpy.where(granule == VOID_RAW)
    if voids[0].size > 0:
        print('{0}: Contains {1} voids'.format(granule_path, len(voids)))
    # Constrain all values to the range between 0 and 100
    # Negative values get set to 0, values over 100 get set to 100
    granule = numpy.clip(granule, 0, 100)
    # Flag the values that were void before
    granule[voids] = VOID
    granule = granule.astype(numpy.uint8)
    granule = granule.reshape((SRTM_GRANULE_SIZE - 1, SRTM_GRANULE_SIZE - 1))
    return granule

def create_srtm_tileset(min_tile_x, max_tile_x, min_tile_y, max_tile_y, dataset):
    '''This function creates tile images between zoom levels 9 and 13
    for a given area described by a range of tile coordinates at zoom level 11.

    Parameters:
    min_tile_x (int): Minimum X value of the range of tiles
                      covering the desired area at zoom level 11.
    max_tile_x (int): Maximum X value of the range of tiles
                      covering the desired area at zoom level 11.
    min_tile_y (int): Minimum Y value of the range of tiles
                      covering the desired area at zoom level 11.
    max_tile_y (int): Maximum Y value of the range of tiles
                      covering the desired area at zoom level 11.
    dataset (str):    The name of the dataset. This string is used in the name of
                      the directory where the tile images will be saved
                      and in the file names of the individual tile images.
    '''
    start_time = datetime.now()
    print('Starting {0} tileset at {1}'.format(dataset, start_time.strftime('%H:%M:%S')))
    min_tile_x_z9 = math.floor(min_tile_x / 4)
    max_tile_x_z9 = math.floor(max_tile_x / 4)
    min_tile_y_z9 = math.floor(min_tile_y / 4)
    max_tile_y_z9 = math.floor(max_tile_y / 4)
    (arr, min_latitude, min_longitude) = load_srtm_data_needed(min_tile_x_z9, max_tile_x_z9, min_tile_y_z9, max_tile_y_z9, 9)
    # For zoom levels 9 and 10, use the clear_px parameter to erase parts of the tile image
    # so that the overlay exactly matches the area described by the range of tiles at zoom level 11.
    for tile_x in range(min_tile_x_z9, max_tile_x_z9 + 1):
        for tile_y in range(min_tile_y_z9, max_tile_y_z9 + 1):
            clear_px = [0, 256, 0, 256]
            if tile_x == min_tile_x_z9:
                clear_px[0] = (min_tile_x % 4) * 64
            if tile_x == max_tile_x_z9:
                remainder = (max_tile_x + 1) % 4
                if remainder != 0:
                    clear_px[1] = remainder * 64
            if tile_y == min_tile_y_z9:
                clear_px[2] = (min_tile_y % 4) * 64
            if tile_y == max_tile_y_z9:
                remainder = (max_tile_y + 1) % 4
                if remainder != 0:
                    clear_px[3] = remainder * 64
            clear_px = None if clear_px == [0, 256, 0, 256] else tuple(clear_px)
            create_tile_images(tile_x, tile_y, 9, arr, min_latitude, min_longitude, dataset, clear_px = clear_px)
    min_tile_x_z10 = math.floor(min_tile_x / 2)
    max_tile_x_z10 = math.floor(max_tile_x / 2)
    min_tile_y_z10 = math.floor(min_tile_y / 2)
    max_tile_y_z10 = math.floor(max_tile_y / 2)
    for tile_x in range(min_tile_x_z10, max_tile_x_z10 + 1):
        for tile_y in range(min_tile_y_z10, max_tile_y_z10 + 1):
            clear_px = [0, 256, 0, 256]
            if tile_x == min_tile_x_z10 and min_tile_x % 2 == 1:
                clear_px[0] = 128
            if tile_x == max_tile_x_z10 and (max_tile_x + 1) % 2 == 1:
                clear_px[1] = 128
            if tile_y == min_tile_y_z10 and min_tile_y % 2 == 1:
                clear_px[2] = 128
            if tile_y == max_tile_y_z10 and (max_tile_y + 1) % 2 == 1:
                clear_px[3] = 128
            clear_px = None if clear_px == [0, 256, 0, 256] else tuple(clear_px)
            create_tile_images(tile_x, tile_y, 10, arr, min_latitude, min_longitude, dataset, clear_px = clear_px)
    # Zoom levels 11, 12, and 13 are more straightforward since there is no need to use clear_px 
    for tile_x in range(min_tile_x, max_tile_x + 1):
        for tile_y in range(min_tile_y, max_tile_y + 1):
            create_tile_images(tile_x, tile_y, 11, arr, min_latitude, min_longitude, dataset)
    for tile_x in range((min_tile_x * 2), (max_tile_x * 2) + 2):
        for tile_y in range((min_tile_y * 2), (max_tile_y * 2) + 2):
            create_tile_images(tile_x, tile_y, 12, arr, min_latitude, min_longitude, dataset)
    for tile_x in range((min_tile_x * 4), (max_tile_x * 4) + 4):
        for tile_y in range((min_tile_y * 4), (max_tile_y * 4) + 4):
            create_tile_images(tile_x, tile_y, 13, arr, min_latitude, min_longitude, dataset)
    end_time = datetime.now()
    print('Finished {0} tileset at {1}'.format(dataset, end_time.strftime('%H:%M:%S')))
    seconds = (end_time - start_time).seconds
    minutes = math.floor(seconds / 60)
    if minutes > 60:
        hours = math.floor(minutes / 60)
        print('{0} hours, {1} minutes, {2} seconds'.format(hours, minutes % 60, seconds % 60))
    else:
        print('{0} minutes, {1} seconds'.format(minutes, seconds % 60))

def create_tile_images(x, y, z, arr, arr_lat, arr_lon, dataset, overwrite = False, clear_px = None):
    '''Creates tile images for a single tile
    at the given X and Y values and zoom level (z).

    Parameters:
    x (int):             X coordinate of the tile.
    y (int):             Y coordinate of the tile.
    z (int):             Zoom level of the tile.
    arr (numpy.ndarray): An array of arcsecond elevation values.
    arr_lat (int):       Latitude of the lower-left corner of the array.
    arr_lon (int):       Longitude of the lower-left corner of the array.
    dataset (str):       Name of the dataset. This string is used in the name of
                         the directory where the tile images will be saved
                         and in the file names of the individual tile images.
    overwrite (bool):    If False, then the method will return early without
                         creating any tile images if any tile images already in
                         the destination directory, matching the given x, y, and z
                         coordinates and dataset name.
    clear_px (tuple):    A four-member tuple used to make certain parts of the
                         tile images blank. 
    '''
    root_tiles_directory = 'SeaLevel/Tiles/{0}'.format(dataset)
    tile_directory = '{0}/{1}/{2}'.format(root_tiles_directory, z, x)
    image_path_format = '{0}/{1}_z{2}x{3}y{4}e*.png'.format(tile_directory, dataset, z, x, y)
    # If overwrite is false, and there are existing images for this tile, return now.
    if not overwrite and len(glob.glob(image_path_format)) > 0:
        print('Skipping tiles at z:{0} x:{1} y:{2}'.format(z, x, y))
        return
    if not os.path.exists(tile_directory):
        os.makedirs(tile_directory)
    increment = 1 / TILE_SIZE
    tile_pixel_elevation_array = numpy.zeros((TILE_SIZE, TILE_SIZE))
    for pixel_x in range(0, TILE_SIZE):
      for pixel_y in range(0, TILE_SIZE):
        pixel_mercator_x = x + (increment * pixel_x)
        pixel_mercator_y = y + (increment * pixel_y)
        tile_pixel_elevation_array[pixel_y, pixel_x] = pixel_elevation(pixel_mercator_x, pixel_mercator_y, z, arr, arr_lat, arr_lon)
    # Save an image for each sea level setting
    image_rgb_array = numpy.zeros((TILE_SIZE, TILE_SIZE, 4)).astype(numpy.uint8)
    for sea_level in range(100):
        fill = numpy.where(tile_pixel_elevation_array <= sea_level)
        fill_count = len(fill[0])
        # If nowhere in the tile is below sea level, the image would be completely transparent.
        # Skip creating the image, since we can use a single blank tile instead of creating lots of separate ones.
        if fill_count == 0:
            continue
        # If the tile is entirely below sea level and clear_px is null, the image will be completely solid.
        # To save disk space, stop creating images at this point and add the tile coordinates
        # along with the current elevation to the maximum elevation array.
        # This maximum elevation array can be used by the app to determine when to show a solid tile.
        if clear_px == None and fill_count == tile_pixel_elevation_array.size:
            max_elevation_filename = '{0}/{1}_solid.dat'.format(root_tiles_directory, dataset)
            max_elevation_entry = numpy.array([z, x, y, sea_level + 1], dtype = numpy.uint16)
            try:
                with open(max_elevation_filename, 'rb') as max_elevation_file:
                    max_elevation_bytes = max_elevation_file.read()
                    max_elevation_array = numpy.frombuffer(max_elevation_bytes, dtype = numpy.uint16)
            except IOError:
                max_elevation_array = numpy.array([], dtype = numpy.uint16)
            max_elevation_array = numpy.concatenate((max_elevation_array, max_elevation_entry))
            with open(max_elevation_filename, 'wb') as max_elevation_file:
                max_elevation_file.write(max_elevation_array)
            break
        # TODO: Apply a different color for voids if necessary
        image_rgb_array[fill] = [0, 122, 255, 150]
        if clear_px:
            image_rgb_array[:, :clear_px[0]].fill(0)
            image_rgb_array[:, clear_px[1]:].fill(0)
            image_rgb_array[:clear_px[2], :].fill(0)
            image_rgb_array[clear_px[3]:, :].fill(0)
        image = Image.fromarray(image_rgb_array, mode = 'RGBA')
        image_path = image_path_format.replace('*', str(sea_level + 1))
        image.save(image_path)
        image_rgb_array.fill(0)

def pixel_elevation(pixel_x, pixel_y, z, arr, arr_lat, arr_lon):
    '''Calculate the approximate elevation value of the tile pixel
    at the given coordinates.

    Parameters:
    pixel_x (float):     Web Mercator X coordinate of the pixel
    pixel_y (float):     Web Mercator Y coordinate of the pixel
    z (int):             Zoom level
    arr (numpy.ndarray): An array of arcsecond elevation values.
    arr_lat (int):       Latitude of the lower-left corner of the array.
    arr_lon (int):       Longitude of the lower-left corner of the array.
    '''
    # Calculate the latitude and longitude of the top left corner of the pixel.
    pixel_latitude = tile_latitude(pixel_y, z)
    pixel_longitude = tile_longitude(pixel_x, z)
    # Calculate the dimensions of the pixel in degrees.
    inc = 1 / TILE_SIZE
    pixel_latitude_span = pixel_latitude - tile_latitude(pixel_y + inc, z)
    pixel_longtude_span = tile_longitude(pixel_x + inc, z) - pixel_longitude
    # Calculate the coordinate of the top left corner of the array
    arr_top_left_lat = arr_lat + arr.shape[0] * ARCSECOND - (ARCSECOND / 2)
    arr_top_left_lon = arr_lon - (ARCSECOND / 2)
    # Find the indices of the arcsecond cell that contains the upper-left corner of the pixel
    min_arcsecond_y = math.floor((arr_top_left_lat - pixel_latitude) / ARCSECOND)
    max_arcsecond_lat = arr_top_left_lat - (min_arcsecond_y * ARCSECOND)
    min_arcsecond_x = math.floor((pixel_longitude - arr_top_left_lon) / ARCSECOND)
    min_arcsecond_lon = arr_top_left_lon + (min_arcsecond_x * ARCSECOND)
    # Find the indices of the arcsecond cell that contains the bottom-right corner of the pixel
    max_arcsecond_y = math.ceil((arr_top_left_lat - (pixel_latitude - pixel_latitude_span)) / ARCSECOND)
    max_arcsecond_x = math.ceil(((pixel_longitude + pixel_longtude_span) - arr_top_left_lon) / ARCSECOND)
    # Calculate overlapping area multiplied by elevation value for each arcsecond cell.
    # For simplicity pretend that the cells are flat rectangles. This is not completely accurate,
    # but the error should be negligible when working with high zoom levels.
    total_elevation_multiplied_by_degree_area = 0
    for arcsecond_x in range(min_arcsecond_x, max_arcsecond_x):
      for arcsecond_y in range(min_arcsecond_y, max_arcsecond_y):
        arcsecond_lat = max_arcsecond_lat - ARCSECOND * (arcsecond_y - min_arcsecond_y)
        arcsecond_lon = min_arcsecond_lon + ARCSECOND * (arcsecond_x - min_arcsecond_x)
        overlapping_lat = max(0, (min(pixel_latitude, arcsecond_lat) - max(pixel_latitude - pixel_latitude_span, arcsecond_lat - ARCSECOND)))
        overlapping_lon = max(0, (min(pixel_longitude + pixel_longtude_span, arcsecond_lon + ARCSECOND) - max(pixel_longitude, arcsecond_lon)))
        total_elevation_multiplied_by_degree_area += (overlapping_lat * overlapping_lon * arr[arcsecond_y, arcsecond_x])
    # Divide the total (elevation * degree area) number by the area of the pixel for the average elevation value.
    return total_elevation_multiplied_by_degree_area / (pixel_latitude_span * pixel_longtude_span)

def open_street_map_image(min_tile_x, max_tile_x, min_tile_y, max_tile_y, z):
    '''Returns a PIL image created from OpenStreetMap tiles
    with the given range of coordinates. This is useful for figuring
    out the range of tiles needed to show a given city.
    '''
    tile_span_x = (max_tile_x - min_tile_x) + 1
    tile_span_y = (max_tile_y - min_tile_y) + 1
    image_size = (tile_span_x * TILE_SIZE, tile_span_y * TILE_SIZE)
    image = Image.new('RGB', image_size)
    for tile_x in range(min_tile_x, max_tile_x + 1):
        for tile_y in range(min_tile_y, max_tile_y + 1):
            url = 'https://tile.openstreetmap.org/{0}/{1}/{2}.png'.format(z, tile_x, tile_y)
            # OpenStreetMap has blocked the default python requests user agent,
            # so use some other agent
            headers = {'user-agent': 'Cassini/1.0.22'}
            response = requests.get(url, headers = headers)
            if response.status_code != 200:
                print('Failed to get tile: {0} with response code:'.format(url))
                continue
            tile_image = Image.open(BytesIO(response.content))
            pixel_x = (tile_x - min_tile_x) * TILE_SIZE
            pixel_y = (tile_y - min_tile_y) * TILE_SIZE
            image.paste(tile_image, (pixel_x, pixel_y))
    return image

def visualize(arr):
    '''Displays a PIL image representing the given array.
    This is useful for debugging purposes.

    Parameters:
    arr (numpy.ndarray): An array of integers between 0 and 100.
    '''
    # Enhance! Scale values to 0-255 for better visibility
    enhanced_arr = (arr * 2.55).astype(numpy.int8)
    image = Image.fromarray(enhanced_arr, mode = 'L')
    image.show()

def ranges():
    '''Returns a list of tuples containing the tile range data
    found in range.txt'''
    range_tuples = []
    with open('range.txt') as range_file:
        range_text = range_file.read()
    range_lines = range_text.split('\n')
    for line in range_lines:
        elements = line.split(',')
        if len(elements) != 5 or not elements[1].isdigit():
            continue
        range_tuples.append((elements[0], int(elements[1]), int(elements[2]), int(elements[3]), int(elements[4])))
    return range_tuples

def granules_needed_for_ranges():
    '''Prints a list of SRTM granules needed for all the tilesets
    defined in range.txt. The filename format used is the one found
    on the NASA Earthdata Search site and not the same as the one 
    used by the srtm_granule_path function. Some of the granules printed
    may not actually exist on the NASA site.
    '''
    granules = set()
    for range_tuple in ranges():
        name, min_tile_x_z11, max_tile_x_z11, min_tile_y_z11, max_tile_y_z11 = range_tuple
        min_tile_x_z9 = math.floor(min_tile_x_z11 / 4)
        max_tile_x_z9 = math.floor(max_tile_x_z11 / 4)
        min_tile_y_z9 = math.floor(min_tile_y_z11 / 4)
        max_tile_y_z9 = math.floor(max_tile_y_z11 / 4)
        range_tuple = srtm_coordinate_range_needed(min_tile_x_z9, max_tile_x_z9, min_tile_y_z9, max_tile_y_z9, 9)
        (min_longitude, max_longitude, min_latitude, max_latitude) = range_tuple
        for latitude in range(max_latitude, min_latitude - 1, -1):
            for longitude in range(min_longitude, max_longitude + 1):
                granules.add((latitude, longitude))
    filenames = []
    for granule in sorted(list(granules)):
        filenames.append(srtm_granule_path(granule[0], granule[1]).replace('.hgt', '.SRTMGL1.hgt.zip'))
    return filenames

def print_latitude_longitude_ranges():
    '''For each tile range defined in range.txt, this function prints the
    latitude and longitude of the center and the latitude and longitude span.
    '''
    for range_tuple in ranges():
        name, min_tile_x_z11, max_tile_x_z11, min_tile_y_z11, max_tile_y_z11 = range_tuple
        center_lat = tile_latitude((min_tile_y_z11 + max_tile_y_z11 + 1) / 2, 11)
        center_lon = tile_longitude((min_tile_x_z11 + max_tile_x_z11 + 1) / 2, 11)
        lat_span = tile_latitude(min_tile_y_z11, 11) - tile_latitude(max_tile_y_z11 + 1, 11)
        lon_span = tile_longitude(max_tile_x_z11 + 1, 11) - tile_longitude(min_tile_x_z11, 11)
        print('{0:>22}: {1:11.6f}, {2:11.6f}, {3:.3f}, {4:.3f}'.format(name, center_lat, center_lon, lat_span, lon_span))

