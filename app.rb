# this clusters a user's last 200 tweets into 500s bins
# and displays a little information about those bins
#
# create an app.yml that has your twitter api credentials
#
# app.yml:
# consumer_key: "blargh"
# consumer_secret: "foomf"


require 'twitter'
require 'yaml'

API_KEYS = YAML.load_file('app.yml')
config = {
  :consumer_key    => API_KEYS['consumer_key'],
  :consumer_secret => API_KEYS['consumer_secret'],
}

client = Twitter::REST::Client.new(config)

puts "Enter Twitter username: "
username = gets.chomp

timeline = client.user_timeline(username, {count: 200})

clusters = []
current_cluster = []

# cluster tweets in 5 min intervals
timeline.reverse.each do |tweet|
  if current_cluster.empty?
    # puts "New cluster starting at %s" % tweet.created_at
    current_cluster << tweet
    clusters << current_cluster
  else
    if (tweet.created_at.to_i - current_cluster[0].created_at.to_i) < 500
      # puts "Adding tweet to cluster +%d seconds" % (tweet.created_at.to_i - current_cluster[0].created_at.to_i)
      current_cluster << tweet
    else
      # puts "New cluster starting at %s" % tweet.created_at
      current_cluster = [tweet]
      clusters << current_cluster
    end
  end
end

puts "-----------------------------------------"

# display cluster details
cluster_bins = Hash.new(0)
clusters.each do |cluster|
  # puts "Cluster start %s with %d tweets" % [cluster[0].created_at, cluster.count]
  cluster_bins[cluster.count] = cluster_bins[cluster.count]+1
end

cluster_bins.keys.sort.each do |k|
  puts "%d clusters with %d tweets" % [cluster_bins[k],k]
end
cluster_max = clusters.map { |c| c.count }.max

puts "-----------------------------------------"

# now show the timestamps of the clusters that are max size
# that's when you be poopin'
clusters.each do |cluster|
  if cluster.count >= cluster_max
    puts "%s tweeted %d times starting at %s" % [username, cluster_max, cluster[0].created_at]
  end
end
