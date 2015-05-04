module WikipediaWrapper

  class ImageWhitelist
      # FIXME: whitelist common images
      @@complete = ['File:Commons-logo.svg', 'File:Boxed East arrow.svg',
                   'File:A coloured voting box.svg', 'File:People icon.svg',
                   'File:Folder Hexagonal Icon.svg', 'File:Red pog.svg',
                   'File:Question book-new.svg', 'File:Cscr-featured.svg',
                   'File:Edit-clear.svg', 'File:East.svg', 'File:North.svg',
                   'File:Compass rose pale.svg', 'File:Portal-puzzle.svg',
                   'File:Ambox important.svg', 'File:Disambig gray.svg',
                   'File:Wiktionary-logo-en.svg', 'File:Ambox current red.svg']


      @@partial = ['arms', 'blason','icon', 'wappen',
                   'bandera', 'flag', 'map', 'arms', 'karte', 'coa']


    def self.is_whitelisted? (filename)

      if @@complete.include? filename
        return true

      else
        @@partial.each do |p|
          if filename.downcase.include? p
            return true
          end
        end
      end

      return false

    end


  end

end