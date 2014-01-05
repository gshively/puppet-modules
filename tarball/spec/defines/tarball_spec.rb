require 'spec_helper'

describe 'tarball' do
	let(:title)  { 'package-1.0.tar.gz' }
    let(:params) { {:source => 'src_url',} }	
	it {should compile}
end
