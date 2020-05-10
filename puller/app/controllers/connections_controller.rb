class ConnectionsController < ApplicationController
  # GET /connections/new
  def new
    locals :connection => Connection.new
  end

  # POST /connections
  def create
    connection = create_connection

    if connection.save
      redirect_to :root, :notice => t(:connection_successfully_created)
    else
      locals :new, :connection => connection
    end
  end

  # DELETE /connections/1
  def destroy
    current_connection.destroy
    redirect_to :root, :notice => t(:connection_successfully_deleted)
  end

private

  def create_connection
    connection = Connection.new(connection_params)
    connection.user = current_user
    connection
  end

  def current_connection
    @current_connection ||= current_user.connections.find(params[:id])
  end

  def connection_params
    params.require(:connection).permit(:source)
  end
end
