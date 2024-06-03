require "csv"

class LoggerMiddleware
  def initialize(app)
    @app = app
    @csv_path = Rails.root.join("log", "my_cool_log.csv")
  end

  def call(env)
    started_on = Time.now
    request = ActionDispatch::Request.new(env)

    response = @app.call(env)
    status = response[0]

    log(env, request, started_on, status)

    response
  end

  private

  def create_csv
    CSV.open(@csv_path, 'w') do |csv|
      csv << %w[method path origin_ip params date execution_time status]
    end
  end

  def append_to_csv(information)
    create_csv unless File.file?(@csv_path)

    CSV.open(@csv_path, 'a') do |csv|
      csv << information
    end
  rescue StandardError => e
    puts "Write error to #{@csv_path}: #{e}"
  end

  def log(env, request, started_on, status)
    information = {
      method: env["REQUEST_METHOD"],
      path: env["REQUEST_PATH"],
      origin_ip: request.ip,
      params: request.params.to_s,
      date: started_on,
      execution_time: Time.now - started_on,
      status: status
    }

    normalized_information = information.values

    append_to_csv(normalized_information)
  end
end
