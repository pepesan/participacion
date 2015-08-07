class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_debate, :set_parent, only: :create
  respond_to :html, :js

  def create
    @comment = Comment.build(@debate, current_user, params[:comment][:body])
    @comment.save!
    @comment.move_to_child_of(@parent) if reply?

    Mailer.comment(@comment).deliver_now if email_on_debate_comment?
    Mailer.reply(@comment).deliver_now if email_on_comment_reply?

    respond_with @comment
  end

  def vote
    @comment = Comment.find(params[:id])
    @comment.vote_by(voter: current_user, vote: params[:value])
    respond_with @comment
  end

  private
    def comment_params
      params.require(:comments).permit(:commentable_type, :commentable_id, :body)
    end

    def set_debate
      @debate = Debate.find(params[:debate_id])
    end

    def set_parent
      @parent = Comment.find_parent(params[:comment])
    end

    def reply?
      @parent.class == Comment
    end

    def email_on_debate_comment?
      @comment.debate.author.email_on_debate_comment?
    end

    def email_on_comment_reply?
      reply? && @parent.author.email_on_comment_reply?
    end
end