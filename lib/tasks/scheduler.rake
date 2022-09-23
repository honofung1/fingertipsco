desc "This task is called by the Heroku scheduler add-on"
task :test_scheduler => :environment do
  puts "scheduler test"
  puts "it works."
end

desc "When start day of the month, reset the order owner order count to zero"
task :monthly_reset_order_count => :environment do
  OrderOwner.all.each do |o|
    o.reset_order_count
  end
end