class Admin::Poll::PollsController < Admin::BaseController
  load_and_authorize_resource
  before_action :load_search, only: [:search_booths, :search_questions, :search_officers]

  def index
  end

  def show
    @poll = Poll.includes(:questions, :booths, officers: [:user]).order('poll_questions.title', 'poll_booths.name', 'users.username').find(params[:id])
  end

  def new
  end

  def create
    if @poll.save
      redirect_to [:admin, @poll], notice: t("flash.actions.create.poll")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @poll.update(poll_params)
      redirect_to [:admin, @poll], notice: t("flash.actions.update.poll")
    else
      render :edit
    end
  end

  def add_question
    question = ::Poll::Question.find(params[:question_id])

    if question.present?
      @poll.questions << question
      notice = t("admin.polls.flash.question_added")
    else
      notice = t("admin.polls.flash.error_on_question_added")
    end
    redirect_to admin_poll_path(@poll, anchor: 'tab-questions'), notice: notice
  end

  def remove_question
    question = ::Poll::Question.find(params[:question_id])

    if @poll.questions.include? question
      @poll.questions.delete(question)
      notice = t("admin.polls.flash.question_removed")
    else
      notice = t("admin.polls.flash.error_on_question_removed")
    end
    redirect_to admin_poll_path(@poll, anchor: 'tab-questions'), notice: notice
  end

  def search_booths
    @booths = ::Poll::Booth.search(@search)
    respond_to do |format|
      format.js
    end
  end

  def search_questions
    @questions = ::Poll::Question.where("poll_id IS ? OR poll_id != ?", nil, @poll.id).search({search: @search}).order(title: :asc)
    respond_to do |format|
      format.js
    end
  end

  def search_officers
    @officers = User.joins(:poll_officer).search(@search).order(username: :asc)

    respond_to do |format|
      format.js
    end
  end

  private

    def poll_params
      params.require(:poll).permit(:name, :starts_at, :ends_at)
    end

    def search_params
      params.permit(:poll_id, :search)
    end

    def load_search
      @search = search_params[:search]
    end

end