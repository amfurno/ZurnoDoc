class HealthMetricsController < ApplicationController
  before_action :set_patient, only: %i[index new create]
  before_action :set_health_metric, only: %i[show edit update destroy]

  def index
    # Patient already scoped through set_patient → Current.user.patients
    skip_policy_scope
    @health_metrics = @patient.health_metrics.includes(:readings).order(created_at: :desc)
  end

  def show
    authorize @health_metric
    sorted_readings = @health_metric.readings.order(sort_column => sort_direction)
    @pagy, @readings = pagy(:offset, sorted_readings, limit: 10, max_limit: 50)
    @chart_data = @health_metric.readings.order(recorded_at: :asc).pluck(:recorded_at, :value)
  end

  def new
    @health_metric = @patient.health_metrics.build
    authorize @health_metric
  end

  def edit
    authorize @health_metric
  end

  def create
    @health_metric = @patient.health_metrics.build(health_metric_params)
    authorize @health_metric
    if @health_metric.save
      redirect_to health_metric_path(@health_metric)
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @health_metric
    if @health_metric.update(health_metric_params)
      redirect_to health_metric_path(@health_metric)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @health_metric
    @health_metric.destroy
    redirect_to patient_health_metrics_path(@patient)
  end

  private

  def set_patient
    @patient = Current.user.patients.find(params[:patient_id])
    Current.patient = @patient
  end

  def set_health_metric
    @health_metric = HealthMetric.find(params[:id])
    @patient = @health_metric.patient
    Current.patient = @patient
  end

  def health_metric_params
    params.expect(health_metric: %i[name unit notes])
  end

  def sort_column
    %w[recorded_at value].include?(params[:sort]) ? params[:sort] : 'recorded_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:dir]) ? params[:dir] : 'desc'
  end
end
