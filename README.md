# image-tiler.sh

`image-tiler.sh` splits large images into a set of tiles to use with [Leaflet.js](http://leafletjs.com) and alike.

This is a one-shoot script so it is not very pretty.

`image-tiler.sh` depends on `bash` and `imagemagick`

## Usage

```
image-tiler.sh [-i input.jpg] [-o output_dir] [-l levels] [-d]
```

## Example

```
image-tiler.sh -i map.jpg -o ./tiles -l 5
```
