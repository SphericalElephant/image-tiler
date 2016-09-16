# image-tiler.sh

`image-tiler.sh` splits large images into a set of tiles to use with [Leaflet.js](http://leafletjs.com) and alike.

This is a one-shoot script so it is not very pretty.

## Usage

```
image-tiler.sh [-i input.jpg] [-o output_dir] [-s .png] [-t 256] [-d]
```

## Example

```
image-tiler.sh -i map.jpg -o tiles
```

## Dependencies

* [VIPS](http://www.vips.ecs.soton.ac.uk)
* [GNU Parallel](https://www.gnu.org/software/parallel/)
* [OptiPNG](http://optipng.sourceforge.net/)
* [AdvanceCOMP](http://www.advancemame.it/comp-readme)
