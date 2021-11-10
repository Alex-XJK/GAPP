class VisualizersController < ApplicationController
  before_action :set_visualizer, only: [:show, :edit, :update, :destroy]

  # GET /visualizers
  # GET /visualizers.json
  def index
    @visualizers = Visualizer.all
  end

  # GET /visualizers/1
  # GET /visualizers/1.json
  def show
  end

  # GET /visualizers/new
  def new
    @visualizer = Visualizer.new
  end

  # GET /visualizers/1/edit
  def edit
  end

  # POST /visualizers
  # POST /visualizers.json
  def create
    @visualizer = Visualizer.new(visualizer_params)

    respond_to do |format|
      if @visualizer.save
        format.html { redirect_to @visualizer, notice: 'Visualizer was successfully created.' }
        format.json { render :show, status: :created, location: @visualizer }
      else
        format.html { render :new }
        format.json { render json: @visualizer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /visualizers/1
  # PATCH/PUT /visualizers/1.json
  def update
    respond_to do |format|
      if @visualizer.update(visualizer_params)
        format.html { redirect_to @visualizer, notice: 'Visualizer was successfully updated.' }
        format.json { render :show, status: :ok, location: @visualizer }
      else
        format.html { render :edit }
        format.json { render json: @visualizer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visualizers/1
  # DELETE /visualizers/1.json
  def destroy
    @visualizer.destroy
    respond_to do |format|
      format.html { redirect_to visualizers_url, notice: 'Visualizer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_visualizer
      @visualizer = Visualizer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def visualizer_params
      params.require(:visualizer).permit(:name, :js_module_name, :load_data)
    end
end
