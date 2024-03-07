require 'spec_helper'

describe AppStage::DeleteFiles do
    describe 'with invalid arguments' do
        it 'should require a access token' do
            options = {}
            @upload_file = AppStage::DeleteFiles.new(options)

            expect(STDOUT).to receive(:puts).with('Delete failed - Invalid project token')
            expect(@upload_file.execute).to eq(-1)
        end
    end

    describe 'when the delete fails because of unauthorised' do
        it 'should return the error request throws' do
            options = {jwt: "1239834u34hf"}
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_return(body: '{"error":"Not Authorized"}', status: 401)
            stub_request(:delete, "https://www.appstage.io/api/live_builds").to_return(body: '{"error":"Not Authorized"}', status: 401)

            expect(STDOUT).to receive(:puts).with('Delete failed - Not Authorized')
            expect(AppStage::DeleteFiles.new(options).execute).to eq(-1)
        end
    end

    describe 'when the delete succeeds without a filter' do
        it 'should return the list of files' do
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_return(
                body: '{"release_files":[{"id":"aebfdf12-e73e-4ccf-9b73-dd0f6156d1de","name":"Motorise_V1.0.2.82.apk","created_at":"2024-02-23T09:39:50.823Z","size":65896856},{"id":"5d6c50ab-9985-4835-84d6-048846ff345a","name":"Motorise_V1.0.2.82.ipa","created_at":"2024-02-23T09:40:11.965Z","size":28409809}]}',
                status: 200
            )
            stub_request(:delete, "https://www.appstage.io/api/live_builds/aebfdf12-e73e-4ccf-9b73-dd0f6156d1de").to_return(status: 200)
            stub_request(:delete, "https://www.appstage.io/api/live_builds/5d6c50ab-9985-4835-84d6-048846ff345a").to_return(status: 200)
            
            expect(STDOUT).to receive(:puts).with('Deleting 2 files')
            expect(STDOUT).to receive(:puts).with(' deleting Motorise_V1.0.2.82.apk')
            expect(STDOUT).to receive(:puts).with(' deleting Motorise_V1.0.2.82.ipa')

            options = {jwt: "1239834u34hf"}
            expect(AppStage::DeleteFiles.new(options).execute).to eq(0)
        end
    end

    describe 'when the delete succeeds with a filter' do
        it 'should return the list of files' do
            stub_request(:get, "https://www.appstage.io/api/live_builds").to_return(
                body: '{"release_files":[{"id":"aebfdf12-e73e-4ccf-9b73-dd0f6156d1de","name":"Motorise_V1.0.2.82.apk","created_at":"2024-02-23T09:39:50.823Z","size":65896856},{"id":"5d6c50ab-9985-4835-84d6-048846ff345a","name":"Motorise_V1.0.2.82.ipa","created_at":"2024-02-23T09:40:11.965Z","size":28409809}]}',
                status: 200
            )
            stub_request(:delete, "https://www.appstage.io/api/live_builds/5d6c50ab-9985-4835-84d6-048846ff345a").to_return(status: 200)
            
            expect(STDOUT).to receive(:puts).with('Deleting 1 files')
            expect(STDOUT).to receive(:puts).with(' deleting Motorise_V1.0.2.82.ipa')

            options = {jwt: "1239834u34hf", delete: '.ipa'}
            expect(AppStage::DeleteFiles.new(options).execute).to eq(0)
        end
    end
end