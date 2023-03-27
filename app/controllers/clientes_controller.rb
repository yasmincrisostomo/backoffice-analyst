class ClientesController < ApplicationController
  def index
    @results = ActiveRecord::Base.connection.exec_query("
      SELECT c.cnpj,
             s_approved.data_horario_do_status AS date_of_purchase,
             strftime('%s', s_approved.data_horario_do_status) - strftime('%s', s_pending.data_horario_do_status) AS approval_time_seconds,
             (strftime('%s', s_approved.data_horario_do_status) - strftime('%s', s_pending.data_horario_do_status))/3600 AS approval_time_hours,
             ((strftime('%s', s_approved.data_horario_do_status) - strftime('%s', s_pending.data_horario_do_status)) % 3600)/60 AS approval_time_minutes
      FROM clientes c
      JOIN statuses s_pending ON c.user_id = s_pending.user_id AND s_pending.status = 'pending_kyc'
      JOIN statuses s_approved ON c.user_id = s_approved.user_id AND s_approved.status = 'approved'
    ")

    @avg_time = ActiveRecord::Base.connection.exec_query("
      SELECT AVG(strftime('%s', s_approved.data_horario_do_status) - strftime('%s', s_pending.data_horario_do_status))/3600 AS avg_approval_time_hours
      FROM clientes c
      JOIN statuses s_pending ON c.user_id = s_pending.user_id AND s_pending.status = 'pending_kyc'
      JOIN statuses s_approved ON c.user_id = s_approved.user_id AND s_approved.status = 'approved'
    ").first['avg_approval_time_hours']

    @max_time = ActiveRecord::Base.connection.exec_query("
      SELECT MAX(strftime('%s', s_approved.data_horario_do_status) - strftime('%s', s_pending.data_horario_do_status))/3600 AS max_approval_time_hours
      FROM clientes c
      JOIN statuses s_pending ON c.user_id = s_pending.user_id AND s_pending.status = 'pending_kyc'
      JOIN statuses s_approved ON c.user_id = s_approved.user_id AND s_approved.status = 'approved'
    ").first['max_approval_time_hours']

    @min_time = ActiveRecord::Base.connection.exec_query("
      SELECT MIN(strftime('%s', s_approved.data_horario_do_status) - strftime('%s', s_pending.data_horario_do_status))/3600 AS min_approval_time_hours
      FROM clientes c
      JOIN statuses s_pending ON c.user_id = s_pending.user_id AND s_pending.status = 'pending_kyc'
      JOIN statuses s_approved ON c.user_id = s_approved.user_id AND s_approved.status = 'approved'
    ").first['min_approval_time_hours']

    render :index
  end
end
