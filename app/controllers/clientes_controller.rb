class ClientesController < ApplicationController
  def index
    @query = params[:cnpj]

    @results = Cliente.select("clientes.cnpj, statuses_pending.data_horario_do_status as date_of_purchase,
                              (strftime('%s', statuses_approved.data_horario_do_status) - strftime('%s', statuses_pending.data_horario_do_status))/3600 as approval_time_hours,
                              ((strftime('%s', statuses_approved.data_horario_do_status) - strftime('%s', statuses_pending.data_horario_do_status)) % 3600)/60 as approval_time_minutes")
                      .joins("JOIN statuses statuses_pending ON clientes.user_id = statuses_pending.user_id AND statuses_pending.status = 'pending_kyc' 
                                JOIN statuses statuses_approved ON clientes.user_id = statuses_approved.user_id AND statuses_approved.status = 'approved'")
                      .where(where_clause)
                      .order('statuses_pending.data_horario_do_status DESC')
                      .page(params[:page])

    @avg_time = Cliente.joins(:statuses)
                       .where(where_clause)
                       .where("statuses.status = 'pending_kyc' OR statuses.status = 'approved'")
                       .group(:user_id)
                       .average("(strftime('%s', statuses.data_horario_do_status))")

    @max_time = Cliente.joins(:statuses)
                       .where(where_clause)
                       .where("statuses.status = 'pending_kyc' OR statuses.status = 'approved'")
                       .group(:user_id)
                       .maximum("(strftime('%s', statuses.data_horario_do_status))")

    @min_time = Cliente.joins(:statuses)
                       .where(where_clause)
                       .where("statuses.status = 'pending_kyc' OR statuses.status = 'approved'")
                       .group(:user_id)
                       .minimum("(strftime('%s', statuses.data_horario_do_status))")

    render :index
  end

  private

  def where_clause
    return "clientes.cnpj LIKE '%#{@query}%'" if @query

    '1=1'
  end
end
