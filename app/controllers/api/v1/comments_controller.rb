module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authenticate_user
      before_action :set_post, only: [:index, :create]
      before_action :set_comment, except: [:index, :create]

      def index
        @comments = @post.comments
        render json: @comments
      end

      def show
        render json: @comment
      end

      def create
        
        
        @comments = @post.comments.where(user_id: current_user.id)
        if @comments
          @comments.content = params[:content]
          @comment.save
          return
        end

        @comment = @post.comments.build(comment_params)
        @comment.user_id = @current_user_id
        
        if @comment.save
          render json: @comment, status: :created
        else
          render json: @comment.errors, status: :unprocessable_entity
        end
      end

      def update
        if @comment.update(comment_params)
          render json: @comment
        else
          render json: @comment.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @comment.destroy
        head :no_content
      end

      def like
        @comment.likes.where(user: @current_user).first_or_create
        render json: @comment, status: :ok
      end

      def unlike
        @comment.likes.where(user_id: @current_user.id).destroy_all
        render json: @comment, status: :ok
      end

      private

      def set_comment
        @comment = Comment.find(params[:id])      
      end

      def set_post
        @post = Post.find(params[:post_id])
      end

      def comment_params
        params.permit(:content)
      end
    end
  end
end
