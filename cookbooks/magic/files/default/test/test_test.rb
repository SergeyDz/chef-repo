require 'minitest/spec'

describe_recipe 'test' do
  it 'has generated the expected configs' do
    Dir['/tmp/expect/*.conf'].each do |conf_path|
      config = File.read(conf_path)
      expect = File.read(conf_path + '.expect')
      assert_equal expect, config
    end
  end

  it 'has reified the htop package' do
    `which htop`
    assert $?.exitstatus.zero?
  end

  it 'has reified the vim package' do
    `which vim`
    assert $?.exitstatus.zero?
  end
end