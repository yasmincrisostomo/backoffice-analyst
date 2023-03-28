class ClientesController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_action :set_results, only: [:index]

  def index
    @query = params[:cnpj]
    render :index
  end

  private

  def set_results
    @results = Cliente.select("clientes.cnpj, statuses_pending.data_horario_do_status as date_of_purchase,
                            (strftime('%s', statuses_approved.data_horario_do_status) - strftime('%s', statuses_pending.data_horario_do_status))/3600 as approval_time_hours,
                            ((strftime('%s', statuses_approved.data_horario_do_status) - strftime('%s', statuses_pending.data_horario_do_status)) % 3600)/60 as approval_time_minutes")
                      .joins("JOIN statuses statuses_pending ON clientes.user_id = statuses_pending.user_id AND statuses_pending.status = 'pending_kyc' 
                              JOIN (SELECT user_id, MAX(data_horario_do_status) as max_data_horario_do_status FROM statuses WHERE status = 'approved' GROUP BY user_id) last_approved
                              ON clientes.user_id = last_approved.user_id
                              JOIN statuses statuses_approved ON clientes.user_id = statuses_approved.user_id AND statuses_approved.status = 'approved' AND statuses_approved.data_horario_do_status = last_approved.max_data_horario_do_status")
                      .where(where_clause)
                      .order('statuses_pending.data_horario_do_status DESC')
                      .page(params[:page])

    set_avg_time
    set_max_time
    set_min_time
  end

  def where_clause
    where = '1=1'
    where += " AND clientes.cnpj LIKE '%#{@query}%'" if @query
    where += " AND statuses_pending.id IN (
                    SELECT MAX(id)
                    FROM statuses
                    WHERE status = 'pending_kyc'
                    GROUP BY user_id
                )"
    where += " AND statuses_approved.id IN (
                    SELECT MAX(id)
                    FROM statuses
                    WHERE status = 'approved'
                    GROUP BY user_id
                )"
    where
  end

  def set_avg_time
    avg_seconds = Cliente.find_by_sql("
      SELECT AVG(julianday(s2.data_horario_do_status) - julianday(s.data_horario_do_status)) * 24 * 60 * 60 AS avg_seconds_to_approve
      FROM clientes AS c
      INNER JOIN statuses AS s ON c.user_id = s.user_id AND s.status = 'pending_kyc'
      INNER JOIN statuses AS s2 ON c.user_id = s2.user_id AND s2.status = 'approved'
    ").first.avg_seconds_to_approve.to_i

    hours = (avg_seconds / (60 * 60)) % 24
    minutes = (avg_seconds / 60) % 60
    seconds = avg_seconds % 60

    hour_str = pluralize(hours, 'hour')
    minute_str = pluralize(minutes, 'minute')
    second_str = pluralize(seconds, 'second')

    @avg_time = format("%s, %s and %s", hour_str, minute_str, second_str)
  end

  def set_max_time
    max_seconds = Cliente.find_by_sql("
      SELECT MAX(julianday(s2.data_horario_do_status) - julianday(s.data_horario_do_status)) * 24 * 60 * 60 AS max_seconds_to_approve
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
      SELECT MIN(julianday(s2.data_horario_do_status) - julianday(s.data_horario_do_status)) * 24 * 60 * 60 AS min_seconds_to_approve
      FROM clientes AS c
      INNER JOIN statuses AS s ON c.user_id = s.user_id AND s.status = 'pending_kyc'
      INNER JOIN statuses AS s2 ON c.user_id = s2.user_id AND s2.status = 'approved'
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