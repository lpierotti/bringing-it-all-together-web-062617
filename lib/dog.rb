require 'pry'
class Dog

	attr_accessor :id, :name, :breed

	def initialize(name:, breed:, id: nil)
		@name = name
		@breed = breed
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT)
		SQL
	end

	def self.drop_table
		sql = "DROP TABLE dogs"
		DB[:conn].execute(sql)
	end

	def self.new_from_db(row)
		new_dog = self.new(name: row[1], breed: row[2])
		new_dog.id = row[0]
		#binding.pry
		new_dog
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE ? = dogs.name
		SQL

		DB[:conn].execute(sql, name).map do |row|
			self.new_from_db(row)
		end.first
	end

	def update
		sql = <<-SQL
			UPDATE dogs
			SET name = ?, breed = ? WHERE dogs.id = ?
		SQL

		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end

	def save
		if self.id
			self.update
		else
			sql = <<-SQL
				INSERT INTO dogs (name, breed) 
				VALUES (?,?)
			SQL

			DB[:conn].execute(sql, self.name, self.breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
			self
		end
	end

	def self.create(hash)
		dog = self.new(hash)
		dog.save
		dog
	end

	def self.find_by_id(id)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE dogs.id = ?
		SQL

		DB[:conn].execute(sql, id).map do |row|
			self.new_from_db(row)
		end.first
	end

	def self.find_or_create_by(info)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE dogs.name = ? AND dogs.breed = ?
		SQL
		#binding.pry

		if DB[:conn].execute(sql, info[:name], info[:breed]) != []
			DB[:conn].execute(sql, info[:name], info[:breed]).map do |row|
				self.new_from_db(row)
			end.first
		else
			self.create(info)
		end

	end


end