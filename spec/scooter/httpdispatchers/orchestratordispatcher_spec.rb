require 'spec_helper'

describe Scooter::HttpDispatchers::OrchestratorDispatcher do

  let(:orchestrator_api) { Scooter::HttpDispatchers::OrchestratorDispatcher.new(host) }
  let(:job_id) { random_string }
  let(:environment) {random_string}


  unixhost = { roles:     ['test_role'],
                   'platform' => 'debian-7-x86_64' }
  let(:host) { Beaker::Host.create('test.com', unixhost, {}) }

  subject { orchestrator_api }

  before do
    expect(OpenSSL::PKey).to receive(:read).and_return('Pkey')
    expect(OpenSSL::X509::Certificate).to receive(:new).and_return('client_cert')
    allow_any_instance_of(Scooter::HttpDispatchers::OrchestratorDispatcher).to receive(:get_host_cert) {'host cert'}
    allow_any_instance_of(Scooter::HttpDispatchers::OrchestratorDispatcher).to receive(:get_host_private_key) {'key file'}
    allow_any_instance_of(Scooter::HttpDispatchers::OrchestratorDispatcher).to receive(:get_host_cacert) {'cert file'}
    expect(subject).to be_kind_of(Scooter::HttpDispatchers::OrchestratorDispatcher)
  end

  it 'should make requests on the correct port' do
    expect(orchestrator_api.connection.url_prefix.port).to be(8143)
  end

  it 'should use the correct path prefix' do
    expect(orchestrator_api.connection.url_prefix.path).to eq('/orchestrator')
  end

  describe '.list_jobs' do

    it { is_expected.to respond_to(:list_jobs).with(0).arguments }
    it { is_expected.to respond_to(:list_jobs).with(1).arguments }
    it { is_expected.not_to respond_to(:list_jobs).with(2).arguments }

    it 'should take a job_id' do
      expect(orchestrator_api.connection).to receive(:get).with('v1/jobs')
      expect{ orchestrator_api.list_jobs }.not_to raise_error
    end
  end

  describe '.list_job_details' do

    it { is_expected.not_to respond_to(:list_job_details).with(0).arguments }
    it { is_expected.to respond_to(:list_job_details).with(1).arguments }

    it 'should take a job_id' do
      expect(orchestrator_api.connection).to receive(:get).with("v1/jobs/#{job_id}")
      expect{ orchestrator_api.list_job_details(job_id) }.not_to raise_error
    end
  end

  describe '.list_nodes_associated_with_job' do

    it { is_expected.not_to respond_to(:list_nodes_associated_with_job).with(0).arguments }
    it { is_expected.to respond_to(:list_nodes_associated_with_job).with(1).arguments }

    it 'should take a job_id' do
      expect(orchestrator_api.connection).to receive(:get).with("v1/jobs/#{job_id}/nodes")
      expect{ orchestrator_api.list_nodes_associated_with_job(job_id) }.not_to raise_error
    end
  end

  describe '.get_job_report' do

    it { is_expected.not_to respond_to(:get_job_report).with(0).arguments }
    it { is_expected.to respond_to(:get_job_report).with(1).arguments }


    it 'should take a job_id' do
      expect(orchestrator_api.connection).to receive(:get).with("v1/jobs/#{job_id}/report")
      expect{ orchestrator_api.get_job_report(job_id) }.not_to raise_error
    end
  end

  describe '.get_job_events' do

    it { is_expected.not_to respond_to(:get_job_events).with(0).arguments }
    it { is_expected.to respond_to(:get_job_events).with(1).arguments }

    it 'should take a job_id' do
      expect(orchestrator_api.connection).to receive(:get).with("v1/jobs/#{job_id}/events")
      expect{ orchestrator_api.get_job_events(job_id) }.not_to raise_error
    end
  end

  describe '.environment' do
    it { is_expected.not_to respond_to(:environment).with(0).arguments }
    it { is_expected.to respond_to(:environment).with(1).arguments }

    it 'should take a environment name' do
      expect(orchestrator_api.connection).to receive(:get).with("v1/environments/#{environment}")
      expect{ orchestrator_api.environment(environment) }.not_to raise_error
    end
  end

  describe '.list_applications' do
    it { is_expected.not_to respond_to(:list_applications).with(0).arguments }
    it { is_expected.to respond_to(:list_applications).with(1).arguments }

    it 'should take a environment name' do
      expect(orchestrator_api.connection).to receive(:get).with("v1/environments/#{environment}/applications")
      expect{ orchestrator_api.list_applications(environment) }.not_to raise_error
    end
  end

  describe '.list_app_instances' do
    it { is_expected.not_to respond_to(:list_app_instances).with(0).arguments }
    it { is_expected.to respond_to(:list_app_instances).with(1).arguments }

    it 'should take a environment name' do
      expect(orchestrator_api.connection).to receive(:get).with("v1/environments/#{environment}/instances")
      expect{ orchestrator_api.list_app_instances(environment) }.not_to raise_error
    end
  end

  describe '.deploy_environment' do
    it { is_expected.not_to respond_to(:deploy_environment).with(0).arguments }
    it { is_expected.to respond_to(:deploy_environment).with(1).arguments }
    it { is_expected.to respond_to(:deploy_environment).with(2).arguments }

    it 'should take an environment name' do
      expect(orchestrator_api.connection).to receive(:post).with("v1/command/deploy")
      expect{ orchestrator_api.deploy_environment(environment) }.not_to raise_error
    end

    it 'should take an environment and a opts hash' do
      opts = {'noop' => true, 'concurency' => 5}

      expect(orchestrator_api.connection).to receive(:post).with("v1/command/deploy")
      expect{ orchestrator_api.deploy_environment(environment, opts) }.not_to raise_error
    end
  end

  describe '.stop_job' do
    it { is_expected.not_to respond_to(:stop_job).with(0).arguments }
    it { is_expected.to respond_to(:stop_job).with(1).arguments }
    it { is_expected.not_to respond_to(:stop_job).with(2).arguments }

    it 'should take a job id' do
      expect(orchestrator_api.connection).to receive(:post).with("v1/command/stop")
      expect{ orchestrator_api.stop_job(job_id) }.not_to raise_error
    end
  end

  describe '.plan_job' do
    it { is_expected.not_to respond_to(:plan_job).with(0).arguments }
    it { is_expected.to respond_to(:plan_job).with(1).arguments }
    it { is_expected.to respond_to(:plan_job).with(2).arguments }

    it 'should take an environment name' do
      expect(orchestrator_api.connection).to receive(:post).with("v1/command/plan")
      expect{ orchestrator_api.plan_job(environment) }.not_to raise_error
    end

    it 'should take an environment and a opts hash' do
      opts = {'noop' => true, 'concurency' => 5}

      expect(orchestrator_api.connection).to receive(:post).with("v1/command/plan")
      expect{ orchestrator_api.plan_job(environment, opts) }.not_to raise_error
    end
  end

  describe '.get_inventory' do
    let(:certname) {'thisismycertname'}

    it {is_expected.to respond_to(:get_inventory).with(0).arguments }
    it {is_expected.to respond_to(:get_inventory).with(1).arguments }
    it {is_expected.not_to respond_to(:get_inventory).with(2).arguments }

    it 'should take a single certname' do
      expect(orchestrator_api.connection).to receive(:get).with("v1/inventory/#{certname}")
      expect{ orchestrator_api.get_inventory(certname) }.not_to raise_error
    end

    it 'should take no argument' do
      expect(orchestrator_api.connection).to receive(:get).with("v1/inventory")
      expect{ orchestrator_api.get_inventory }.not_to raise_error
    end
  end

  describe '.nodes_connected_to_broker' do
    let(:certnames) {['certnameone', 'certnametwo', 'certnamethree']}

    it {is_expected.not_to respond_to(:nodes_connected_to_broker).with(0).arguments }
    it {is_expected.to respond_to(:nodes_connected_to_broker).with(1).arguments }
    it {is_expected.not_to respond_to(:nodes_connected_to_broker).with(2).arguments }

    it 'should take an array of certnames' do
      expect(orchestrator_api.connection).to receive(:post).with("v1/inventory")
      expect{ orchestrator_api.nodes_connected_to_broker(certnames) }.not_to raise_error
    end
  end

  describe '.get_status' do

    it {is_expected.to respond_to(:get_status).with(0).arguments }
    it {is_expected.not_to respond_to(:get_status).with(1).arguments }

    it 'should take no argument' do
      expect(orchestrator_api.connection).to receive(:get).with("v1/status")
      expect{ orchestrator_api.get_status }.not_to raise_error
    end
  end
end
