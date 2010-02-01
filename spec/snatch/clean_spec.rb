require 'spec_helper'

describe Snatch::Clean do
  before(:each) do
    File.stub!(:open)
  end

  it "should remove query params after a PHP CSS path" do
    clean    = Snatch::Clean.new('file_name')
    href     = '../../stylesheet.php?blah=woot'
    expected = '../../stylesheet.php'
    clean.send(:remove_query_params, href).should == expected
  end

  describe "rewrite_href" do
    before(:each) do
      @clean = Snatch::Clean.new('file_name')
    end

    it "should do nothing without an href" do
      @clean.send(:rewrite_href, '').should == ''
    end

    it "should move a top-level stylesheet file" do
      href = 'stylesheet.php?cssid=12&amp;mediatype=screen'
      @clean.should_receive(:mv_stylesheet).with(href, '12-screen.css')
      @clean.send(:rewrite_href, href)
    end

    it "should move a nested stylesheet file" do
      href = '../stylesheet.php?cssid=12&amp;mediatype=screen'
      @clean.should_receive(:mv_stylesheet).with(href, '../12-screen.css')
      @clean.send(:rewrite_href, href)
    end
  end

  describe "extract_path_components" do
    it "should find parents and values for cssid and mediatype" do
      clean    = Snatch::Clean.new('file_name')
      php_path = '/css/something/stylesheet.php?cssid=12&amp;mediatype=screen'
      path     = clean.send(:extract_path_components, php_path)
      path.to_a.should == ['/css/something/', '12', 'screen']
    end

    it "should find relative path compontents and values for cssid and mediatype" do
      clean    = Snatch::Clean.new('file_name')
      php_path = '../../stylesheet.php?cssid=12&amp;mediatype=screen'
      path     = clean.send(:extract_path_components, php_path)
      path.to_a.should == ['../../', '12', 'screen']
    end

    it "should find values for cssid and mediatype" do
      clean    = Snatch::Clean.new('file_name')
      php_path = 'stylesheet.php?cssid=12&amp;mediatype=screen'
      path     = clean.send(:extract_path_components, php_path)
      path.to_a.should == ['12', 'screen']
    end
  end

  describe "moving PHP files to CSS path" do
    it "should expand multiple paths to include the public directory" do
      clean       = Snatch::Clean.new('file_name')
      public_path = Snatch::PUBLIC_PATH
      expected = [
        File.expand_path(File.join(public_path, 'a/b')),
        File.expand_path(File.join(public_path, 'c/d'))
      ]
      clean.send(:expand_paths, 'a/b', 'c/d').should == expected
    end

    it "should assign multiple paths with a splat" do
      clean       = Snatch::Clean.new('file_name')
      public_path = Snatch::PUBLIC_PATH
      expected = [
        File.expand_path(File.join(public_path, 'a/b')),
        File.expand_path(File.join(public_path, 'c/d')),
        File.expand_path(File.join(public_path, 'e/f'))
      ]
      a, b, c = *clean.send(:expand_paths, 'a/b', 'c/d', 'e/f')
      a.should == expected.first
      b.should == expected.second
      c.should == expected.last
    end

    it "should expand absolute paths to include the public directory" do
      clean       = Snatch::Clean.new('file_name')
      public_path = Snatch::PUBLIC_PATH
      expected = [
        File.expand_path(File.join(public_path, '/a/b'))
      ]
      clean.send(:expand_paths, '/a/b').should == expected
    end
  end
end
