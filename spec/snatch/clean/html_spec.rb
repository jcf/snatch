# encoding: utf-8
require 'spec_helper'

describe Snatch::Clean::HTML do
  before(:each) do
    @html = Snatch::Clean::HTML.new('nokogiri_doc', 'public')
  end

  describe "Removing crap" do
    before do
      @html.doc.should_receive(:css).with('a[href]').any_number_of_times.and_return([])
      @html.doc.should_receive(:css).with('[src]').any_number_of_times.and_return([])
    end

    it 'should remove any base tags' do
      mock_nodes = [(mock_node = mock('nokogiri_node'))]
      @html.doc.should_receive(:css).with('base, meta[generator]').and_return(mock_nodes)
      @html.doc.should_receive(:search).and_return(mock_node)
      mock_node.should_receive(:remove).twice.and_return([])
      mock_nodes.should_receive(:each).and_yield(mock_node)
      @html.send(:update)
    end

    it 'should remove comments and the generator meta tag' do
      mock_nodes = [(mock_node = mock('nokogiri_node'))]
      @html.doc.should_receive(:css).with('base, meta[generator]').and_return([])
      @html.doc.should_receive(:search).with('//comment()').and_return(mock_nodes)
      mock_nodes.should_receive(:remove).and_return([mock_node])
      @html.send(:update) 
    end
  end

  describe Snatch::Clean::HTML::HrefFixMethods do
    subject { mock.extend(Snatch::Clean::HTML::HrefFixMethods) }

    it 'should remove a trailing index.html' do
      fix_node(:remove_index_html, '<a href="/blah/index.html"></a>') do |node|
        node.should have_href('/blah/')
      end
    end

    it 'should replace an absolute CMS URL with a domainless absolute URL' do
      anchor = %Q{<a href="http://#{Snatch::MARKETING_SITE}/folder"></a>}
      fix_node(:replace_absolute, anchor) do |node|
        node.should have_href('/folder')
      end
    end

    it 'should encode email addresses' do
      anchor = %Q{<a href="mailto:blah@exåmplé.cøm">blah@exåmplé.cøm</a>}
      @html.class.should_receive(:url_encode).and_return('url_encode')
      @html.class.should_receive(:html_encode).and_return('html_encode')
      fix_node(:encode_mailtos, anchor) do |node|
        node.should have_href('mailto:url_encode')
        node.text.should == 'html_encode'
      end
    end

    describe "leading slashes and colons" do
      it 'should append a slash when there is no colon' do
        fix_node(:prepend_slash, %Q{<a href="blah/file.txt"></a>}) do |node|
          node.should have_href('/blah/file.txt')
        end
      end

      it 'should not append a slash when there is a colon' do
        fix_node(:prepend_slash, %Q{<a href="blah/file:wtf.txt"></a>}) do |node|
          node.should have_href('blah/file:wtf.txt')
        end
      end

      it 'should not add two slashes' do
        fix_node(:prepend_slash, %Q{<a href="/blah/file.txt"></a>}) do |node|
          node.should have_href('/blah/file.txt')
        end
      end
    end

    describe "trailing slash" do
      it 'with a period' do
        fix_node(:append_slash, %Q{<a href="file.extension"></a>}) do |node|
          node.should have_href('file.extension')
        end
      end

      it 'with a hash' do
        fix_node(:append_slash, %Q{<a href="blah#anchor"></a>"}) do |node|
          node.should have_href('blah#anchor')
        end
      end

      it 'with a colon' do
        # When would this ever happen?
        fix_node(:append_slash, %Q{<a href="user:pass@domain.com"></a>}) do |node|
          node.should have_href('user:pass@domain.com')
        end
      end

      it 'should not duplicate slashes' do
        fix_node(:append_slash, %Q{<a href="folder/"></a>}) do |node|
          node.should have_href('folder/')
        end
      end
    end
  end

  describe Snatch::Clean::HTML::SrcFixMethods do
    subject { mock.extend(Snatch::Clean::HTML::SrcFixMethods) }

    it 'should replace an absolute CMS URL with a domainless absolute URL' do
      link = %Q{<link src="http://#{Snatch::MARKETING_SITE}/folder"></a>}
      fix_node(:replace_absolute, link) do |node|
        node.should have_src('/folder')
      end
    end

    it 'should make upload URLs absolute and root' do
      link = %Q{<link src="uploads/some-image.png"></link>}
      fix_node(:rewrite_uploads, link) do |node|
        node.should have_src('/uploads/some-image.png')
      end
    end
  end
end

