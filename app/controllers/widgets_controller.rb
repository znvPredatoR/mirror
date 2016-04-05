class WidgetsController < ApplicationController

  before_action :authenticate!

  def create
    @dashboard = Dashboard.find(params[:dashboard_id])
    widget = Widget.create!(widget_params)
    if widget.parent.present?
      widget.parent.children << widget
      render partial: 'dashboard/widget', locals: { widget: widget }
    else
      @dashboard.widgets << widget
      render partial: 'dashboard/row', locals: { widget: widget }
    end
  end

  def update
    Widget.find(params[:id]).update(widget_params)
    head :ok, content_type: 'text/html'
  end

  def wrap
    widget = Widget.find(params[:id])
    current_parent = widget.parent
    current_parent.children.delete(widget)
    new_row_right = current_parent.insert_new_row(widget_wrap_params[:current_position])
    new_row_left = current_parent.insert_new_row(widget_wrap_params[:current_position])
    if widget_wrap_params[:move_direction] == 'left'
      new_row_left.children << widget
    else
      new_row_right.children << widget
    end
    head :ok, content_type: 'text/html'
  end

  def unwrap
    widget = Widget.find(params[:id])
    current_parent = widget.parent
    new_parent = current_parent.parent
    if widget_wrap_params[:move_direction] == 'left'
      new_parent.children.where(position: current_parent.position - 1).first.destroy!
    else
      new_parent.children.where(position: current_parent.position + 1).first.destroy!
    end
    widget.update(parent: new_parent)
    current_parent.destroy!

    head :ok, content_type: 'text/html'
  end

  def destroy
    Widget.find(params[:id]).destroy!
    head :ok, content_type: 'text/html'
  end

private

  def widget_params
    params.require(:widget).permit(:widget_type, :position, :parent_id)
  end

  def widget_wrap_params
    params.require(:widget).permit(:move_direction, :current_position)
  end

end