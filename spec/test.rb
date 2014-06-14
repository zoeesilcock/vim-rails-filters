class MyController < ApplicationController

  before_filter :before_all
  before_filter :before_show, only: [:show]
  before_filter :before_except, except: [:index]

  def index
    # index content
  end

  def show
    # Oh hai
  end

  private

  def before_all
    puts 'before filter for all'
  end

  def before_show
    puts 'before show'
  end

  def before_except
    puts 'before except'
  end

  def method_with_params(foo, bar)
  end

end
