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

    it "can handle methods with parameters" do
      vim.search 'def method_with_params'

      expect(get_current_method).to eq('method_with_params')
    end
  end

  describe "get_filters_for" do
    def get_filters_for(method)
      vim.command("echo <SNR>#{@sid}_get_filters_for('#{method}')")
    end

    it "returns a list of line numbers" do
      expect(get_filters_for('index')).to eq("[{'filter_line': 3, 'method_line': 17}, {'filter_line': 4, 'method_line': 21}, {'filter_line': 5, 'method_line': 25}]")
    end
  end

  describe "extract_method_from_filter" do
    def extract_method_from_filter(string)
      vim.command("echo <SNR>#{@sid}_extract_method_from_filter('#{string}')")
    end

    it "understands symbols" do
      expect(extract_method_from_filter('before_filter :think_before_you_talk')).to eq('think_before_you_talk')
    end
  end

  describe "build_quickfix_list" do
    let(:filter_lines) { "[{'filter_line': 3, 'method_line': 17}]" }

    def build_quickfix_list(filter_lines)
      vim.command("echo <SNR>#{@sid}_build_quickfix_list(#{filter_lines})")
    end

    it "contains the right line number" do
      list = build_quickfix_list(filter_lines)

      line_number = list.match(/'lnum': (\d+)/)[1].to_i
      expect(line_number).to eq(17)
    end

    it "contains the buffer number" do
      list = build_quickfix_list(filter_lines)

      buffer_number = list.match(/'bufnr': (\d+)/)[1].to_i
      expect(buffer_number).to be_an(Integer)
    end

    it "contains the method declaration as th text" do
      list = build_quickfix_list(filter_lines)

      text = list.match(/'text': '([^']*)'/)[1]
      expect(text).to eq("before_filter :before_all")
    end
  end

  describe "strip" do
    def strip(string)
      vim.command("echo <SNR>#{@sid}_strip('#{string}')")
    end

    it "removes spaces before content" do
      expect(strip('  I am indented')).to eq('I am indented')
    end

    it "removes spaces after content" do
      expect(strip('I am sloppy ')).to eq('I am sloppy')
    end
  end
end
