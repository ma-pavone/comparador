require 'selenium-webdriver'

After do |scenario|
scenario_name = scenario.name.gsub(/\s+/,'_').tr('/','_')
if scenario.failed?
    ss_capture(scenario_name.downcase!, 'falhou')
elsif
    ss_capture(scenario_name.downcase!, 'passou')
end
end

at_exit do
puts 'Todos os testes foram concluidos.'
end