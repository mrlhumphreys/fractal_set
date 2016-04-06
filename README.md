# Fractal Set

## Setup 

```
  bundle install 
```

## Usage

### Generate a Julia Set

In the following example a Julia Set will be rendered with the following properties:

  * c is -0.8 + i0.156 (real, imaginary)
  * The graph will include points from real/imaginary -2 to 2 (min, max)
  * The output image will be 512px by 512px (width, height)

```
  ruby ./bin/fractal_set.rb --real=-0.8 --imaginary=0.156 --min=-2 --max=2 --width=512 --height=512 
```
