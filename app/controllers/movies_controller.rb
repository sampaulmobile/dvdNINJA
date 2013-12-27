class MoviesController < ApplicationController

  def show
    @movie = Movie.find(params[:id])
  end

  def index
    if params[:phrase]
      @movies = Movie.where("title LIKE ?", "%#{params[:phrase]}%").order("release_date DESC")
    else
      @movies = Movie.all.order("release_date DESC").limit(100)
    end

    if params[:rt]
      @movies = @movies.where("rt_id != -1")
    end
  end

  def queue
    if params[:phrase]
      @torrents = Movie.search_pb(params[:phrase])
    end
  end

  def instant
    if params[:phrase]
      @torrents = Movie.queue_magnets(params[:phrase])
    end
  end

  def update_rt
      Movie.update_rt_dvds
      
      redirect_to rt_url
  end

  def torrent_rt
      Movie.torrent_rt_dvds

      redirect_to torrents_url
  end

  def download
    if params[:url]
      Torrent.download(params[:url])
    end

    redirect_to root_url
  end

end
