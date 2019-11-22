# TODO list

- Add additional datasets
    - Advanced Spaceborne Thermal Emission and Reflection Radiometer (ASTER)
    - CoastalDEM data from Climate Central
    - National Elevation Dataset (NED)
        - Coastal National Elevation Database (CoNED)
    - NOAA LIDAR data
- Show a warning if the user turns on current location and their location is outside the data region?
- Show a warning if the user tries to download data without a Wi-Fi connection?
- Update info view:
    - Link to GitHub page?
    - Link to NASA SRTM page?

# Known Issues

- Transient missing tile issue
    - Sometimes a few tiles will appear to be missing on the map. Seems to happen more often when zoomed in.
    - Changing sea level to a different value and then back to the original value usually fixes this.
- When changing location, map overlays are not shown at first even if sea level is greater than zero.
    - Changing sea level will make the overlays appear again.
