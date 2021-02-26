class User < ActiveRecord::Base
    has_secure_password

    def sufficient_funds?(amount)
        self.balance >= amount ? true : false
    end
end
