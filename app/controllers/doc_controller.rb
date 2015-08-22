require 'jsonclient'
require 'mongo'
include Mongo
require 'uri'

class DocController < ApplicationController
	def index
		#TEST PUSH PULL
		#puts "Index, line " + "8"
		if params[:authors]
			puts params[:authors]
			@authors = true
			reg = '^' + params[:authors]
			regex = Regexp.new reg
			@cursor = ssl.find({"pretty_name"=>regex}).sort("pretty_name")
			puts "here"
			auth_objs = get_authors(@cursor)
			puts "there"

			#@curr_auth = ""
			@docs = []
			start = params[:page].to_i * 20 
			auth_objs.drop(start).first(21).each do |d|
				@docs << d
			end

			@dpag = Kaminari.paginate_array(@docs).page(1).per(20)

		else
			@cursor = ssl.find(filters).sort(sorted_by)
			@count = @cursor.count()
		
			puts @cursor.count()
			puts "\n\n\n\n\n"
			@docs = []
			start = params[:page].to_i * 20 
			@cursor.skip(start).first(21).each do |d|
				@docs << d
			end
			@dpag = Kaminari.paginate_array(@docs).page(1).per(20)
		end
		
	end

	def show
		#puts "Show, line " + "19"
		@doc = ssl.find({id: params[:id]}).to_a.first
		if @doc.nil?
			redirect_to docs_path, notice: 'No record of doc with id: ' + params[:id].to_s  
		end
	end

	def raw
		#puts "raw, line " + "27"
		@raw = ssl.find({id: params[:id]}).to_a.first
		if @raw.nil?
			redirect_to doc_index_path, notice: 'No record of doc with id: ' + params[:id].to_s  
    		else
    			render json: @raw 
		end
  	end

	def find
		#puts "find, line " + "37"
		clnt = JSONClient.new
		header = {'Cookie' => 'Summon-Two=true'}
		uri = URI.parse(URI.encode("http://tufts.summon.serialssolutions.com/api/search?pn=1&ho=t&q=" + params[:title]))
		response = clnt.get(uri, nil, header)
		json_response = response.content
		if json_response.keys.include?("documents")
			@result = response.content["documents"]
		else
			@result = ''
		end
	end

	def create
		#puts "create, line " + "51"
		if params[:new_doc_contents].nil?
			puts 'Failed to find new_doc_contents'
			redirect_to doc_find_path, alert: 'Could not find that doc'
		else
			new_doc = params[:new_doc_contents]
			new_doc['title'] = new_doc['title'].gsub('<b>', '').gsub('</b>', '').titleize
			if new_doc['isbn'].nil?
				if new_doc['eissns'].nil?
					if not new_doc['issns'].nil? and not new_doc['issns'].split('"')[1].nil?
						new_doc['id'] = new_doc['issns'].split('"')[1]
					end
				else
					if not new_doc['eissns'].nil? and not new_doc['eissns'].split('"')[1].nil?
						new_doc['id'] = new_doc['eissns']
					end
				end
			else
				new_doc['id'] = new_doc['isbn']
			end
			begin
			 	new_id = ssl.insert(new_doc)
			 	new_doc_id = new_doc['id']
				redirect_to doc_path(new_doc_id), notice: 'Your document was successfully added to the SSL'
			rescue Mongo::OperationFailure => e
				redirect_to ssl_admin_path, alert: 'Error inserting document: ' + e.message
			end
		end
	end

	def edit
		#puts "edit, line " + "82"
		if current_user.try(:admin?)
			@edit = ssl.find({id: params[:id]}).to_a.first
			if @edit.nil?
				redirect_to doc_index_path, alert: 'No record of doc with id: ' + params[:id].to_s  
			end

			else
				redirect_to root_path, alert: 'You do not have permission to edit SSL entries'
			end
	end

  	def update
  		#puts "update, line " + "95"
    		if current_user.try(:admin?)
      			old_entry = ssl.find({id: params[:id]}).to_a.first
      			mongo_id = params["_id"]
      			update_mongo_id = old_entry["_id"]
      			if mongo_id.nil?
        			puts 'Failed to find id'
        			redirect_to docs_path, alert: 'Could not edit that doc'
      			else
        		begin
          			params.to_json
        		rescue JSON::JsonError
          			puts 'JSON Error'
          			redirect_to doc_path(params[:id]), alert: 'Your edits were not successful. Please try again.'
        		end
        		updated_keys = {}
        		params.each do |key, value|
	          		if key != "_id" and old_entry.include?(key) and value != old_entry[key]
	            		# don't want to try to update fields with the same value--mongo doesn't seem to like that
	            		updated_keys[key] = value
	          		end
        		end
		        # ssl.update never succeeds and I have no clue why
		        status = ssl.update({"_id" => update_mongo_id}, {"$set" => updated_keys}, {"$upsert" => true})
	        	if status[:ok] == 0 or status[:nModified] == 0
	          		puts updated_keys
	          		puts 'Status error: ' + status.to_s
	          		redirect_to doc_path(params[:id]), alert: 'Your edits were not successful. Please try again.'
	        	else
	          		redirect_to doc_path(params[:id]), notice: 'Your document was successfully edited'
	        	end
      		end	
		else
			redirect_to root_path, alert: 'You do not have permission to edit SSL entries'
    		end
	end

	def delete
  		#puts "delete, line " + "133"
	  	if current_user.try(:admin?)
      			puts params
	      		if params[:id].nil?
	        		puts 'Failed to find id'
        			redirect_to doc_index_path, notice: 'Could not delete that doc'
				else
					ssl.remove({id: params[:id]})
					redirect_to docs_path, notice: 'Your document was successfully deleted from the SSL'
      			end
	  	else
      			redirect_to root_path, alert: 'You do not have permission to delete entries from the SSL'
	  	end
  	end

	private
		
		def ssl
			#puts "private ssl, line " + "150"
			mongo_uri = 'mongodb://ahedbe01:gdae2015@ds047591.mongolab.com:47591/heroku_app34131114' #ENV['SSL_MONGODB']
			#db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
			db_name = "heroku_app34131114"
			client = MongoClient.from_uri(mongo_uri)
			db = client.db(db_name)
			db.collection('ssl').create_index("pretty_name")
			col = db.collection('ssl')
			col
		end

		def filters
			puts "filters, line " + "159"
			flts = {}
			if params.has_key?(:title) and params[:title].match(/^[[:alnum:]\ ]+$/)
				title = Regexp.new(params[:title].split(' ').map{|word| '(?=.*' << word << ')'}.join(''), true)
				flts["title"] = title
			end
			if params.has_key?(:author) and params[:author].match(/^[[:alnum:]\ ]+$/)
				author = Regexp.union(params[:author].split(' ').map{|word| Regexp.new(word, true)})
				flts["authors"] = author

			end
			if params.has_key?(:keywords) and params[:keywords].match(/^[[:alnum:]\ ]+$/)
				keywords = Regexp.union(params[:keywords].split(' ').map{|word| Regexp.new(word, true)})
				flts["subject_terms"] = keywords
			end
			if params.has_key?(:disciplines) and params[:disciplines].match(/^[[:alnum:]\ ]+$/)
				flts["disciplines"] = Regexp.union(params[:disciplines].split(' ').map{|word| Regexp.new(word, true)})
			end
			if params.has_key?(:publisher) and params[:publisher].match(/^[[:alnum:]\ ]+$/)
				flts["publisher"] = Regexp.new(params[:publisher], true)
			end
			if params.has_key?(:isbn) and not params[:isbn].nil?
				flts["isbn"] = Regexp.new(Regexp.escape(params[:isbn]), true)
			end

			flts
		end

		def sorted_by
			#puts "sorted by, line " + "203"
			srt = {}
			if params.has_key?(:sort_by) and params[:sort_by].match(/^[[:alnum:]\ ]+$/)
				if params[:sort_by] == "author"
					puts "Here \n\n\n"
					srt["pretty_name"] = 1
				else
					srt[params[:sort_by]] = 1
				end
			else
				srt[:title] = 1
			end
			srt
		end

		def get_authors(cursor)
			#auth_obj
			# => auth_name
			# => auth_array
			# => => title
			# => => URL
			# => => ISBN
			curr_auth = ""
			auth_objs = []
			auth_array = []
			cursor.each do |d|
				if not d['pretty_name'] == curr_auth
					auth_obj = {:name => curr_auth, :auth_array => auth_array}
					auth_objs.push(auth_obj)
					curr_auth = d['pretty_name']
					auth_array = []
				end
				entry = {:title => d['title'], :id => d['id'], :isbn => ['isbn']}
				auth_array.push(entry)
			end

			auth_objs

		end

end
