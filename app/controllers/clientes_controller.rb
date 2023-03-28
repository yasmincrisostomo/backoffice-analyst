class ClientesController < ApplicationController
  def index
    @query = params[:cnpj]

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

    @avg_time = Cliente.joins(:statuses)
                       .where("statuses.status = 'pending_kyc' OR statuses.status = 'approved'")
                       .group(:user_id)
                       .average("(strftime('%s', statuses.data_horario_do_status))")

    @max_time = Cliente.joins(:statuses)
                       .where("statuses.status = 'pending_kyc' OR statuses.status = 'approved'")
                       .group(:user_id)
                       .maximum("(strftime('%s', statuses.data_horario_do_status))")

    @min_time = Cliente.joins(:statuses)
                       .where("statuses.status = 'pending_kyc' OR statuses.status = 'approved'")
                       .group(:user_id)
                       .minimum("(strftime('%s', statuses.data_horario_do_status))")

    render :index
  end

  private

  def where_clause
    where = "1=1"
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
end
