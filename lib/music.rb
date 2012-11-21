module Music
  module Errors
    class DirectoryDoesNotExist < StandardError; end
  end

  class Files
    FORMATS = ["mp3"]

    attr_accessor :files
    def initialize(directory, options)

      @options = options
      if !File.exists?(directory)
        raise Music::Errors::DirectoryDoesNotExist.new("Directory: #{directory} does not exist")
      end

      @files = Dir.glob("#{directory}/**/*").reject{|f| 
        !(f =~ /.(#{FORMATS.join("|")})$/)
      }
      if @options[:shuffle]
        @files.shuffle!
      end
    end

    def each
      @files.each do |file|
        yield file
      end
    end
  end

end
