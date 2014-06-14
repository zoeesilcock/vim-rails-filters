require 'spec_helper.rb'

describe "rails-filters.vim" do
  before do
    File.open("test.rb","w") {|o| o.puts File.readlines(File.expand_path('../test.rb', __FILE__)) }
    vim.edit! 'test.rb'

    @sid = vim.command('scriptnames').match(/(\d+):.*vim-rails-filters\/plugin\/rails_filters\.vim/)[1]
  end

  describe "get_current_method" do
    def get_current_method
      vim.command("echo <SNR>#{@sid}_get_current_method()")
    end

    it "returns nothing when not in a method" do
      vim.search '$^'

      expect(get_current_method).to be_empty
    end

    it "works on the first line of the method" do
      vim.search 'def index'

      expect(get_current_method).to eq('index')
    end

    it "works inside the method" do
      vim.search '# index content'

      expect(get_current_method).to eq('index')
    end
  end
end
