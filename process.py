import math
import numpy
import sqlite3
from PIL import Image

BLOCK_SIZE = 3601
VOID_RAW = -32768
VOID = 127
ARCSECOND = 1 / 3600
TILE_SIZE = 256
OVERLAY_COLOR = 0x5AC8FA80

def x(lon, z):
    '''Web Mercator tile origin X value for a given longitude and zoom level.'''
    return (2 ** z) * ((lon / 360) + 0.5)

def y(lat, z):
    '''Web Mercator tile origin Y value for a given latitude and zoom level.'''
    pi = math.pi
    return (2 ** (z - 1) / pi) * (pi - math.log(math.tan(pi * (0.25 + (lat / 360)))))
    
def lat(y, z):
    '''Latitude for a given Web Mercator tile origin Y value and zoom level.'''
    pi = math.pi
    return 360 * (((math.atan(math.e ** (pi * (1 - (y * (2 ** (1 - z))))))) / pi) - 0.25)

def lon(x, z):
    '''Longitude for a given Web Mercator tile origin X value and zoom level.'''
    return 360 * ((x / (2 ** z)) - 0.5)

def create_tiles(tx, ty, z, arr, arr_lat, arr_lon):
    '''Create tile images for the tile at the given X and Y values and zoom level.'''
    t_lat = lat(ty, z)
    t_lon = lon(tx, z)
    # TODO: Automatically read arr from file based on t_lat, t_lon, and z
    # instead of having to pass the array into the function
    inc = 1 / TILE_SIZE
    tile = numpy.zeros((TILE_SIZE, TILE_SIZE))
    for px in range(0, TILE_SIZE):
      for py in range(0, TILE_SIZE):
        tile[py, px] = pixel_elevation(tx + (inc * px), ty + (inc * py), z, arr, arr_lat, arr_lon)
    # Save an overlay image for each sea level setting
    tmp = numpy.zeros((TILE_SIZE, TILE_SIZE)).astype(numpy.int32)
    for sea_level in range(100):
        # TODO: Apply a different overlay color for voids if necessary
        tmp[numpy.where(tile <= sea_level)] = OVERLAY_COLOR
        image = Image.fromarray(tmp, mode='RGBA')
        path = 'SeaLevel/Tiles/{0}/{1}/{2}e{3}.png'.format(z, tx, ty, sea_level + 1)
        image.save(path)
        tmp.fill(0)

def pixel_elevation(px, py, z, arr, arr_lat, arr_lon):
    '''Calculate the approximate elevation value of the tile pixel at the given X and Y values and zoom level.
    arr is an array of arcsecond elevation values. arr_lat and arr_lon are the coordinates of the center
    of the lower-left square arcsecond in the array.'''
    p_lat = lat(py, z)
    p_lon = lon(px, z)
    inc = 1 / TILE_SIZE
    d_lat = p_lat - lat(py + inc, z)
    d_lon = lon(px + inc, z) - p_lon
    # Calculate the coordinate of the top left corner of the array
    tl_lat = arr_lat + arr.shape[0] * ARCSECOND - (ARCSECOND / 2)
    tl_lon = arr_lon - (ARCSECOND / 2)
    # Find the indices of the arcsecond that contains the upper-left corner of the pixel
    start_y = math.floor((tl_lat - p_lat) / ARCSECOND)
    start_lat = tl_lat - (start_y * ARCSECOND)
    start_x = math.floor((p_lon - tl_lon) / ARCSECOND)
    start_lon = tl_lon + (start_x * ARCSECOND)
    # Find the indices of the arcsecond that contains the bottom-right corner of the pixel
    end_y = math.ceil((tl_lat - (p_lat - d_lat)) / ARCSECOND)
    end_x = math.ceil(((p_lon + d_lon) - tl_lon) / ARCSECOND)
    # Calculate overlapping area multiplied by elevation value for each arcsecond
    # There will be some inaccuracy since this is not planar geometry.
    total = 0
    for cx in range(start_x, end_x):
      for cy in range(start_y, end_y):
        c_lat = start_lat - ARCSECOND * (cy - start_y)
        c_lon = start_lon + ARCSECOND * (cx - start_x)
        o_lat = max(0, (min(p_lat, c_lat) - max(p_lat - d_lat, c_lat - ARCSECOND)))
        o_lon = max(0, (min(p_lon + d_lon, c_lon + ARCSECOND) - max(p_lon, c_lon)))
        total += (o_lat * o_lon * arr[cy, cx])
    # Divide that number by the area of the pixel for the average elevation value.
    return total / (d_lat * d_lon)

def path(lat, lon):
    '''Returns an hgt file name for the given latitude and longitude, according to the format NASA uses.'''
    lat_prefix = 'N' if lat >= 0 else 'S'
    lon_prefix = 'E' if lon >= 0 else 'W'
    return '{0}{1:02}{2}{3:03}.hgt'.format(lat_prefix, abs(lat), lon_prefix, abs(lon))

def process(lat, lon):
    '''Reads the hgt file for the given latitude and longitude
    and processes it into a numpy array of integers between 0 and 100.'''
    block_path = path(lat, lon)
    block = numpy.fromfile(block_path, dtype=numpy.dtype('>i2'))
    # Check that the block contains the expected number of values
    if len(block) != (BLOCK_SIZE * BLOCK_SIZE):
        print('{0}: Unexpected number of values: {1}'.format(block_path, len(block)))
        return
    # Remove the top row of values, which is a duplicate of the bottom row of the block above
    block = numpy.delete(block, range(BLOCK_SIZE))
    # Remove the rightmost column of values, which is a duplicate of the leftmost column of the block to the right
    block = numpy.delete(block, range(BLOCK_SIZE - 1, len(block) + 1, BLOCK_SIZE))
    # Find voids (missing data)
    voids = numpy.where(block == VOID_RAW)
    if voids[0].size > 0:
        print('{0}: Contains {1} voids'.format(block_path, len(voids)))
    # Constrain all values to the range between 0 and 100
    # Negative values get set to 0, values over 100 get set to 100
    block = numpy.clip(block, 0, 100)
    # Flag the values that were void before
    block[voids] = VOID
    block = block.astype(numpy.int8)
    return block
    
def visualize(arr):
    '''Displays a PIL image representing the given numpy array of integers between 0 and 100.'''
    arr2 = (arr * 2.55).astype(numpy.int8)
    image = Image.fromarray(arr2, mode='L')
    image.show()

