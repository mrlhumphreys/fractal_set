require 'rmagick'
require 'optparse'

module FractalSet
  def set_function(z, c)
    z**2 + c 
  end

  def repeat_iteration_for_value(z=0, c=0, iteration=0, reps=300)
    result = set_function(z, c)

    if iteration == reps
      reps 
    elsif result.real**2 + result.imaginary**2 > 4
      iteration
    else
      repeat_iteration_for_value(result, c, iteration+1)
    end
  end

  def plot(point_width,point_height)
    (0..point_width).to_a.map do |row|
      (0..point_height).to_a.map do |column|
        r = component(column, point_width)
        i = component(row, point_height)
        num = Complex(r, i)
        iter_value(num)
      end
    end
  end

  def component(n,max_point)
    case n
    when 0
      @min_n 
    when max_point
      @max_n 
    else
      (n.to_f / max_point.to_f) * (@max_n - @min_n) + @min_n 
    end
  end
end

class JuliaSet
  include FractalSet

  def initialize(c, min_n=-2, max_n=2)
    @c = c
    @min_n = min_n || -2
    @max_n = max_n || 2
  end

  def iter_value(num)
    repeat_iteration_for_value(num, @c)
  end
end

class MandelbrotSet
  include FractalSet

  def initialize(min_n, max_n)
    @min_n = min_n || -2
    @max_n = max_n || 2
  end

  def iter_value(num)
    repeat_iteration_for_value(0, num)
  end
end

class SetImage
  def initialize(set, width, height)
    @set = set
    @width = width || 512
    @height = height || 512
  end

  def image
    @image ||= Magick::Image.new(@width, @height)
  end

  def data
    @data ||= @set.plot(@width, @height) 
  end

  def create(filename)
    data.each_with_index do |row, row_index|
      row.each_with_index do |item, column_index|
        h = item+228 % 256
        s = 255
        b = 255 * (item < 300 ? 1 : 0)

        c = "hsb(#{h}, #{s}, #{b})"  

        image.pixel_color(column_index, row_index, c)
      end
    end
    @image.write(filename)
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: julia_set.rb [options]"

  opts.on("-rREAL", "--real=REAL", "Real Component") { |o| options[:real] = o.to_f }
  opts.on("-iIMAGINARY", "--imaginary=IMAGINARY", "Imaginary Component") { |o| options[:imaginary] = o.to_f }
  opts.on("-mMIN", "--min=MIN", "Minimum frame") { |o| options[:min] = o.to_f }
  opts.on("-MMAX", "--max=MAX", "Maximum frame") { |o| options[:max] = o.to_f }
  opts.on("-wWIDTH", "--width=WIDTH", "Image width") { |o| options[:width] = o.to_i }
  opts.on("-hHEIGHT", "--height=HEIGHT", "Image height") { |o| options[:height] = o.to_i }

end.parse!

if options[:real] && options[:imaginary]
  c = Complex(options[:real], options[:imaginary])
  s = JuliaSet.new(c, options[:min], options[:max])
  i = SetImage.new(s,options[:width], options[:height])
  i.create("julia_set_r#{c.real}_i#{c.imaginary}_#{Time.now.to_i}.bmp")
else
  s = MandelbrotSet.new(options[:min], options[:max])
  i = SetImage.new(s,options[:width], options[:height])
  i.create("mandelbrot_set_#{Time.now.to_i}.bmp")
end


