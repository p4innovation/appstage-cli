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
            mock_direct_upload_error('https://www.appstage.io', 401, "Not Authorized")

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with('Upload failed - Not Authorized')
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end
    end

    describe 'when the upload succeeds' do
        it 'should return success' do
            mock_direct_upload_flow('https://www.appstage.io')

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
            mock_direct_upload_flow('https://custom.appstage.io')

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with('Upload complete')
            expect(AppStage::UploadFile.new(options).execute).to eq(0)
        end
    end

    describe 'error handling' do
        it 'should handle network errors gracefully' do
            options = {jwt: "token", upload: './spec/fixtures/testfile.txt'}
            stub_request(:post, "https://www.appstage.io/api/direct_uploads")
                .to_raise(Net::ReadTimeout)

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with(/Upload failed/)
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end

        it 'should handle server errors' do
            options = {jwt: "token", upload: './spec/fixtures/testfile.txt'}
            mock_direct_upload_error('https://www.appstage.io', 500, "Internal Server Error")

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with('Upload failed - Internal Server Error')
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end

        it 'should handle malformed JSON response' do
            options = {jwt: "token", upload: './spec/fixtures/testfile.txt'}
            stub_request(:post, "https://www.appstage.io/api/direct_uploads")
                .to_return(body: 'invalid json', status: 200)

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with(/Upload failed/)
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end

        it 'should handle CDN upload failure' do
            options = {jwt: "token", upload: './spec/fixtures/testfile.txt'}
            cdn_url = "https://s3.amazonaws.com/test-bucket/uploads/test-key"

            stub_request(:post, "https://www.appstage.io/api/direct_uploads")
                .to_return(body: {
                    signed_id: "test-signed-blob-id",
                    direct_upload: {
                        url: cdn_url,
                        headers: { "Content-Type" => "application/octet-stream" }
                    }
                }.to_json, status: 200)

            stub_request(:put, cdn_url)
                .to_return(body: "", status: 500)

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with(/Upload failed.*CDN upload failed/)
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end

        it 'should handle release creation failure' do
            options = {jwt: "token", upload: './spec/fixtures/testfile.txt'}
            cdn_url = "https://s3.amazonaws.com/test-bucket/uploads/test-key"
            signed_id = "test-signed-blob-id"

            stub_request(:post, "https://www.appstage.io/api/direct_uploads")
                .to_return(body: {
                    signed_id: signed_id,
                    direct_upload: {
                        url: cdn_url,
                        headers: { "Content-Type" => "application/octet-stream" }
                    }
                }.to_json, status: 200)

            stub_request(:put, cdn_url)
                .to_return(body: "", status: 200)

            stub_request(:post, "https://www.appstage.io/api/live_builds")
                .with(body: { signed_blob_id: signed_id }.to_json)
                .to_return(body: { error: "Storage quota exceeded" }.to_json, status: 422)

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with('Upload failed - Storage quota exceeded')
            expect(AppStage::UploadFile.new(options).execute).to eq(-1)
        end
    end

    describe 'authentication' do
        it 'should include JWT token in Authorization header' do
            token = "test-jwt-token"
            options = {jwt: token, upload: './spec/fixtures/testfile.txt'}
            cdn_url = "https://s3.amazonaws.com/test-bucket/uploads/test-key"
            signed_id = "test-signed-blob-id"

            direct_upload_stub = stub_request(:post, "https://www.appstage.io/api/direct_uploads")
                .with(headers: { 'Authorization' => "Bearer #{token}" })
                .to_return(body: {
                    signed_id: signed_id,
                    direct_upload: {
                        url: cdn_url,
                        headers: { "Content-Type" => "application/octet-stream" }
                    }
                }.to_json, status: 200)

            stub_request(:put, cdn_url)
                .to_return(body: "", status: 200)

            release_stub = stub_request(:post, "https://www.appstage.io/api/live_builds")
                .with(
                    headers: { 'Authorization' => "Bearer #{token}" },
                    body: { signed_blob_id: signed_id }.to_json
                )
                .to_return(body: '{"id": "test"}', status: 200)

            expect(STDOUT).to receive(:puts).with('Uploading testfile.txt 25 bytes...')
            expect(STDOUT).to receive(:puts).with('Upload complete')
            AppStage::UploadFile.new(options).execute
            expect(direct_upload_stub).to have_been_requested
            expect(release_stub).to have_been_requested
        end
    end
end