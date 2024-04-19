class ValuationsController < ApplicationController
  def create
    @account = Current.family.accounts.find(params[:account_id])

    # TODO: placeholder logic until we have a better abstraction for trends
    @valuation = @account.valuations.new(valuation_params.merge(currency: Current.family.currency))
    if @valuation.save
      @valuation.account.sync_later(@valuation.date - 1.day)

      respond_to do |format|
        format.html { redirect_to account_path(@account), notice: "Valuation created" }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = "Valuation already exists for this date"
    render :new, status: :unprocessable_entity
  end

  def show
    @valuation = Current.family.accounts.find(params[:account_id]).valuations.find(params[:id])
  end

  def edit
    @valuation = Valuation.find(params[:id])
  end

  def update
    @valuation = Valuation.find(params[:id])
    sync_start_date = [ @valuation.date, Date.parse(valuation_params[:date]) ].compact.min
    if @valuation.update(valuation_params)
      @valuation.account.sync_later(sync_start_date - 1.day)

      redirect_to account_path(@valuation.account), notice: "Valuation updated"
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    flash.now[:error] = "Valuation already exists for this date"
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @valuation = Valuation.find(params[:id])
    sync_start_date = Valuation.where("date < ?", @valuation.date).order(date: :desc).first&.date
    @account = @valuation.account
    @valuation.destroy!
    @account.sync_later(sync_start_date)

    respond_to do |format|
      format.html { redirect_to account_path(@account), notice: "Valuation deleted" }
      format.turbo_stream
    end
  end

  def new
    @account = Current.family.accounts.find(params[:account_id])
    @valuation = @account.valuations.new
  end

  private
    def valuation_params
      params.require(:valuation).permit(:date, :value)
    end
end
