# SeaLevel

<img src="https://raw.githubusercontent.com/gbrixey/SeaLevel/main/screenshot.png" alt="Screenshot of the SeaLevel app" width="250" />

This app allows the user to raise the sea level with a slider. The map is then shaded blue to indicate which areas would be below sea level based on the selected surface elevation data set.

The surface elevation data was used to generate map overlay images. I have not created a web API for fetching these images, so they have to be stored in the app using the iOS On-Demand Resources feature. Due to storage limitations, only one area can be viewed at a time. The active area can be changed from the map UI, which may require downloading additional data.

Data sets used (only one so far):

- [NASA Shuttle Radar Topography Mission](https://www2.jpl.nasa.gov/srtm/)
