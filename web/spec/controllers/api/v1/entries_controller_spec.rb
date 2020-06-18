describe Api::V1::EntriesController, :type => :controller do
  let(:user) { create(:user) }
  let(:book) { create(:book, :user => user) }

  describe "POST /api/v1/books/:book_slug/entry" do
    let(:entry_params) do
      {
        :book_slug => book.slug,
        :text => "Running, 45min",
        :time => Time.now.to_i
      }
    end

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
        expect(response).to have_http_status(:ok)
      end

      it "creates an entry" do
        expect { post :create, :params => entry_params }
          .to change { user.entries.count }.by 1
      end
    end
  end

  describe "POST /api/v1/books/:book_slug/entries" do
    let(:entry_params) do
      {
        :book_slug => book.slug,
        :time => Time.now.to_i,
        :text => %i[one two three]
      }
    end

    let(:expected_new_entry_count) { entry_params[:text].size }

    it "requires authentication" do
      post :bulk_create, :params => entry_params
      expect(response).to have_http_status(:unauthorized)
    end

    context "when authenticated" do
      before do
        request.headers["Authorization"] = "Bearer #{user.jwt}"
      end

      it "succeeds" do
        post :bulk_create, :params => entry_params
        expect(response).to have_http_status(:no_content)
      end

      it "creates an entry for every text parameter" do
        expect { post :bulk_create, :params => entry_params }
          .to change { user.entries.count }.by expected_new_entry_count
      end
    end
  end
end
