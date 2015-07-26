class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_question, only: [:create]
  before_action :load_answer, except: [:create]
  before_action :access_answer, only: [:update, :destroy]
  before_action :access_best, only: [:set_best, :cancel_best]

  respond_to :js

  include Voted

  def create
    respond_with(@answer = @question.answers.create(answer_params.merge(user: current_user)))
  end

  def update
    @answer.update(answer_params)
    respond_with(@answer)
  end

  def destroy
    respond_with(@answer.destroy)
  end

  def set_best
    respond_with(@answer.set_best)
  end

  def cancel_best
    respond_with(@answer.cancel_best)
  end

  private

  def load_question
    @question = Question.find(params[:question_id])
  end

  def load_answer
    @answer = Answer.find(params[:id])
    @question = @answer.question
  end

  def access_answer
    redirect_to @answer.question, notice: 'Access denied' if  @answer.user_id != current_user.id
  end

  def access_best
    redirect_to @answer.question, notice: 'Access denied' if  @answer.question.user_id != current_user.id
  end

  def answer_params
    params.require(:answer).permit(:text, attachments_attributes: [:file, :done, :_destroy])
  end
end
