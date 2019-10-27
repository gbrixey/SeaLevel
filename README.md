# SeaLevel

<img src="https://raw.githubusercontent.com/gbrixey/SeaLevel/master/screenshot.png" alt="Screenshot of the SeaLevel app" width="250" />

This app allows the user to raise the sea level with a slider. The map is then shaded blue to indicate which areas would be below sea level. However, even if they are below sea level, the shaded areas might not actually be under water, depending on local geography and other factors.

Data comes from the [NASA Shuttle Radar Topography Mission](https://www2.jpl.nasa.gov/srtm/). This data provides surface elevation at a resolution of one arcsecond (about 30 meters). The elevation measurements in this data set may be higher than ground level in some areas due to the presence of buildings, trees, etc.

The SRTM data was used to generate map overlay images. These images are bundled with the app, rather than accessed via the internet. Due to storage limitations, only images for the New York City area are included.
