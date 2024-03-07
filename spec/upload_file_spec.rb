require 'spec_helper'

describe AppStage::UploadFile do
    describe 'with invalid arguments' do
        it 'should require a access token' do
            options = {upload: "testfile.txt"}
            @upload_file = AppStage::UploadFile.new(options)

            expect(STDOUT).to receive(:puts).with('Upload failed - Invalid project token')
            expect(@upload_file.execute).to eq(-1)
        end

        it 'should require a file to upload' do
            options = {jwt: "1239834u34hf"}
            @upload_file = AppStage::UploadFile.new(options)

            expect(STDOUT).to receive(:puts).with('Upload failed - No file specified')
            expect(@upload_file.execute).to eq(-1)
        end
    end

    describe 'when the upload fails' do
        it 'should return the error request throws' do
            options = {jwt: "1239834u34hf", upload: './spec/fixtures/testfile.txt'}
            mock_multipart_request('https://www.appstage.io/api/live_builds', 401, {"error":"Not Authorized"})

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with('Upload failed - Not Authorized')
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end
    end

    describe 'when the upload succeeds' do
        it 'should return success' do
            mock_multipart_request('https://www.appstage.io/api/live_builds', 200, 
                {"created_at":"2024-03-07T10:52:16.673Z","display_name":"readme.md","id":"ec6b6c76-6358-44f2-b2b3-044053a2067b","release_id":"d6d98189-584f-4a76-924a-b58867a1d579"})

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with('Upload complete')
            options = {jwt: "1239834u34hf", upload: './spec/fixtures/testfile.txt'}
            expect(AppStage::UploadFile.new(options).execute).to eq(0)
        end
    end
end