class PostsController < ApplicationController

    layout 'application'

    before_action :set_post, only: [:new, :edit, :update, :show, :destroy]


    def index
        @posts = Post.all.order(:created_at)
    end 

    def new; end

    def show; end

    def edit; end

    def update 
        
        return unless @post.persisted?
        
        if @post.update(create_update_post_params)
            redirect_to posts_path  
        else 
            flash.now[:error] = "brev, de bi wrong"
            render :new, status: :unprocessable_entity
        end
    end 

    def create 

        @post = Post.new(create_update_post_params)

        if @post.save 
            redirect_to posts_path
        else
            render :new, status: :unprocessable_entity
        end
    end 

    def destroy 
        if @post.destroy 
            redirect_to posts_path 
        else 
            redirect_to :show
        end 
    end

    def set_post 
        @post = params[:id].present? ? Post.find(params[:id]) : Post.new
    end


    def create_update_post_params 
        params.require(:post).permit(:title, :body)
    end

end
