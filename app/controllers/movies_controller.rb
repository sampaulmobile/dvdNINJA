class MoviesController < ApplicationController

  def show
    @movie = Movie.find(params[:id])
  end

  def index
    if params[:phrase]
      @movies = Movie.where("title LIKE ?", "%#{params[:phrase]}%").order("release_date DESC")
    else
      @movies = Movie.all.order("release_date DESC")
    end

    if params[:rt]
      @movies = @movies.where("rt_id != -1")
    end
  end

  def queue


  end

  def instant
    if params[:phrase]
      @torrents = Movie.queue_magnets(params[:phrase])
    end

  end

end
