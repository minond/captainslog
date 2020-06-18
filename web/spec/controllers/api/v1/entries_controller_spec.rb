describe Api::V1::EntriesController, :type => :controller do
  let(:user) { create(:user) }
  let(:book) { create(:book, :user => user) }

  describe "POST /api/v1/books/:book_slug/entry" do
    let(:entry_params) {
      {
        :book_slug => book.slug,
        :text => "Running, 45min",
        :time => Time.now.to_i
      }
    }

    it "requires authentication" do
      post :create, :params => entry_params
      expect(response).to have_http_status(:unauthorized)
    end

    context "authenticated" do
      before do
        request.headers["Authorization"] = "Bearer #{user.jwt}"
      end

      it "creates an entry" do
        post :create, :params => entry_params
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
