require 'spec_helper'

describe 'prometheus::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache') do
    end.converge(described_recipe)
  end

  it 'creates a user with correct attributes' do
    expect(chef_run).to create_user('prometheus').with(
      system: true,
      shell: '/bin/false',
      home: '/opt/prometheus'
    )
  end

  it 'creates a directory at /opt/prometheus' do
    expect(chef_run).to create_directory('/opt/prometheus').with(
      owner: 'prometheus',
      group: 'prometheus',
      mode: '0755',
      recursive: true
    )
  end

  it 'creates a directory at /var/log/prometheus' do
    expect(chef_run).to create_directory('/var/log/prometheus').with(
      owner: 'prometheus',
      group: 'prometheus',
      mode: '0755',
      recursive: true
    )
  end

  it 'renders a prometheus job configuration file and notifies prometheus to restart' do
    resource = chef_run.template('/opt/prometheus/prometheus.yml')
    expect(resource).to notify('service[prometheus]').to(:restart)
  end
end
