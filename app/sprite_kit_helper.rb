module SKHelper
  def degrees_to_radians(degrees)
    degrees * Math::PI / 180  # radians
  end
end
include SKHelper
