class Gem::Commands::PushCommand < Gem::AbstractCommand

  def description
    'Push a gem up to Gemcutter'
  end

  def arguments
    "GEM       built gem to push up"
  end

  def usage
    "#{program_name} GEM"
  end

  def initialize
    super 'push', description
    add_proxy_option
  end

  def execute
    setup
    send_gem
  end

  def send_gem
    say "Pushing gem to Gemcutter..."

    name = begin
      get_one_gem_name
    rescue Gem::CommandLineError
      get_latest_packaged_gem || raise Gem::CommandLineError, "No gem name was specified, and there are no packaged gems in ./pkg"
    end
    response = make_request(:post, "gems") do |request|
      request.body = File.open(name, 'rb'){|io| io.read }
      request.add_field("Content-Length", request.body.size)
      request.add_field("Content-Type", "application/octet-stream")
      request.add_field("Authorization", api_key)
    end

    say response.body
  end

end
