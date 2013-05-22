class NodesController < ApplicationController

  respond_to :json

  def index
    respond_with Node.all
  end

  def show
    respond_with Node.find params[:id]
  end

  def create
    respond_with Node.create(params[:node])
  end

  def update
    respond_with Node.update params[:id], params[:node]
  end

  def destroy
    respond_with Node.destroy params[:id]
  end

  def move
    @node = Node.find params[:id]
    if params[:right].present? && params[:right].to_i > 0
      @node.move_to_left_of params[:right]
    elsif params[:left].present? && params[:left].to_i > 0
      @node.move_to_right_of params[:left]
    end
    respond_with @node
  end

end
