Spec::Matchers.define :have_href do |expected|
  match do |actual|
    expected.should == actual['href']
  end

  failure_message_for_should do |actual|
    "expected href to equal #{expected} but got #{actual['href']}"
  end

  failure_message_for_should_not do |actual|
    "expected href to not equal #{expected}"
  end

  description do
    "be equal to #{expected}"
  end
end

Spec::Matchers.define :have_src do |expected|
  match do |actual|
    expected.should == actual['src']
  end

  failure_message_for_should do |actual|
    "expected src to equal #{expected} but got #{actual['src']}"
  end

  failure_message_for_should_not do |actual|
    "expected src to not equal #{expected}"
  end

  description do
    "be equal to #{expected}"
  end
end

