require 'spec_helper'

RSpec.describe AppStage::UploadFile do
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

    describe 'file validation' do
        it 'should handle non-existent files' do
            options = {jwt: "token", upload: './non_existent_file.txt'}
            
            expect(STDOUT).to receive(:puts).with(/Upload failed/)
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end
    end

    describe 'with custom host' do
        it 'should use the provided host URL' do
            options = {jwt: "token", upload: './spec/fixtures/testfile.txt', host: "https://custom.appstage.io"}
            mock_multipart_request('https://custom.appstage.io/api/live_builds', 200, {"id": "test"})

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with('Upload complete')
            expect(AppStage::UploadFile.new(options).execute).to eq(0)
        end
    end

    describe 'error handling' do
        it 'should handle network errors gracefully' do
            options = {jwt: "token", upload: './spec/fixtures/testfile.txt'}
            stub_request(:post, "https://www.appstage.io/api/live_builds")
                .to_raise(Net::ReadTimeout)

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with(/Upload failed/)
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end

        it 'should handle server errors' do
            options = {jwt: "token", upload: './spec/fixtures/testfile.txt'}
            mock_multipart_request('https://www.appstage.io/api/live_builds', 500, {"error": "Internal Server Error"})

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with('Upload failed - Internal Server Error')
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end

        it 'should handle malformed JSON response' do
            options = {jwt: "token", upload: './spec/fixtures/testfile.txt'}
            headers = { 'Content-Type' => /multipart\/form-data/ }
            match_multipart_body = ->(request) do
                request.body.force_encoding('BINARY')
                request.body =~ /testfile.txt/
            end
            stub_request(:post, "https://www.appstage.io/api/live_builds")
                .with(headers: headers, &match_multipart_body)
                .to_return(body: 'invalid json', status: 200)

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with(/Upload failed/)
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end
    end

    describe 'authentication' do
        it 'should include JWT token in Authorization header' do
            token = "test-jwt-token"
            options = {jwt: token, upload: './spec/fixtures/testfile.txt'}
            
            stub = stub_request(:post, "https://www.appstage.io/api/live_builds")
                .with(headers: { 'Authorization' => "Bearer #{token}" })
                .to_return(body: '{"id": "test"}', status: 200)

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with('Upload complete')
            AppStage::UploadFile.new(options).execute
            expect(stub).to have_been_requested
        end
    end
end