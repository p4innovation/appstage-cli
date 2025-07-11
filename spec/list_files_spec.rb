require 'spec_helper'

RSpec.describe AppStage::ListFiles do
    describe 'with invalid arguments' do
        it 'should require a access token' do
            options = {}
            @upload_file = AppStage::ListFiles.new(options)

            expect(STDOUT).to receive(:puts).with('File listing failed - Invalid project token')
            expect(@upload_file.execute).to eq(-1)
        end
    end

    describe 'when the listing fails' do
        it 'should return the error request throws' do
            options = {jwt: "1239834u34hf"}
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_return(body: '{"error":"Not Authorized"}', status: 401)

            expect(STDOUT).to receive(:puts).with('File listing failed - Not Authorized')
            expect(AppStage::ListFiles.new(options).execute).to eq(-1)
        end
    end

    describe 'when the listing succeeds' do
        it 'should return the list of files' do
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_return(
                body: '{"release_files":[{"id":"aebfdf12-e73e-4ccf-9b73-dd0f6156d1de","name":"Motorise_V1.0.2.82.apk","created_at":"2024-02-23T09:39:50.823Z","size":65896856},{"id":"5d6c50ab-9985-4835-84d6-048846ff345a","name":"Motorise_V1.0.2.82.ipa","created_at":"2024-02-23T09:40:11.965Z","size":28409809}]}',
                status: 200
            )

            expect(STDOUT).to receive(:puts).with('Motorise_V1.0.2.82.apk')
            expect(STDOUT).to receive(:puts).with('Motorise_V1.0.2.82.ipa')
            options = {jwt: "1239834u34hf", upload: './spec/fixtures/testfile.txt'}
            expect(AppStage::ListFiles.new(options).execute).to eq(0)
        end
    end

    describe 'listing with a filter' do
        it 'should return the list of files' do
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_return(
                body: '{"release_files":[{"id":"aebfdf12-e73e-4ccf-9b73-dd0f6156d1de","name":"Motorise_V1.0.2.82.apk","created_at":"2024-02-23T09:39:50.823Z","size":65896856},{"id":"5d6c50ab-9985-4835-84d6-048846ff345a","name":"Motorise_V1.0.2.82.ipa","created_at":"2024-02-23T09:40:11.965Z","size":28409809}]}',
                status: 200
            )

            expect(STDOUT).to receive(:puts).with('Motorise_V1.0.2.82.ipa')
            options = {jwt: "1239834u34hf", upload: './spec/fixtures/testfile.txt', list: '.ipa'}
            expect(AppStage::ListFiles.new(options).execute).to eq(0)
        end

        it 'should filter files using regex pattern' do
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_return(
                body: '{"release_files":[{"id":"1","name":"app-v1.0.ipa","created_at":"2024-02-23T09:39:50.823Z","size":1000},{"id":"2","name":"app-v2.0.ipa","created_at":"2024-02-23T09:40:11.965Z","size":2000},{"id":"3","name":"app-v1.0.apk","created_at":"2024-02-23T09:40:11.965Z","size":3000}]}',
                status: 200
            )

            expect(STDOUT).to receive(:puts).with('app-v1.0.ipa')
            expect(STDOUT).to receive(:puts).with('app-v2.0.ipa')
            options = {jwt: "token", list: '\.ipa$'}
            expect(AppStage::ListFiles.new(options).execute).to eq(0)
        end

        it 'should handle complex regex patterns' do
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_return(
                body: '{"release_files":[{"id":"1","name":"app-v1.0.ipa"},{"id":"2","name":"app-v2.0.ipa"},{"id":"3","name":"app-debug-v1.0.ipa"}]}',
                status: 200
            )

            expect(STDOUT).to receive(:puts).with('app-v1.0.ipa')
            expect(STDOUT).to receive(:puts).with('app-v2.0.ipa')
            options = {jwt: "token", list: 'app-v\d+\.\d+\.ipa'}
            expect(AppStage::ListFiles.new(options).execute).to eq(0)
        end
    end

    describe 'with custom host' do
        it 'should use the provided host URL' do
            options = {jwt: "token", host: "https://custom.appstage.io"}
            stub_request(:get, "https://custom.appstage.io/api/live_builds").to_return(
                body: '{"release_files":[{"id":"1","name":"test.ipa"}]}',
                status: 200
            )

            expect(STDOUT).to receive(:puts).with('test.ipa')
            expect(AppStage::ListFiles.new(options).execute).to eq(0)
        end
    end

    describe 'error handling' do
        it 'should handle network errors gracefully' do
            options = {jwt: "token"}
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_raise(Net::ReadTimeout)

            expect(STDOUT).to receive(:puts).with(/File listing failed/)
            expect(AppStage::ListFiles.new(options).execute).to eq(-1)
        end

        it 'should handle malformed JSON response' do
            options = {jwt: "token"}
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_return(
                body: 'invalid json',
                status: 200
            )

            expect(STDOUT).to receive(:puts).with(/File listing failed/)
            expect(AppStage::ListFiles.new(options).execute).to eq(-1)
        end
    end

    describe 'when release_files is empty' do
        it 'should not output anything' do
            options = {jwt: "token"}
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_return(
                body: '{"release_files":[]}',
                status: 200
            )

            expect(STDOUT).not_to receive(:puts)
            expect(AppStage::ListFiles.new(options).execute).to eq(0)
        end
    end
end