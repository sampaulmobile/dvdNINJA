class TorrentsController < ApplicationController

  def index
    @torrents = Torrent.order('created_at DESC').limit(100)
  end

end
