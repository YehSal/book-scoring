# Yehia Saleh
# Created 11/8/16

# This program parses a JSON file containing books info and a CSV of keywords,
# their genres, and scores and prints out the parsed books alphabetically with
# their highest 3 genres
require 'pry'
require 'json'
require 'csv'

# Holds relevant information for every JSON parsed book
class Book
  attr_accessor :title, :genres, :keyword_entries, :genre_score_entries,
                :description

  def initialize(title, description)
    @title = title
    @description = description
    @genres = []
    @keyword_entries = []
    @genre_score_entries = []
  end

  # Only add genre if it hasn't been seen before
  def add_uniq_genre(genre)
    return if @genres.include?(genre)
    @genres << genre
  end

  # Parse description and return entries containing info about the keyword
  # encountered: it's genre, it's individual score, and how many times it
  # appeared
  def parse_description(csv)
    csv.each do |i|
      genre = i[0].strip
      keyword = i[1].strip
      score = i[2].to_i

      num_keywords = @description.scan(/#{keyword}/).count

      next if num_keywords.zero?

      add_uniq_genre(genre)
      keyword_entries << [genre, score, num_keywords]
    end
  end

  # Calculate final score for current genre
  def calculate_final_score(list)
    count = list.size
    total_unique_score = 0
    total_num_keywords = 0

    list.each do |entry|
      unique_score = entry[1]
      num_keyword = entry[2]

      total_unique_score += unique_score
      total_num_keywords += num_keyword
    end

    avg_score = total_unique_score / count
    final_score = total_num_keywords * avg_score

    genre = list[0][0]
    @genre_score_entries << [genre, final_score]
  end

  # Group keyword entries by genre
  def calculate_genre_scores
    @genres.each do |genre|
      curr_keyword_list = @keyword_entries.select { |entry| entry[0] == genre }
      calculate_final_score(curr_keyword_list)
    end
  end

  # prints out the highest 3 genre_score_entries for the current book
  def print_top_3
    @genre_score_entries.sort_by! do |i|
      i[1]
    end
    @genre_score_entries.reverse!

    puts @title

    to_print = @genre_score_entries[0..2]
    to_print.each { |entry| puts entry }
    print "\n"
  end
end

file = File.read('bookbub.json')
data_hash = JSON.parse(file)

keyword_scores = CSV.read('bookbub.csv')
keyword_scores.delete_at(0)

# Array to be filled with parsed books and their relevant info
result = []

data_hash.each do |i|
  title = i['title']
  description = i['description']

  # Fill parsed book with relevant info and calculate its scores
  new_book = Book.new(title, description)
  new_book.parse_description(keyword_scores)
  new_book.calculate_genre_scores

  result << new_book
end

# Sort books alphabetically before printing
result.sort_by!(&:title)
result.each(&:print_top_3)
