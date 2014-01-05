require 'spec_helper'

describe 'tarball' do

	context 'without source passed' do
		let(:title)  { 'package-1.0.tar.gz' }
		let(:params) { {} }
		it { expect { should compile }.to raise_error(Puppet::Error) }
	end

	context 'with source passed' do
		let(:title)  { 'package-1.0.tar.gz' }
		let(:params) { {:source => 'src_url',} }
		it { should compile }
	end

	context 'with binary package without extract_dir defined' do
		let(:title)  { 'package-1.0.bin' }
		let(:params) { {:source => 'src_url',} }
		it do 
			expect { 
				should compile 
			}.to raise_error(Puppet::Error, /extract_dir/)
		end
	end

	context 'with binary package with extract_dir defined' do
		let(:title)  { 'package-1.0.bin' }
		let(:params) { {:source => 'src_url', :extract_dir => 'extract_dir',} }
		it { should compile }
	end

	context 'tar.Z style packages' do
		let(:title)  { 'package-1.0.tar.Z' }
		let(:params) { {:source => 'src_url', :target => '/tmp' } }
		it do
			should compile
			should contain_file("/tmp/package-1.0").with({
				'ensure' => 'directory',
				'owner'  => 'root',
				'group'  => 'root',
				'noop'   => 'true',
			})
			should contain_file("/tmp/package-1.0")
				.that_requires('Exec[chown -R root:root /tmp/package-1.0]')

			should contain_exec("chown -R root:root /tmp/package-1.0")
				.that_subscribes_to('Exec[tar -xZf package-1.0.tar.Z]')
				.with_refreshonly('true')
		end
	end

	context 'tar.gz style packages' do
		let(:title)  { 'package-1.0.tar.gz' }
		let(:params) { {:source => 'src_url', :target => '/tmp' } }
		it { should contain_file("/tmp/package-1.0") }
	end

	context 'tgz style packages' do
		let(:title)  { 'package-1.0.tgz' }
		let(:params) { {:source => 'src_url', :target => '/tmp' } }
		it { should contain_file("/tmp/package-1.0") }
	end

	context 'noop file type created for requires' do
		let(:title)  {'package-1.0.tar.gz'}
		let(:params) { {:source => 'source_url', :target => '/tmp',}}
	end

	context 'with ensure => absent' do
		let(:title)  { 'package-1.0.tar.gz' }
		let(:params) { {:source => 'src_url', :ensure => 'absent'} }
		it do
			should contain_exec("rm -rf /opt/package-1.0")
		end
	end

end

