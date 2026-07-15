class HealthMetricReadingsController < ApplicationController
  # No index action — skip inherited index-only/index-except Pundit callbacks
  # and re-declare verify_authorized unconditionally for this controller.
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized
  after_action :verify_authorized

  before_action :set_health_metric, only: %i[new create]
  before_action :set_reading, only: %i[edit update destroy]

  def new
    @reading = @health_metric.readings.build(recorded_at: Time.current)
    authorize @reading
  end

  def edit
    authorize @reading
  end

  def create
    @reading = @health_metric.readings.build(reading_params)
    authorize @reading
    if @reading.save
      redirect_to health_metric_path(@health_metric)
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @reading
    if @reading.update(reading_params)
      redirect_to health_metric_path(@reading.health_metric)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @reading
    metric = @reading.health_metric
    @reading.destroy
    redirect_to health_metric_path(metric)
  end

  private

  def set_health_metric
    @health_metric = HealthMetric.find(params[:health_metric_id])
    @patient = @health_metric.patient
    Current.patient = @patient
  end

  def set_reading
    @reading = HealthMetricReading.find(params[:id])
    @health_metric = @reading.health_metric
    @patient = @health_metric.patient
    Current.patient = @patient
  end

  def reading_params
    params.expect(health_metric_reading: %i[recorded_at value notes])
  end
end
