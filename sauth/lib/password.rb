module Password
	require 'digest/sha1'

	attr_reader :password

	def password=(clear_pass)
		unless password.nil?
    		self[:password] = Digest::SHA1.hexdigest(clear_pass)
		end
  	end

  	def authenticate(login, clear_pass)
		user = User.find_by_login(login)
		!user.nil? && user.password == Digest::SHA1.hexdigest(clear_pass)
  	end 
end
