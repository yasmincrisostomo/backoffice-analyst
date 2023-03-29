class ClientesController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_action :set_results, only: [:index]

  def index
    @avg_time = set_avg_time
    @max_time = set_max_time
    @min_time = set_min_time

    render :index
  end

  private

  def set_results
    @query = params[:cnpj]
    @results = Cliente.select("clientes.cnpj, statuses_pending.data_horario_do_status as date_of_purchase,
                            (extract(epoch from statuses_approved.data_horario_do_status - statuses_pending.data_horario_do_status))/3600 as approval_time_hours,
                            ((extract(epoch from statuses_approved.data_horario_do_status - statuses_pending.data_horario_do_status)) % 3600)/60 as approval_time_minutes")
                      .joins("JOIN statuses statuses_pending ON clientes.user_id = statuses_pending.user_id AND statuses_pending.status = 'pending_kyc' 
                              JOIN (SELECT user_id, MAX(data_horario_do_status) as max_data_horario_do_status FROM statuses WHERE status = 'approved' GROUP BY user_id) last_approved
                              ON clientes.user_id = last_approved.user_id
                              JOIN statuses statuses_approved ON clientes.user_id = statuses_approved.user_id AND statuses_approved.status = 'approved' AND statuses_approved.data_horario_do_status = last_approved.max_data_horario_do_status")
                      .where("clientes.cnpj LIKE '%#{@query}%'")
                      .order('statuses_pending.data_horario_do_status DESC')
                      .page(params[:page]).per(10)
  end

  def set_avg_time
    avg_seconds = Cliente.find_by_sql("
      SELECT AVG(extract(epoch from s2.data_horario_do_status - s.data_horario_do_status)) AS avg_seconds_to_approve
      FROM clientes AS c
      INNER JOIN statuses AS s ON c.user_id = s.user_id AND s.status = 'pending_kyc'
      INNER JOIN statuses AS s2 ON c.user_id = s2.user_id AND s2.status = 'approved'
    ").first.avg_seconds_to_approve.to_i

    hours, minutes, seconds = calculate_time_units(avg_seconds)

    hour_str = pluralize(hours, 'hour')
    minute_str = pluralize(minutes, 'minute')
    second_str = pluralize(seconds, 'second')

    @avg_time = format("%s, %s and %s", hour_str, minute_str, second_str)
  end

  def set_max_time
    max_seconds = Cliente.find_by_sql("
      SELECT MAX(extract(epoch from s2.data_horario_do_status - s.data_horario_do_status)) AS max_seconds_to_approve
      FROM clientes AS c
      INNER JOIN statuses AS s ON c.user_id = s.user_id AND s.status = 'pending_kyc'
      INNER JOIN statuses AS s2 ON c.user_id = s2.user_id AND s2.status = 'approved'
    ").first.max_seconds_to_approve.to_i

    days, hours, minutes, seconds = calculate_time_units(max_seconds)

    day_str = pluralize(days, 'day')
    hour_str = pluralize(hours, 'hour')
    minute_str = pluralize(minutes, 'minute')
    second_str = pluralize(seconds, 'second')

    @max_time = format("%s, %s, %s and %s", day_str, hour_str, minute_str, second_str)
  end

  def set_min_time
    min_seconds = Cliente.find_by_sql("
      SELECT MIN(EXTRACT(epoch FROM (statuses_approved.data_horario_do_status - statuses_pending.data_horario_do_status))) AS min_seconds_to_approve
      FROM clientes
      INNER JOIN statuses statuses_pending ON clientes.user_id = statuses_pending.user_id AND statuses_pending.status = 'pending_kyc'
      INNER JOIN (
        SELECT user_id, MAX(data_horario_do_status) as max_data_horario_do_status 
        FROM statuses 
        WHERE status = 'approved' 
        GROUP BY user_id
      ) last_approved ON clientes.user_id = last_approved.user_id
      INNER JOIN statuses statuses_approved ON clientes.user_id = statuses_approved.user_id AND statuses_approved.status = 'approved' AND statuses_approved.data_horario_do_status = last_approved.max_data_horario_do_status
      WHERE clientes.cnpj LIKE '%#{@query}%'
    ").first.min_seconds_to_approve.to_i
  
    days, hours, minutes, seconds = calculate_time_units(min_seconds)
  
    day_str = pluralize(days, 'day')
    hour_str = pluralize(hours, 'hour')
    minute_str = pluralize(minutes, 'minute')
    second_str = pluralize(seconds, 'second')
  
    @min_time = format("%s, %s, %s and %s", day_str, hour_str, minute_str, second_str)
  end

  def calculate_time_units(seconds)
    days = seconds / (24 * 60 * 60)
    hours = (seconds / (60 * 60)) % 24
    minutes = (seconds / 60) % 60
    seconds = seconds % 60
  
    return days, hours, minutes, seconds
  end
end