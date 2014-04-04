# coding: utf-8
require 'spec_helper'

describe Content do
  context "with a simple blog" do
  let!(:blog) { create(:blog) }

  describe "#short_url" do
    before do
      @content = FactoryGirl.build_stubbed :content,
        published: true,
        redirects: [FactoryGirl.build_stubbed(:redirect, :from_path =>
                                            "foo", :to_path => "bar")]
    end

    describe "normally" do
      let!(:blog) { create(:blog, base_url: "http://myblog.net") }

      it "returns the blog's base url combined with the redirection's from path" do
        @content.should be_published
        @content.short_url.should == "http://myblog.net/foo"
      end
    end

    describe "when the blog is in a sub-uri" do
      let!(:blog) { create(:blog, base_url: "http://myblog.net/blog") }

      it "includes the sub-uri path" do
        @content.short_url.should == "http://myblog.net/blog/foo"
      end
    end
  end

  describe "#text_filter" do
    it "returns nil by default" do
      @content = Content.new
      @content.text_filter.should be_nil
    end
  end

  describe "#really_send_notifications" do
    it "sends notifications to interested users" do
      @content = Content.new
      henri = mock_model(User)
      alice = mock_model(User)

      @content.should_receive(:notify_user_via_email).with henri
      @content.should_receive(:notify_user_via_email).with alice

      @content.should_receive(:interested_users).and_return([henri, alice])

      @content.really_send_notifications
    end
  end

  describe :search_posts_with do
    context "with an simple article" do
      subject { Content.search_with(params) }

      context "with nil params" do
        let(:params) { nil }
        it { expect(subject).to be_empty }
      end

      context "with a matching searchstring article" do
        let(:params) { {searchstring: 'a search string'} }
        let!(:match_article) { create(:article, body: 'there is a search string here') }
        it { expect(subject).to eq([match_article]) }
      end

      context "with an article published_at" do
        let(:params) { {published_at: '2012-02'} }
        let!(:article) { create(:article) }
        let!(:match_article) { create(:article, published_at: DateTime.new(2012,2,13)) }
        it { expect(subject).to eq([match_article]) }
      end

      context "with same user_id article" do
        let(:params) { {user_id: '13'} }
        let!(:article) { create(:article) }
        let!(:match_article) { create(:article, user_id: 13) }
        it { expect(subject).to eq([match_article]) }
      end

      context "with not published status article" do
        let(:params) { {published: '0' } }
        let!(:article) { create(:article) }
        let!(:match_article) { create(:article, published: false) }
        it { expect(subject).to eq([match_article]) }
      end

      context "with published status article" do
        let(:params) { {published: '1' } }
        let!(:article) { create(:article, published: true) }
        it { expect(subject).to eq([article]) }
      end
    end
  end
  end

  describe :generate_html do
    context "with a blog with textile filter" do
      let!(:blog) { create(:blog, comment_text_filter: 'textile') }

      context "comment with italic and bold" do
        let(:comment) {build(:comment, body: 'Comment body _italic_ *bold*')}

        it { expect(comment.generate_html(:body)).to match(/\<em\>italic\<\/em\>/) }
        it { expect(comment.generate_html(:body)).to match(/\<strong\>bold\<\/strong\>/) }
      end
    end

  end
end

