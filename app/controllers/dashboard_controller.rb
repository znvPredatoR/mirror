class DashboardController < ApplicationController

  before_action :authenticate!

  def show
    @dashboard = Dashboard.find(params[:id])
  end

  def preview
    @dashboard = Dashboard.find(params[:id])
    render 'preview', layout: 'preview'
  end

end