class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @friends = current_user.friends

    @pending = current_user.pending_friends

    @sent_requests = current_user.friend_requests
  end

  def create
    @request = current_user.friendships.build(friend_id: params[:friend_id])

    flash[:notice] = if @request.save
                       'Request sent'
                     else
                       'There has been a problem sending request'
                     end
    redirect_to users_path
  end

  def update
    friend = User.find(params[:id])
    @friendship = current_user.confirm_friend(friend)

    if @friendship
      Friendship.create!(user_id: current_user.id, friend_id: friend.id, confirmed: true)
      flash[:notice] = 'Friendship confirmed'
    else
      flash[:notice] = 'Ooops!, Something went wrong.'
    end
    redirect_back fallback_location: :back
  end

  def destroy
    @friend = User.find(params[:id])

    friendship = Friendship.find_by(user_id: current_user.id, friend_id: @friend.id)
    other_friendship = Friendship.find_by(user_id: @friend.id, friend_id: current_user.id)

    if friendship
      friendship.destroy
      other_friendship.destroy
      flash[:notice] = 'Success!'
    else
      flash[:notice] = 'Error! Cannot Unfriend'
    end
    redirect_to friendships_path
  end
end
