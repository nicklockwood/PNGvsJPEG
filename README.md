PNGvsJPEG
=========

This is a simple benchmark app to compare JPEG vs PNG loading performance on iOS. Spoiler: JPEG wins.

The test counts the time taken to load the image *and* draw it at full size into a new image context. The reason for this is that iOS defers decompression of images until they are drawn, and stores images in different formats in memory based on the file type, so unless you redraw an image after loading you cannot be certain that the image is actually ready to draw.

If you draw an image into a new context after loading, and then use the newly-created image for subsequent drawing (discarding the original) you guarantee the best possible drawing performance.

Note: To get an accurate result, ensure that you do the following:

1. Run on a device, not the simulator
2. Build in release mode, not debug
3. Disconnect from the debugger / Xcode
4. Kill the app and re-run a few times to verify