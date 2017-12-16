require "test_helper"

class PullRequestTest < ActiveSupport::TestCase

  def setup
    @pr = Rick::PullRequest.new(Github.new(basic_auth: "gaetanm:#{ENV['GITHUB_SECRET_TOKEN']}"))
  end

  # PullRequest#retrieve
  def test_retrieve_sets_data_attribute
    VCR.use_cassette "github_pulls" do
      before = @pr.count
      after  = @pr.retrieve.count
      refute_equal before, after
    end
  end

  def test_retrieve_returns_pull_request_instance
    VCR.use_cassette "github_pulls" do
      assert_instance_of Rick::PullRequest, @pr.retrieve
    end
  end

  # PullRequest#opened
  def test_under_review_sets_data_with_pull_requests_under_review
    VCR.use_cassette "github_projects" do
      prs_under_review = 9
      assert_equal prs_under_review, @pr.retrieve.under_review.count
    end
  end

  def test_under_review_returns_pull_request_instance
    VCR.use_cassette "github_projects" do
      assert_instance_of Rick::PullRequest, @pr.under_review
    end
  end

  # PullRequest#old
  def test_old_sets_data_with_pull_requests_with_no_activity_since_the_given_number_of_day
    VCR.use_cassette "github_projects" do
      nbr_since_two_days = 6
      travel_to DateTime.new(2017, 12, 15) do
        assert_equal nbr_since_two_days, @pr.retrieve.under_review.old(2).count
      end
    end

    VCR.use_cassette "github_projects" do
      nbr_since_five_days = 1
      travel_to DateTime.new(2017, 12, 15) do
        assert_equal nbr_since_five_days, @pr.retrieve.under_review.old(5).count
      end
    end
  end

  def test_old_returns_pull_request_instance
    assert_instance_of Rick::PullRequest, @pr.old
  end
end