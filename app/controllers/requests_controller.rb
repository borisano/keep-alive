class RequestsController < ApplicationController
  before_action :set_request, only: %i[show edit update destroy contacts]
  before_action :require_admin, only: %i[edit update]

  # GET /requests or /requests.json
  def index
    @type = params[:type]
    @q = Request.ransack(params[:q])
    @pagy, @requests = pagy(@q.result.where(type: @type).order(created_at: :desc))
  end

  # GET /requests/1 or /requests/1.json
  def show; end

  # GET /requests/new
  def new
    @type = params[:type]
    @request = Request.new
  end

  # POST /requests/1/contacts
  def contacts
    sleep 3
  end

  # GET /requests/1/edit
  def edit; end

  # POST /requests or /requests.json
  def create
    @request = Request.new(create_request_params)
    @type = @request.type

    respond_to do |format|
      if @request.save
        format.html do
          redirect_to request_url(@request), notice: t('requests.created')
        end
        format.json { render :show, status: :created, location: @request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requests/1 or /requests/1.json
  def update
    respond_to do |format|
      if @request.update(update_request_params)
        format.html do
          redirect_to request_url(@request), notice: 'Request was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /requests/1 or /requests/1.json
  def destroy
    @request.destroy

    respond_to do |format|
      format.html { redirect_to requests_url, notice: 'Request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.find(params[:id])
  end

  def update_request_params
    params.require(:request).permit!
  end

  def create_request_params
    params
      .require(:request)
      .permit(:type, :title, :region, :city, :address, :contact_name, :phone, :viber,
              :telegram, :description, :skype)
      .merge(reporter_ip: request.remote_ip, user: current_user)
  end

  def require_admin
    head(:forbidden) unless current_user&.admin?
  end
end
