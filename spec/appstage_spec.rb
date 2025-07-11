require 'spec_helper'
require 'stringio'

RSpec.describe AppStage do
  describe '.execute' do
    let(:original_stdout) { $stdout }
    let(:original_stderr) { $stderr }
    let(:stdout) { StringIO.new }
    let(:stderr) { StringIO.new }

    before do
      $stdout = stdout
      $stderr = stderr
      ARGV.clear
    end

    after do
      $stdout = original_stdout
      $stderr = original_stderr
      ARGV.clear
    end

    context 'when no command is provided' do
      it 'shows help and exits with code 1' do
        expect { described_class.execute }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
        expect(stdout.string).to include('Usage: appstage <command> [options]')
      end
    end

    context 'when invalid option is provided' do
      before { ARGV << '--invalid-option' }

      it 'shows error message and exits with code 1' do
        expect { described_class.execute }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
        expect(stdout.string).to include('Invalid invocation')
      end
    end

    context 'when -h or --help is provided' do
      let(:list_files_instance) { instance_double(AppStage::ListFiles) }
      
      before do 
        ARGV << '-l' << '--help'
        stub_const("AppStage::ListFiles", Class.new)
        allow(AppStage::ListFiles).to receive(:new).and_return(list_files_instance)
        allow(list_files_instance).to receive(:execute).and_return(0)
      end

      it 'shows help message and continues execution' do
        expect { described_class.execute }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
        expect(stdout.string).to include('Usage: appstage <command> [options]')
        expect(stdout.string).to include('Commands:-')
        expect(stdout.string).to include('Options:-')
      end
    end

    context 'when list command is provided' do
      let(:list_files_instance) { instance_double(AppStage::ListFiles) }

      before do
        ARGV << '-l' << '-j' << 'test-token'
        stub_const("AppStage::ListFiles", Class.new)
        allow(AppStage::ListFiles).to receive(:new).with(hash_including(list: nil, jwt: 'test-token')).and_return(list_files_instance)
        allow(list_files_instance).to receive(:execute).and_return(0)
      end

      it 'creates ListFiles instance and executes it' do
        expect { described_class.execute }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
        expect(AppStage::ListFiles).to have_received(:new)
        expect(list_files_instance).to have_received(:execute)
      end
    end

    context 'when delete command is provided' do
      let(:delete_files_instance) { instance_double(AppStage::DeleteFiles) }

      before do
        ARGV << '-d' << '.*\.ipa' << '-j' << 'test-token'
        allow(AppStage::DeleteFiles).to receive(:new).with(hash_including(delete: '.*\.ipa', jwt: 'test-token')).and_return(delete_files_instance)
        allow(delete_files_instance).to receive(:execute).and_return(0)
      end

      it 'creates DeleteFiles instance and executes it' do
        expect { described_class.execute }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
        expect(AppStage::DeleteFiles).to have_received(:new)
        expect(delete_files_instance).to have_received(:execute)
      end
    end

    context 'when upload command is provided' do
      let(:upload_file_instance) { instance_double(AppStage::UploadFile) }

      before do
        ARGV << '-u' << 'test.ipa' << '-j' << 'test-token'
        allow(AppStage::UploadFile).to receive(:new).with(hash_including(upload: 'test.ipa', jwt: 'test-token')).and_return(upload_file_instance)
        allow(upload_file_instance).to receive(:execute).and_return(0)
      end

      it 'creates UploadFile instance and executes it' do
        expect { described_class.execute }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
        expect(AppStage::UploadFile).to have_received(:new)
        expect(upload_file_instance).to have_received(:execute)
      end
    end

    context 'when host option is provided' do
      let(:list_files_instance) { instance_double(AppStage::ListFiles) }

      before do
        ARGV << '-l' << '-j' << 'test-token' << '-h' << 'https://custom.host.com'
        allow(AppStage::ListFiles).to receive(:new).with(hash_including(host: 'https://custom.host.com')).and_return(list_files_instance)
        allow(list_files_instance).to receive(:execute).and_return(0)
      end

      it 'passes host option to command' do
        expect { described_class.execute }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
        expect(AppStage::ListFiles).to have_received(:new).with(hash_including(host: 'https://custom.host.com'))
      end
    end
  end
end