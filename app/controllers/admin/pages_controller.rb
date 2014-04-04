# coding: utf-8
require 'base64'

class Admin::PagesController < Admin::BaseController

  before_filter :set_images, only: [:new, :edit]
  before_filter :set_macro, only: [:new, :edit]

  layout "administration", :except => 'show'
  cache_sweeper :blog_sweeper

  def index
    @search = params[:search] ? params[:search] : {}
    @pages = Page.search_with(@search).page(params[:page]).per(this_blog.admin_display_elements)
  end

  def new
    @page = Page.new(params[:page])
    @page.user_id = current_user.id
    @page.text_filter ||= default_textfilter

    if request.post?
      @page.published_at = Time.now
      if @page.save
        flash[:notice] = _('Page was successfully created.')
        redirect_to :action => 'index'
      end
    end
  end

  def edit
    @page = Page.find(params[:id])
    @page.attributes = params[:page]
    @page.text_filter ||= default_textfilter
    if request.post? and @page.save
      flash[:notice] = _('Page was successfully updated.')
      redirect_to :action => 'index'
    end
  end

  def destroy
    destroy_a(Page)
  end

  private

  def default_textfilter
    current_user.text_filter || blog.text_filter
  end


  def set_macro
    @macros = TextFilter.macro_filters
  end

  def set_images
    @images = Resource.images.by_created_at.page(1).per(10)
  end
end
