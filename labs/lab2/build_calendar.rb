teams_file = ARGV[0]
start_date = ARGV[1]
end_date = ARGV[2]
calendar_file = ARGV[3]

require 'date'

# парсим даты
start_date = Date.parse(start_date);
end_date = Date.parse(end_date);

if !File.exist?(teams_file)
  puts "file not found" 
  exit
end

# парсим файл с командами
teams = []
File.foreach(teams_file, encoding: "UTF-8") do |line|
  line = line.strip
  if line.include?('—')
    parts = line.split('—')
    teams << {name: parts[0].strip, city: parts[1].strip}
  end
end
puts "found #{teams.size} commands"

# разбиваем команды на пары дабы найти количество необходимых нам игр
pairs = []
teams.each_with_index do |team1, i|
  teams.each_with_index do |team2, j|
    if j > i
      pairs << [team1, team2]
    end
  end
end
puts "need #{pairs.size} games"

# ищем доступные дни и время
days_availible = []
date = start_date
while (date <= end_date)
  if date.wday == 5 || date.wday == 6 || date.wday == 0
    days_availible << date
  end
  date += 1
end

times = ["12:00", "15:00", "18:00"]
slots = []
days_availible.each do |d|
  times.each do |t|
    slots << {date: d, time: t, game_count: 0}
  end
end

games = []
pairs.each do |team1, team2|
  best_slot = slots.min_by{ |s| s[:game_count] }
  if best_slot[:game_count] < 2
    games << {
      date: best_slot[:date],
      time: best_slot[:time],
      team1: team1,
      team2: team2
    }
    best_slot[:game_count] += 1;
  else
    put "no space for games availible."
    break
  end
end

games = games.sort_by{ |g| [g[:date], g[:time]] }

File.open(calendar_file, "w") do |file|
  file.puts "GAMES CALENDAR"
  file.puts "from #{start_date} to #{end_date}"
  file.puts

  current_day = nil
  games.each do |game|
    if current_day != game[:date]
      current_day = game[:date]
      file.puts "\n#{game[:date]}"
    end
    file.puts "#{game[:time]}: #{game[:team1][:name]} vs #{game[:team2][:name]}"
  end
  file.puts "\nGames total: #{games.size}"
end
