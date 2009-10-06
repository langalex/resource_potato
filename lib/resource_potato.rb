module ResourcePotato
  
end

Dir.glob(File.dirname(__FILE__) + '/resource_potato/**.rb').each do |file|
  require file
end

