require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'firstblog.db'
	@db.results_as_hash = true
end

before do
	init_db

end

configure do

	init_db

	@db.execute 'CREATE TABLE IF NOT EXISTS Posts (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		author TEXT
	)'

	@db.execute 'CREATE TABLE IF NOT EXISTS Comments (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		post_id INTEGER
	)'

end

get '/' do

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index

end

get '/new' do
	erb :new
end

post '/new' do
	@content = params[:content]
	@author = params[:author]

	errors = {
		author: 'Type your name',
		content: 'Type post text'
	}

	errors.each_key do |key|
		if params[key] == ''
			@error = errors[key]
			return erb :new
		end
	end

	@db.execute 'insert into Posts (content, created_date, author) values (?, datetime(), ?)', [@content, @author]

	redirect to '/'
end

get '/details/:post_id' do

	post_id = params[:post_id]

	results = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = results[0]

	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	erb :details

end

post '/details/:id' do

	post_id = params[:id]
	comment = params[:content]

	if comment == ''

		results = @db.execute 'select * from Posts where id = ?', [post_id]
		@row = results[0]

		@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

		@error = 'Type your comment'
		return erb :details

	end

	@db.execute 'insert into Comments (
		content,
		created_date,
		post_id
	) values (
		?,
		datetime(),
		?
	)', [
		comment,
		post_id
	]

	redirect to "/details/#{post_id}" 

end
