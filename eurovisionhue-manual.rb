require 'color'
require 'hue'
require 'miro'

hue = Hue::Client.new

def colour_to_hue(colour)
  r = colour.r
  g = colour.g
  b = colour.b
  max = [r, g, b].max
  min = [r, g, b].min
  delta = max - min
  v = max * 100

  if max != 0.0
    s = delta / max * 100
  else
    s = 0.0
  end

  if s == 0.0
    h = 0.0
  else
    if r == max
      h = (g - b) / delta
    elsif g == max
      h = 2 + (b - r) / delta
    elsif b == max
      h = 4 + (r - g) / delta
    end

    h *= 60.0

    if h < 0
      h += 360.0
    end
  end

  {
    hue: (h * 182.04).round,
    saturation: (s / 100.0 * 255.0).round,
    bri: (v / 100.0 * 255.0).round
  }
end

current_country = nil

countries = IO.readlines("running-order-with-host-before.txt")
indexArg = ARGV[0].to_i

new_country = countries[indexArg].strip

if new_country != current_country
  puts "Changing to #{new_country}"
  current_country = new_country
  colours = Miro::DominantColors.new("flags/#{new_country}.png")
  hue.lights.each_with_index do |light, i|
    light.on!
    if i < colours.to_rgb.count
      rgb = colours.to_rgb[i]
    else
      rgb = colours.to_rgb[i % colours.to_rgb.count]
    end
    target_colour = Color::RGB.new(rgb[0], rgb[1], rgb[2])
    puts "Transitioning #{light.name} to #{rgb}"
    light.set_state(colour_to_hue(target_colour), transition: 5)
  end

end

