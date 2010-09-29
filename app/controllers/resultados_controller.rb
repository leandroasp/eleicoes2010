require 'zip/zip'

class ResultadosController < ApplicationController
  def index
    unzip_file("http://localhost/ruby/eleicoes2010/public/pi13.zip", "public/zips")
  end

def unzip_file (file, destination)
  Zip::ZipFile.open(file) { |zip_file|
   zip_file.each { |f|
     f_path=File.join(destination, f.name)
     FileUtils.mkdir_p(File.dirname(f_path))
     zip_file.extract(f, f_path) unless File.exist?(f_path)
   }
  }
end

end
