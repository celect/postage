namespace :postage do
  
  desc 'Do the initial postage installation.'
  task :setup => :environment do
    
    if (key = ENV['API_KEY']).blank?
      print 'Please enter the API key: '
      key = STDIN.gets.gsub("\n", '')
    end
    
    filename = "#{Rails.root}/config/initializers/postageapp.rb"
    
    output = "
Postage.configure do |config|
  config.api_key = '#{key}'
end

"
    File.open(filename, 'w'){|file| file.write(output)}
    puts "Created intializer: #{filename}"
    puts "With the following content: \n#{output}"
  end
  
  desc 'Check current plugin configuration'
  task :current_config => :environment do
    config_accessors = [
      [:api_key,            '               API Key: '],
      [:url,                'PostageApp service URL: '],
      [:recipient_override, '    Recipient Override: '],
      [:environments,       ' Active Environment(s): ']
    ]
    
    config_accessors.each do |k, v|
      puts "#{v} #{Postage.send(k).inspect}"
    end
  end
  
  desc 'Verify postage plugin installation by requesting project info from PostageApp.com'
  task :test => :environment do 
    puts "Attempting to contact PostageApp..."
    response = Postage::Request.new(:get_project_info).call!
    if response.blank?
      puts 'Failed to recieve a response. Check your configuration please.'
    else
      puts "Received response: \n----------"
      puts response.to_yaml
      puts '----------'
      if response[:response] == 'success'
        puts 'Everything seems to be in order.'
      else
        puts 'Received unexpected response. Check your configuration please.'
      end
    end
  end
  
end