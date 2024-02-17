require "roda"
require 'sequel'
require 'json'
require 'date'


sleep(ENV['STARTUP_DELAY'].to_i) if ENV['STARTUP_DELAY']

DB = Sequel.connect("postgres://postgres:password@localhost", max_connections: ENV.fetch("CONNECTION_POOL") { 5 }, :timeout=>3)
DB.extension(:pg_streaming)
DB.stream_all_queries = true

class Transaction < Sequel::Model
end

class App < Roda
  plugin :direct_call
  # plugin :error_handler do |e|
  #   response.status = 422
  #   nil
  # end

  route do |r|
    r.on "clientes" do
      r.on Integer do |id|
        @id = id
        @customer = Transaction.where(customer_id: @id).order(:id).limit(1).select(:customer_balance_cents, :customer_limit_cents).last rescue nil


        r.get "extrato"  do
          r.is @customer == nil do
            response.status = 404
            nil
          end

          response.status = 200
          build_extrato.to_json
        end

        r.post "transacoes" do
          r.is @customer == nil do
            response.status = 404
            nil
          end

          @body = request.body.read
          @data = JSON.parse @body
          build_new_customer_balance_cents
          r.is invalid_transaction?(@new_customer_balance_cents, @data['descricao'], @data['valor'], @data['tipo']) do
            response.status = 422
            nil
          end

          response.status = 200
          build_transaction_result.to_json
        end
      end
    end
  end


  def build_extrato
    data_extrato = Time.now.iso8601(6)
    last_transactions = Transaction.exclude(kind: 0).where(customer_id: 1).reverse_order(:id).limit(10).select(:amount,:kind,:description,:created_at)
    last_transactions = last_transactions.map do | transaction |
      {
        valor: transaction[:amount],
        tipo: convert_kind(transaction[:kind]),
        descricao: transaction[:description],
        realizada_em: transaction[:created_at].iso8601(6),
      }
    end

    result = {
      "saldo": {
        "total": @customer.customer_balance_cents,
        "data_extrato": data_extrato,
        "limite": @customer.customer_limit_cents
      },
      "ultimas_transacoes": last_transactions
    }
  end

  def build_new_customer_balance_cents
    if @data['tipo'] == "c"
      @transaction_kind = 1
      @new_customer_balance_cents = @customer.customer_balance_cents + @data['valor']
    else
      @transaction_kind = 2
      @new_customer_balance_cents = @customer.customer_balance_cents - @data['valor']
    end
  end

  def invalid_transaction?(new_customer_balance_cents, descricao, valor, kind)
    return true unless valor.is_a?(Integer)
    return true if descricao.nil? || descricao.empty? || descricao.length > 10
    return true if kind != "c" && kind != "d"
    if @data['tipo'] == 'd'
      if new_customer_balance_cents < (-@customer.customer_limit_cents)
        return true
      end
    end

    false
  end

  def convert_kind(kind)
    if kind == 1
      "c"
    else
      "d"
    end
  end

  def build_transaction_result
    @new_customer = Transaction.insert(
      customer_id: @id,
      customer_limit_cents: @customer.customer_limit_cents,
      customer_balance_cents: @new_customer_balance_cents,
      amount: @data['valor'],
      kind: @transaction_kind,
      description: @data['descricao'],
    )
    {
      "limite": @customer.customer_limit_cents,
      "saldo": @new_customer_balance_cents
    }
  end
end

run App.freeze.app
