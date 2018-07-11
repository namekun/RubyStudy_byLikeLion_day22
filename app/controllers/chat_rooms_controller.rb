class ChatRoomsController < ApplicationController
  before_action :set_chat_room, only: [:show, :edit, :update, :destroy, :user_admit_room, :chat, :user_exit_room]
  before_action :authenticate_user!, except: [:index]

  # GET /chat_rooms
  # GET /chat_rooms.json
  def index
    @chat_rooms = ChatRoom.all
  end

  # GET /chat_rooms/1
  # GET /chat_rooms/1.json
  def show
  end

  # GET /chat_rooms/new
  def new
    @chat_room = ChatRoom.new
  end

  # GET /chat_rooms/1/edit
  def edit
  end

  # POST /chat_rooms
  # POST /chat_rooms.json
  def create
    @chat_room = ChatRoom.new(chat_room_params)
    @chat_room.master_id = current_user.email # 방이 만들어 질때, 현재 유저의 이메일을 master_id로
    respond_to do |format|
      if @chat_room.save
        @chat_room.user_admit_room(current_user)
        format.html { redirect_to @chat_room, notice: 'Chat room was successfully created.' }
        format.json { render :show, status: :created, location: @chat_room }
      else
        format.html { render :new }
        format.json { render json: @chat_room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chat_rooms/1
  # PATCH/PUT /chat_rooms/1.json
  def update
    respond_to do |format|
    # 현재 유저가 master id를 갖고있는 유저인가?  
      if @chat_room.update(chat_room_params)
        format.html { redirect_to @chat_room, notice: 'Chat room was successfully updated.' }
        format.json { render :show, status: :ok, location: @chat_room }
      else
        format.html { render :edit }
        format.json { render json: @chat_room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chat_rooms/1
  # DELETE /chat_rooms/1.json
  def destroy
    @chat_room.destroy
    respond_to do |format|
      format.html { redirect_to chat_rooms_url, notice: 'Chat room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def user_admit_room
      # 현재 유저가 있는 방에서 join버튼을 눌렀을 때 동작하는 액션
      # 이미 조인 되어있는 유저라면, `이미 참가한 방입니다.`라는 alert를 띄워주고, 
      # 아닐경우에는 join시킵니다.
      
      if current_user.joined_room?(@chat_room)
        # @chat_room.users.include?(current_user) -> 이방에 그 유저가 포함되어있나?
        # 유저가 참가하고있는 방의 목록중에, 이방이 포함되어있는가?
        # current_user.chat_room.where(params[:id])[0].nil?
        # where은 리턴값이 무조건 어소시에이션 객체를 하나 갖고있다, 즉 배열값을 하나 갖는다고 할 수 있다.

        # where대신에 find를 쓰면, 결과를 못찾을 때 error를 내뱉는다.
        # 방에 참가하고 있는 유저들 중에, 이 유저가 포함되어있는가?
        # 의 두가지 방법
        render js: "alert('이미 참여한 방입니다.');"
      else
        @chat_room.user_admit_room(current_user)
      end
  end
  
  def user_exit_room
    @chat_room.user_exit_room(current_user)
    if current_user.email.eql? @chat_room.master_id
        @chat_room.master_id.update(@chat_room.users.sample.email)
    end
  end
  
  
  def chat
    @chat_room.chats.create(user_id: current_user.id, message: params[:message])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat_room
      @chat_room = ChatRoom.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chat_room_params
      params.fetch(:chat_room, {}).permit(:title, :max_count)
    end
end
