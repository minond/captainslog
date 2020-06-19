describe Api::V1::EntriesController, :type => :controller do
  let(:user) { create(:user) }
  let(:book) { create(:book, :user => user) }

  describe "POST /api/v1/books/:book_id/entries" do
    let(:entry_params) do
      {
        :book_id => book.id,
        :times => [Time.now.to_i] * 3,
        :texts => %i[one two three]
      }
    end

    let(:expected_new_entry_count) { entry_params[:texts].size }

    it "requires authentication" do
      post :create, :params => entry_params
      expect(response).to have_http_status(:unauthorized)
    end

    context "when authenticated" do
      before do
        request.headers["Authorization"] = "Bearer #{user.jwt}"
      end

      it "succeeds" do
        post :create, :params => entry_params
        expect(response).to have_http_status(:no_content)
      end

      it "creates an entry for every text parameter" do
        expect { post :create, :params => entry_params }
          .to change { user.entries.count }.by expected_new_entry_count
      end
    end
  end
end
