require "ostruct"

class ImportsController < ApplicationController
  before_action :set_import, except: %i[ index new create ]

  def index
    @imports = Current.family.imports
    render layout: "with_sidebar"
  end

  def new
    @import = Import.new
  end

  def edit
  end

  def update
    @import.update!(account_id: params[:import][:account_id])

    redirect_to load_import_path(@import), notice: "Import updated"
  end

  def create
    account = Current.family.accounts.find(params[:import][:account_id])
    @import = Import.create!(account: account)

    redirect_to load_import_path(@import), notice: "Import was successfully created."
  end

  def destroy
    @import.destroy!
    redirect_to imports_url, notice: "Import was successfully destroyed.", status: :see_other
  end

  def load
  end

  def update_csv
    if @import.update(import_params)
      redirect_to configure_import_path(@import), notice: "Import uploaded"
    else
      flash.now[:error] = @import.errors.full_messages.to_sentence
      render :load, status: :unprocessable_entity
    end
  end

  def configure
  end

  def update_mappings
    if @import.update(import_params)
      redirect_to clean_import_path(@import), notice: "Mappings saved"
    else
      flash.now[:error] = @import.errors.full_messages.first
      render :show, status: :unprocessable_entity
    end
  end

  def clean
  end

  def update_cell_temporary
    @import.update_cell! \
      row_idx: import_params_temporary[:row_idx],
      col_idx: import_params_temporary[:col_idx],
      value: import_params_temporary[:value]

    render :clean
  end

  def confirm
    unless @import.row_errors.flatten.empty?
      flash[:error] = "There are invalid values"
      redirect_to clean_import_path(@import)
    end
  end

  def publish
    @import.confirm!
    redirect_to transactions_path, notice: "Import complete!"
  end

  private

    def set_import
      @import = Current.family.imports.find(params[:id])
    end

    def import_params
      params.require(:import).permit(:raw_csv, column_mappings: [ :date, :merchant, :category, :amount ])
    end

    def import_params_temporary
      permitted_params = params.require(:csv_update).permit(:row_idx, :col_idx, :value)
      permitted_params[:row_idx] = permitted_params[:row_idx].to_i
      permitted_params[:col_idx] = permitted_params[:col_idx].to_i
      permitted_params
    end
end
