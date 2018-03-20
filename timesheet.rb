#!/usr/bin/env ruby
require 'watir'
require 'optparse'

options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"

    opts.on("-r", "--[no-]refresh-session", "refresh user session") do |r|
        options[:refresh] = r
    end

    opts.on("-u USERNAME", "--username USERNAME", "your username") do |user|
        options[:username] = user
    end

    opts.on("-p PASSWORD", "--password PASSWORD", "your password") do |pass|
        options[:password] = pass
    end

    opts.on("-e ENTERTIME", "--enter-time ENTERTIME", "the time you entered") do |time|
        options[:enter_time] = time
    end

    opts.on("-x EXITTIME", "--exit-time EXITTIME", "the time you exited") do |time|
        options[:exit_time] = time
    end

    opts.on("-o ORGANIZATION", "--organization-name ORGANIZATION", "the name of your organization as used by pingone") do |organization|
        options[:organization] = organization
    end

end.parse!
raise OptionParser::MissingArgument if options[:password].nil?
raise OptionParser::MissingArgument if options[:username].nil?
raise OptionParser::MissingArgument if options[:organization].nil?


username = options[:username]
password = options[:password]
organization = options[:organization]
organization_capitalized = organization.capitalize + "Inc" 

pingone_url = "https://#{organization}.pingone.com"
timesheet_url = "https://eu1.replicon.com/#{organization_capitalized}/my/timesheet/current"
timesheet_test = "https://eu1.replicon.com/#{organization_capitalized}/my/punch"

enter_time = options[:enter_time] ? options[:enter_time] : "9:00"
exit_time = options[:exit_time] ? options[:exit_time] : "19:00"

caps = Selenium::WebDriver::Remote::Capabilities.chrome
caps[:chrome_options] = {detach: true}
#browser = Watir::Browser.new :chrome, desired_capabilities: caps
browser = Watir::Browser.new :chrome, detach: false 
if options[:refresh] then
    browser.cookies.clear
    browser.goto pingone_url

    browser.text_field(id: 'username').wait_until_present(timeout: 20).set(username)
    browser.text_field(id: 'password').wait_until_present(timeout: 20).set(password)
    sleep 2 
    begin
        browser.execute_script('window.postOk()')
    rescue
       puts "couldnt login , did you click ok for me?" 
    end

    begin
        browser.iframe(:id => "duo_iframe").wait_until_present(timeout: 30)
    rescue
        puts "cant find duo_iframe.."
    end

    button = browser.iframe(:id => "duo_iframe").button(:class => "auth-button").wait_until_present(timeout: 20)
    button.click
    sleep 3
    browser.a(:class => 'ping-app').wait_until_present(timeout: 20)
    sleep 3
    browser.div("app-id"=> '31417741-9964-4301-8dc2-6a4d498831d6').wait_until_present(timeout: 20).click 
    browser.windows.last.use
    sleep 3
    browser.execute_script(%Q'window.location="/#{organization_capitalized}/my/timesheet/default"')
    sleep 3
    browser.cookies.save(file = 'cookies')
else
    browser.goto pingone_url
    begin
        browser.cookies.load(file = 'cookies')
    rescue
        puts "cant find cookies file, please try to refresh cookies"
    end
    browser.goto timesheet_test
end
sleep 2.3
browser.goto timesheet_url

Watir::Wait.until { browser.lis(:class => "day").length >= 10}
add_punches = browser.lis(:class => /^day$/).map do |day|
    day.a(:class => "addPunchLink").wait_until(timeout: 20, &:present?)
end
add_punches.each do |add_punch_link|
    begin
        add_punch_link.click
        browser.text_field(:class => "time").set(enter_time)
        browser.table(:class => "fieldTable").a(:class => "divDropdownSelectionNeeded").click
        browser.ul(:class => "divDropdownListLimitedWidth").a(:text => "Work Hours").click
        browser.button(:value => "Add").click
        sleep 2.6
    rescue Exception => e
        puts e
    end
end

existing_punches = browser.spans(:class => "badgePunchMissing").map do |punch|
    punch.wait_until(timeout: 20, &:present?)
end

existing_punches.each do |punch|
    begin
        punch.click
        sleep 1
        browser.text_field(:class => "time").set(exit_time)
        browser.button(:value => "Add").click
        sleep 3.5
    rescue Exception => e
        puts e
    end
end
