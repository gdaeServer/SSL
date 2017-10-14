require 'jsonclient'
require 'json'
require 'mongo'
include Mongo
require 'uri'




class DocController < ApplicationController
	skip_before_action :verify_authenticity_token # delete this for security!!

	def index
		#puts "Index, line " + "8"
		if params[:authors]
			
			@authors = true
			reg = '^' + params[:authors]
			regex = Regexp.new reg
			@cursor = ssl.find({"pretty_name"=>regex}).sort("pretty_name")
			@docs = []
			start = params[:page].to_i * 20 
			curr = ""
			entries = []
			@cursor.skip(start).first(21).each do |d|
				if not curr == d['pretty_name'] and not curr == ""
					doc = {:name => d['pretty_name'], :entries => entries, :id => d['id']}
					entries = []
					@docs << doc	
				end
				
				entry = {:title => d['title'], :id => d['id']}
				entries.push(entry)
				curr = d['pretty_name']

			end

			@dpag = Kaminari.paginate_array(@docs).page(1).per(@docs.length-1)

		else
			# DEAL with KW: 
			# OR  1. get top level kws separately (Y)
			# 	  2. its children: get everything that is kid = .../{#name}[\/]([^\/]*)/ (Y)
			#     3. put all the kids in an array (Y)
			#     4. make sure unique and display them in kws area
			# @kwpath = params[:kwpath] # BUG: kwpath sometimes work sometimes does not.
			parent = ""
			if not params[:kw].nil?
				parent = params[:kw]                     
			end

			# DEAL with SSL:
			# OR REGEX that certain word in the path: db.categories.find( { path: /,Programming,/ } )
			# rgex = Regexp.new(parent)
			# @cursor = ssl.find( {"sslbrowsepath" => rgex} everybody whose path has the "name"

			reg = /#{Regexp.quote(parent)}/
			flts = filters
			flts["sslbrowsepath"] = reg

			@cursor = ssl.find(flts).sort(sorted_by) 
			@count = @cursor.count()
			@docs = []
			start = params[:page].to_i * 20 
			@cursor.skip(start).first(21).each do |d|
				@docs << d
			end
			@dpag = Kaminari.paginate_array(@docs).page(1).per(20)   #BUG: count and the actual number of articles displayed not same
		end
		
	end

	# show an article (beautified in "views/show.hrml.erb"
	def show
		#puts "Show, line " + "19"
		@doc = ssl.find({id: params[:id]}).to_a.first

		if @doc.nil?
			redirect_to docs_path, notice: 'No record of doc with id: ' + params[:id].to_s  
		end
	end

	# show raw JSON of an article
	def raw
		#puts "raw, line " + "27"
		@raw = ssl.find({id: params[:id]}).to_a.first
		if @raw.nil?
			redirect_to doc_index_path, notice: 'No record of doc with id: ' + params[:id].to_s  
    		else
    			render json: @raw 
		end
  	end

  	# I don't understand what it does
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

  	def browse

  		#All the data needed is loaded from public/discipline_hierarchy.json. 
  		#To re-create this file, use the python script mongojson_to_bootstrap_htree_parse.py with a
  		# json prepared as in the commented out code below. see
  		

		# coll = ssl_keywords
		# whole_keywords = coll.find()
		# File.open("tmp.json", 'w') { |file| 
		# 	whole_keywords.each do |d|
		# 		file.write(d)		
		#  end
		# }


  	end
	private

		# having this whole separate DB because it's faster
	    def ssl_keywords
	    	# db = Mongo::Connection.new("localhost", 27017).db("ssl")
	    	# coll = db.collection('yummmmy')
	    	mongo_uri = 'mongodb://ahedbe01:gdae2015@ds047591.mongolab.com:47591/heroku_app34131114' #ENV['SSL_MONGODB']
			db_name = "heroku_app34131114"
			client = MongoClient.from_uri(mongo_uri)
			db = client.db(db_name)
			coll = db.collection('keywords')

	    	# initialize the keyword tree DB
	    	if coll.count() == 0 
		    	# No.1: an array of path values of all docs 

		    	paths_array = ssl.distinct('sslbrowsepath')

		    	# No.2: Turn into Ruby hashes    	
		    	my_hashes = []
		    	tops = []
		    	tops_uniq = []
	            paths_array.each do |p| 

	            	my_toplevel = p.strip()[/^([^\/]+)/]
	            	if p.include? "/"  #make sure has kids
		            	tops << {
		            		:name => my_toplevel,
		            		:parent => "Everything",
		            		:path => "",
		            	}
		            end

	            	name = p.strip()[/([^\/]+)$/] # name: word after the last "/" => a leaf child of the kw tree.
	            	minus_name = p.strip().sub(/\/+#{Regexp.quote(name)}$/, '') # minus_name: the original path except "name"
	            	parent = minus_name.strip()[/([^\/]+)$/] # word between the second last and the last "/"s => "name"'s parent       

	           		if parent.nil? or parent == "" or !p.include? "/"
	            		parent = "bye"  
	            	end 

	            	my_hashes << {
	            		:name => name,
	            		:parent => parent, 
	            		:path => p,
	            	}	            	
	            end

	            tops_uniq = tops.uniq{|x| x[:name]} 

	            my_hashes = my_hashes | tops_uniq

		    	# No.3: import all keywords and their paths into keyword DB
		    	my_hashes.each do |p|
		    		coll.insert({ :name => p[:name], :parent => p[:parent], :path => p[:path] })
		    	end
		    end 
		    # No.4: return the imported collection
	    	coll
	    end

		
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
			# authors: array
			if params.has_key?(:author) and params[:author].match(/^[[:alnum:]\ ]+$/)
				author = Regexp.union(params[:author].split(' ').map{|word| Regexp.new(word, true)})
				flts["authors"] = author
			end
			# keywords: array ???? TODO
			if params.has_key?(:keywords) and params[:keywords].match(/^[[:alnum:]\ ]+$/)
				keywords = Regexp.union(params[:keywords].split(' ').map{|word| Regexp.new(word, true)})
				flts["subject_terms"] = keywords
			end
			# disciplines: array
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
			# filters is an array of key-value pairs. It looks like:
			# {"title": "harry potter", "author": "J.K. Rowling", "subject_terms": "[fiction, fantasy, magic]"}
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



end
